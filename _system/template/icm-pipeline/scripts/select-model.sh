#!/usr/bin/env bash
# select-model.sh — read a stub's complexity, print the model to open the session on (TEMPLATE-OWNED).
#
# A stub, a scope and a spec each carry a `complexity` line (`_shared/scope-template.md` → Complexity
# and the model; `intake/CONTEXT.md` → Formats). Which model that implies is the same answer every
# time, so it is not re-derived in conversation and not restated in a contract — it lives here once:
#
#   low · trivial · easy            → sonnet     well-trodden work, one surface
#   medium · standard               → sonnet     ordinary feature work
#   high · complex · architecture   → opus       a new boundary, a data-model change, a risky rewrite
#   research · investigation · spike → fable     the answer is not known yet
#
# Both vocabularies are read on purpose: a stub says low|medium|high|research, a spec says
# trivial|standard|complex (the labels depend on that one), and the helper is pointed at either.
# An explicit `recommended-model` line WINS over the mapping — that line is the operator's override.
# A file with neither reads as `medium`, and the output says it was a default, not a reading.
#
# It PRINTS a recommendation. It starts no session, switches no model, and no stage acts on it by
# itself — the operator reads the line when opening the session that will do the work. (The house
# rule: never build an orchestrator. This is a lookup, not a launcher.)
#
# Header forms read, in this order — the first `complexity` found is the one used:
#   - complexity: high                      the estate's `- key: value` header
#   complexity: "high" # a comment          a YAML front-matter block between `---` fences
# and the same two forms for `recommended-model` / `recommended_model`.
#
# The model is printed as an ALIAS (sonnet | opus | fable) — what `claude --model <alias>` takes.
# A harness that wants a full model id reads it from the project's own manifest, never from here:
# `.icm/project.json` → `"models": {"opus": "<id>", …}` adds an `id:` line for the chosen alias.
#
# Usage:
#   .icm/scripts/select-model.sh <epic>/<feature-slug>    # .icm/intake/<epic>/<feature-slug>.md
#   .icm/scripts/select-model.sh <stub-name>              # found anywhere under .icm/intake/ (live)
#   .icm/scripts/select-model.sh <path-to-file>           # any stub, scope.md or spec.md
#   … [--json]                                            # one JSON object instead of the lines
#
# Verdict (stdout, last line):
#   RESULT: MODEL <alias>   exit 0  — read from the file, or the `medium` default (the lines say which)
#   RESULT: INVALID         exit 2  — a complexity or model word outside the vocabulary
#   (exit 1: usage, no such file, or an ambiguous stub name — the matches are listed)
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"
die() { echo "error: $*" >&2; exit 1; }

as_json=0; arg=""
while [ $# -gt 0 ]; do
  case "$1" in
    --json)    as_json=1; shift ;;
    -h|--help) sed -n '2,40p' "${BASH_SOURCE[0]}"; exit 0 ;;
    --*)       die "unknown flag: $1" ;;
    *)         [ -z "$arg" ] && arg="$1" || die "unexpected argument: $1"; shift ;;
  esac
done
[ -n "$arg" ] || die "usage: select-model.sh <epic>/<feature-slug> | <stub-name> | <path> [--json]"

# --- resolve the file ------------------------------------------------------------------------------
file=""
if [ -f "$arg" ]; then
  file="$arg"
elif [ -f ".icm/intake/${arg%.md}.md" ]; then
  file=".icm/intake/${arg%.md}.md"
else
  # A bare stub name: look through the live intake folders (epics and triage), never the archives —
  # a consumed stub is not work anybody is about to open a session for.
  mapfile -t hits < <(find .icm/intake -name "${arg%.md}.md" -not -path '*/_done/*' 2>/dev/null | sort)
  case "${#hits[@]}" in
    0) die "no stub '$arg' under .icm/intake/ (give <epic>/<feature-slug>, a stub name, or a path)" ;;
    1) file="${hits[0]}" ;;
    *) printf '  %s\n' "${hits[@]}" >&2; die "stub name '$arg' is ambiguous — give <epic>/<feature-slug>" ;;
  esac
fi
file="${file#./}"

# --- read one header key, either form ---------------------------------------------------------------
# Only the header is searched: everything before the first `## ` section. A body that happens to
# say "complexity: high" in a sentence is prose, not a field.
header_value() { # <key-regex>
  awk -v key="$1" '
    /^##[[:space:]]/ { exit }
    {
      line = $0
      sub(/^[[:space:]]*-[[:space:]]+/, "", line)            # the estate "- key: value" form
      if (line ~ "^(" key ")[[:space:]]*:") {
        val = substr(line, index(line, ":") + 1)
        sub(/[[:space:]]+#.*$/, "", val)                     # a trailing "# comment"
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
        gsub(/^["\047]|["\047]$/, "", val)                   # YAML quotes
        print tolower(val); exit
      }
    }
  ' "$file"
}

complexity="$(header_value 'complexity')"
override="$(header_value 'recommended[-_]model')"

# A template left unfilled ("<low | medium | …>", "low | medium | high") is not a reading.
case "$complexity" in *"<"*|*"|"*) complexity="" ;; esac
case "$override"   in *"<"*|*"|"*) override="" ;; esac

# --- the mapping ------------------------------------------------------------------------------------
model=""; source=""
case "$complexity" in
  low|trivial|easy)                 model="sonnet"; source="complexity" ;;
  medium|standard)                  model="sonnet"; source="complexity" ;;
  high|complex|architecture)        model="opus";   source="complexity" ;;
  research|investigation|spike)     model="fable";  source="complexity" ;;
  "")                               model="sonnet"; source="default"; complexity="medium" ;;
  *) echo "$file: complexity '$complexity' is not low|medium|high|research (or a spec's trivial|standard|complex)" >&2
     echo "RESULT: INVALID"; exit 2 ;;
esac

if [ -n "$override" ]; then
  case "$override" in
    sonnet|opus|fable) model="$override"; source="recommended-model" ;;
    *) echo "$file: recommended-model '$override' is not sonnet|opus|fable" >&2
       echo "RESULT: INVALID"; exit 2 ;;
  esac
fi

# --- the project's own id for that alias, when it keeps one ----------------------------------------
model_id=""
if command -v jq >/dev/null 2>&1; then
  # shellcheck source=lib/project.sh
  source "$(dirname "${BASH_SOURCE[0]}")/lib/project.sh"
  model_id="$(project_field ".models.${model}" '')"
fi

case "$source" in
  complexity)        why="from complexity: $complexity" ;;
  recommended-model) why="the file's own recommended-model line (complexity: $complexity)" ;;
  default)           why="default — the file carries no complexity line, read as medium" ;;
esac

if [ "$as_json" -eq 1 ]; then
  command -v jq >/dev/null 2>&1 || die "--json needs jq"
  jq -n --arg file "$file" --arg complexity "$complexity" --arg model "$model" \
        --arg source "$source" --arg id "$model_id" \
    '{file: $file, complexity: $complexity, model: $model, source: $source}
     + (if $id == "" then {} else {id: $id} end)'
else
  echo "file:       $file"
  echo "complexity: $complexity"
  echo "model:      $model  ($why)"
  [ -z "$model_id" ] || echo "id:         $model_id  (.icm/project.json → models.$model)"
  echo "open with:  claude --model $model   ·   any other harness: its own name for \"$model\"${model_id:+ ($model_id)}"
fi
echo "RESULT: MODEL $model"

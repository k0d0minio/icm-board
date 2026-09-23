#!/usr/bin/env bash
# icm-check.sh — verify (and with --fix, populate) the estate-wide .icm/.claude baseline.
#
# Discovers git repos the same way pull-all.sh does — the root repo itself (icm-board,
# .git at the Apps root) plus every repo up to 2 levels below Apps/ — skips sustentus
# (its .icm/ carries its own pipeline semantics; it is the source the template was
# extracted from), and checks each repo against _system/template/:
#
#   .icm/CONTEXT.md          the repo's .icm map
#   .icm/intake/README.md    micro-copy of the intake contract (epics + stubs + triage)
#   .icm/intake/triage/      the parking lane
#   .icm/intake/_done/       the archive (completed epics + legacy tickets)
#   .icm/docs/               ad hoc reports
#   .claude/settings.json    clean policy baseline
#   .claude/hooks/*          canonical estate hooks (session-start, wrap-reminder, and —
#                            kodominio repos only — vercel-env-hydrate)
#   .claude/skills/*         canonical estate skills (ticket-craft, pr-conventions)
#   AGENTS.md                reported only — never templated (each repo writes its own)
#   CLAUDE.md                the one-line `@AGENTS.md` importer — seeded, but only into
#                            a repo that already carries AGENTS.md
#   opencode.jsonc           the estate's OpenCode rails — same gate as the importer
#   .icm/project.md          reported only — /project writes it from an interrogation
#
# Layer 0 is moving from a full CLAUDE.md to AGENTS.md plus a one-line `@AGENTS.md`
# importer (epic opencode-sidecar). Both shapes are accepted for as long as the rollout
# takes: a repo satisfies the identity check with EITHER a legacy CLAUDE.md OR the
# AGENTS.md + importer pair, and only a repo carrying neither warns. AGENTS.md itself is
# never templated — each repo writes its own Layer 0, exactly as CLAUDE.md was.
#
# EVERY repo is additionally checked — and with --fix, seeded — against the pipeline
# (contracts/PIPELINE.md): template/icm-pipeline/ → .icm/, template/claude-pipeline/ →
# .claude/, template/github-pipeline/ → .github/. There is no profile to declare any more
# (decision D22): the `- profile:` line an older .icm/CONTEXT.md carries is not read, and
# how much of the pipeline a repo leans on is its own `complexity` in .icm/project.json
# (`micro` | `standard`). The pipeline file list is NOT hardcoded here: it is read from
# template/icm-pipeline/MANIFEST, the one file icm-sync.sh reads too (decision D20), so the
# two can never disagree. `T` entries are template-owned — required, seeded when missing,
# and DRIFT-REPORTED against the template (the repair is `icm-sync.sh --apply`, a human's
# call — this script still never overwrites). `P` entries are project-owned — required,
# seeded once from the template's stub when missing, never compared afterwards.
#
# --repo <path> measures exactly one repo, exempt or not: the way to read sustentus against
# the template it is the source of, without lifting the exemption for the estate walk.
#
# --fix creates ONLY what is missing, from the template; existing files are never
# touched — with exactly one exception, decision D18: it merges the template's own
# registration for a seeded-but-unregistered hook into an existing settings.json. It
# appends only an entry the repo's file does not already name, rewrites nothing, and
# touches no other key. Requires jq; without it the merge is skipped and the inert-hook
# warning stands. A repo's copy of a canonical asset that has diverged from the template
# is reported as drift and never repaired — repos own their copies (template/README.md).
# Legacy flat PREFIX-NNN tickets are reported as unmigrated, never converted.
#
# Usage: _system/scripts/icm-check.sh [--fix] [--repo <path>] [root]
# Exit:  0 report delivered — gaps are the report's content, not a failure (D15) ·
#        2 bad invocation

set -uo pipefail

FIX=0
APPS_ROOT=""
ONE_REPO=""
expect_repo=0
for arg in "$@"; do
  if (( expect_repo )); then ONE_REPO="$arg"; expect_repo=0; continue; fi
  case "$arg" in
    --fix) FIX=1 ;;
    --repo) expect_repo=1 ;;
    -*) echo "Unknown flag: $arg" >&2; exit 2 ;;
    *) APPS_ROOT="$arg" ;;
  esac
done
(( expect_repo )) && { echo "--repo needs a path" >&2; exit 2; }
[[ -n "$APPS_ROOT" ]] || APPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/template"

# jq powers the single merge --fix is permitted to make into an existing file (D18).
# Absent, the merge is skipped and the warning it would have silenced is reported with
# the reason attached — the report never claims a repo is wired when it is not.
JQ="$(command -v jq 2>/dev/null || true)"

if [[ ! -d "$APPS_ROOT" ]]; then echo "Not a directory: $APPS_ROOT" >&2; exit 2; fi
if [[ ! -d "$TEMPLATE/icm" || ! -d "$TEMPLATE/claude" || ! -d "$TEMPLATE/root" ]]; then
  echo "Template missing or incomplete: $TEMPLATE" >&2; exit 2
fi
MANIFEST="$TEMPLATE/icm-pipeline/MANIFEST"
[[ -f "$MANIFEST" ]] || { echo "Pipeline manifest missing: $MANIFEST" >&2; exit 2; }
if [[ -n "$ONE_REPO" ]]; then
  [[ -d "$ONE_REPO" ]] || { echo "Not a directory: $ONE_REPO" >&2; exit 2; }
  ONE_REPO="$(cd "$ONE_REPO" && pwd)"
fi

EXEMPT=("sustentus")

# Canonical Claude assets (template/claude/…): seeded when missing, drift-reported when
# a repo's copy diverges — never overwritten. Paths relative to <repo>/.claude/.
CANONICAL=(
  "hooks/session-start.sh"
  "hooks/wrap-reminder.sh"
  "skills/ticket-craft/SKILL.md"
  "skills/pr-conventions/SKILL.md"
)

# Canonical assets that stop at a team boundary. `vercel-env-hydrate.sh` hydrates a cloud
# session's environment from the Vercel team the repo deploys under, and sustentus and
# remi21 are separated boundaries (epic vercel-env-system, Jamie's ruling 2026-09-02):
# what their repos carry is decided in their repos, so the hook is offered there rather
# than seeded. sustentus is already exempt outright; remi-ai is named here instead of
# added to EXEMPT because it still takes every other part of the baseline. Nothing breaks
# in a repo that goes without it — `session-start.sh` only calls the file if it is there.
CANONICAL_KODOMINIO=( "hooks/vercel-env-hydrate.sh" )
SEPARATE_TEAM=("remi-ai")

# The pipeline (template/icm-pipeline/…): paths relative to <repo>/.icm/, read from the
# MANIFEST — `T` template-owned (drift-reported), `P` project-owned (seeded once). One list
# for this script and for icm-sync.sh, so the checker and the repair cannot disagree.
mapfile -t PIPELINE_ICM     < <(awk '$1=="T"{print $2}' "$MANIFEST")
mapfile -t PIPELINE_PROJECT < <(awk '$1=="P"{print $2}' "$MANIFEST")
for p in "${PIPELINE_ICM[@]}" "${PIPELINE_PROJECT[@]}"; do
  [[ -f "$TEMPLATE/icm-pipeline/$p" ]] || { echo "MANIFEST names a file the template lacks: $p" >&2; exit 2; }
done
PIPELINE_CLAUDE=( "skills/pipeline/SKILL.md" )
PIPELINE_GITHUB=( "pull_request_template.md" )

# Canonical root assets (template/root/…): the new-shape bundle. Seeded — and required —
# ONLY in a repo that has already migrated its Layer 0 to AGENTS.md, so an un-migrated
# repo never goes red for a shape it has not been moved to yet (the rollout is
# estate-rollout's work, not this script's). Paths relative to <repo>/.
#   CLAUDE.md      the one-line `@AGENTS.md` importer. Seed-only and NEVER drift-checked:
#                  a legacy CLAUDE.md diverges from it by design, and that is the whole
#                  point of the transition tolerance.
#   opencode.jsonc the estate's OpenCode rails; drift-reported like any other canonical
#                  asset once a repo carries one.
CANONICAL_ROOT=( "opencode.jsonc" )

bold=$'\033[1m'; red=$'\033[31m'; green=$'\033[32m'; yellow=$'\033[33m'; dim=$'\033[2m'; off=$'\033[0m'
[[ -t 1 ]] || { bold=; red=; green=; yellow=; dim=; off=; }

mapfile -t repos < <(
  find "$APPS_ROOT" -mindepth 2 -maxdepth 3 -name .git \
    \( -type d -o -type f \) \
    -not -path '*/node_modules/*' \
    -not -path '*/.*/.*/.git' \
    -printf '%h\n' | sort
)
# The root repo itself (icm-board, .git at the Apps root), checked like any other. It
# holds the baseline, so it is measured against it — a rule this repo exempts itself
# from is a rule it should delete (CLAUDE.md, standing rules).
[[ -e "$APPS_ROOT/.git" ]] && repos=("$APPS_ROOT" "${repos[@]}")
# --repo: exactly one repo, measured voluntarily — the exemption list does not apply.
[[ -n "$ONE_REPO" ]] && repos=("$ONE_REPO")

total=0; conformant=0; fixed=0; warnings=0; gaps=0

for repo in "${repos[@]}"; do
  name="${repo#"$APPS_ROOT"/}"
  base="$(basename "$repo")"
  [[ "$repo" == "$APPS_ROOT" ]] && name="$base"

  skip=0
  for e in "${EXEMPT[@]}"; do [[ "$base" == "$e" ]] && skip=1; done
  [[ -n "$ONE_REPO" ]] && skip=0
  if (( skip )); then
    echo "${dim}${name} — exempt${off}"
    continue
  fi

  total=$((total + 1))
  missing=(); warns=(); actions=(); repo_fixed=0

  # The canonical Claude assets this particular repo should carry.
  assets=("${CANONICAL[@]}")
  separate=0
  for t in "${SEPARATE_TEAM[@]}"; do [[ "$base" == "$t" ]] && separate=1; done
  (( separate )) || assets+=("${CANONICAL_KODOMINIO[@]}")

  # Has this repo's Layer 0 moved to AGENTS.md yet? Everything new-shape hangs off this
  # one fact, so an un-migrated repo is measured exactly as it was before the move.
  migrated=0
  [[ -f "$repo/AGENTS.md" ]] && migrated=1

  # --- .icm baseline ---
  [[ -f "$repo/.icm/CONTEXT.md" ]]        || missing+=(".icm/CONTEXT.md")
  [[ -d "$repo/.icm/intake" ]]            || missing+=(".icm/intake/")
  [[ -f "$repo/.icm/intake/README.md" ]]  || missing+=(".icm/intake/README.md")
  [[ -d "$repo/.icm/intake/triage" ]]     || missing+=(".icm/intake/triage/")
  [[ -d "$repo/.icm/intake/_done" ]]      || missing+=(".icm/intake/_done/")
  [[ -d "$repo/.icm/docs" ]]              || missing+=(".icm/docs/")

  # --- .claude baseline ---
  [[ -d "$repo/.claude" ]]               || missing+=(".claude/")
  [[ -f "$repo/.claude/settings.json" ]] || missing+=(".claude/settings.json")
  for asset in "${assets[@]}"; do
    [[ -f "$repo/.claude/$asset" ]] || missing+=(".claude/$asset")
  done

  # --- new-shape root assets (only once the repo carries AGENTS.md) ---
  if (( migrated )); then
    [[ -f "$repo/CLAUDE.md" ]] || missing+=("CLAUDE.md (the one-line \`@AGENTS.md\` importer)")
    for asset in "${CANONICAL_ROOT[@]}"; do
      [[ -f "$repo/$asset" ]] || missing+=("$asset")
    done
  fi

  # The rails file is opencode.jsonc, not opencode.json — it carries the `//` comment
  # explaining the push gate's last-match-wins ordering, and a repo linting `**/*` with
  # Biome parses a `.json` file as strict JSON and fails on it. A leftover `.json` is
  # either a half-finished rename or a repo OpenCode is now reading twice, so say so
  # wherever it appears, migrated or not.
  [[ -f "$repo/opencode.json" ]] && \
    warns+=("legacy opencode.json at root — the rails file is opencode.jsonc (a .json copy is strict JSON to Biome and breaks \`biome check\`)")

  # --- the pipeline (every repo — there is no profile to declare, D22) ---
  for p in "${PIPELINE_ICM[@]}";     do [[ -f "$repo/.icm/$p"     ]] || missing+=(".icm/$p"); done
  for p in "${PIPELINE_PROJECT[@]}"; do [[ -f "$repo/.icm/$p"     ]] || missing+=(".icm/$p (project-owned — seeded once)"); done
  for p in "${PIPELINE_CLAUDE[@]}";  do [[ -f "$repo/.claude/$p"  ]] || missing+=(".claude/$p"); done
  for p in "${PIPELINE_GITHUB[@]}";  do [[ -f "$repo/.github/$p"  ]] || missing+=(".github/$p"); done
  # Template-owned files are drift-reported against the template. The repair is
  # `icm-sync.sh --apply <repo>` — a human's call, never made here (D20).
  for p in "${PIPELINE_ICM[@]}"; do
    if [[ -f "$repo/.icm/$p" ]] && ! cmp -s "$TEMPLATE/icm-pipeline/$p" "$repo/.icm/$p"; then
      warns+=("pipeline drift: .icm/$p differs from the template — icm-sync.sh --dry-run shows it, --apply repairs it")
    fi
  done
  # A stage or lane contract the manifest does not list is either the repo's own addition
  # (fine — its project-rules.md should say so) or a file the template retired (git rm it).
  while IFS= read -r f; do
    rel="${f#"$repo/.icm/"}"
    printf '%s\n' "${PIPELINE_ICM[@]}" | grep -qxF "$rel" \
      || warns+=("not in the template's manifest: .icm/$rel — the repo's own addition, or a retired file to git rm (never removed here)")
  done < <(find "$repo/.icm/stages" "$repo/.icm/lanes" -name 'CONTEXT.md' 2>/dev/null | sort)

  # --- canonical drift (report-only, never repaired — repos own their copies) ---
  for asset in "${assets[@]}"; do
    if [[ -f "$repo/.claude/$asset" ]] && ! cmp -s "$TEMPLATE/claude/$asset" "$repo/.claude/$asset"; then
      warns+=("drift from canonical: .claude/$asset differs from _system/template/claude/$asset")
    fi
  done
  for asset in "${CANONICAL_ROOT[@]}"; do
    if [[ -f "$repo/$asset" ]] && ! cmp -s "$TEMPLATE/root/$asset" "$repo/$asset"; then
      warns+=("drift from canonical: $asset differs from _system/template/root/$asset")
    fi
  done
  # --- report-only checks (agent/human territory, never auto-fixed) ---
  # Layer-0 identity, shape-tolerant for the length of the AGENTS.md rollout: either the
  # legacy full CLAUDE.md or the AGENTS.md + importer pair satisfies it, and only a repo
  # with neither warns. Neither file is ever written from the template here — AGENTS.md
  # is each repo's own Layer 0, and the importer is only seeded once AGENTS.md exists.
  if (( ! migrated )) && [[ ! -f "$repo/CLAUDE.md" ]]; then
    warns+=("no Layer-0 identity file — expected AGENTS.md (+ the CLAUDE.md importer) or a legacy CLAUDE.md")
  fi
  # An importer pointing at nothing is worse than no importer; it can only appear if a
  # migration half-landed.
  if (( ! migrated )) && [[ -f "$repo/CLAUDE.md" ]] && \
     grep -qE '^[[:space:]]*@AGENTS\.md[[:space:]]*$' "$repo/CLAUDE.md" 2>/dev/null; then
    warns+=("CLAUDE.md imports @AGENTS.md but no AGENTS.md exists — Layer 0 resolves to nothing")
  fi
  # Deliberately never templated: an empty register is worse than none, because it
  # reads as established intent. /project writes it from a real interrogation.
  [[ -f "$repo/.icm/project.md" ]] || warns+=("no .icm/project.md — /project has never run here")
  legacy=0
  for f in "$repo/.icm/intake"/*.md; do
    [[ -e "$f" ]] || continue
    case "$(basename "$f" | tr '[:upper:]' '[:lower:]')" in readme.md|context.md) continue ;; esac
    legacy=$((legacy + 1))
  done
  (( legacy > 0 )) && warns+=("$legacy legacy flat ticket(s) in .icm/intake/ — unmigrated to the epic layout (/project re-cuts them; never converted here)")
  if git -C "$repo" check-ignore -q .icm 2>/dev/null; then
    warns+=(".gitignore excludes .icm — tickets would never reach the board")
  fi
  if git -C "$repo" check-ignore -q .claude/settings.json 2>/dev/null; then
    warns+=(".gitignore excludes .claude/settings.json — policy won't ship to cloud sessions")
  fi
  if [[ -f "$repo/.claude/settings.local.json" ]] && \
     ! git -C "$repo" check-ignore -q .claude/settings.local.json 2>/dev/null; then
    warns+=(".claude/settings.local.json is not gitignored (accretion layer should stay local)")
  fi
  for loose in TODO.md BACKLOG.md; do
    [[ -f "$repo/$loose" ]] && warns+=("loose $loose at root — should be stubs in .icm/intake/")
  done

  # --- fix ---
  if (( FIX )) && (( ${#missing[@]} > 0 )); then
    mkdir -p "$repo/.icm/intake/_done" "$repo/.icm/intake/triage/_done" "$repo/.icm/docs" "$repo/.claude"
    [[ -f "$repo/.icm/intake/_done/.gitkeep" ]] || : > "$repo/.icm/intake/_done/.gitkeep"
    [[ -f "$repo/.icm/intake/triage/_done/.gitkeep" ]] || : > "$repo/.icm/intake/triage/_done/.gitkeep"
    # .gitkeep only if docs/ is empty, so it can be dropped once real docs land
    if [[ -z "$(ls -A "$repo/.icm/docs" 2>/dev/null)" ]]; then
      : > "$repo/.icm/docs/.gitkeep"
    fi
    if [[ ! -f "$repo/.icm/CONTEXT.md" ]]; then
      cp "$TEMPLATE/icm/CONTEXT.md" "$repo/.icm/CONTEXT.md"
      actions+=("created .icm/CONTEXT.md")
    fi
    if [[ ! -f "$repo/.icm/intake/README.md" ]]; then
      cp "$TEMPLATE/icm/intake/README.md" "$repo/.icm/intake/README.md"
      actions+=("created .icm/intake/README.md")
    fi
    if [[ ! -f "$repo/.claude/settings.json" ]]; then
      cp "$TEMPLATE/claude/settings.json" "$repo/.claude/settings.json"
      actions+=("created .claude/settings.json")
    fi
    for asset in "${assets[@]}"; do
      if [[ ! -f "$repo/.claude/$asset" ]]; then
        mkdir -p "$(dirname "$repo/.claude/$asset")"
        cp "$TEMPLATE/claude/$asset" "$repo/.claude/$asset"
        case "$asset" in hooks/*) chmod +x "$repo/.claude/$asset" ;; esac
        actions+=("created .claude/$asset")
      fi
    done
    # New-shape root assets, seeded only into a repo that already carries AGENTS.md —
    # never overwritten, so a repo with a full legacy CLAUDE.md is left entirely alone.
    if (( migrated )); then
      if [[ ! -f "$repo/CLAUDE.md" ]]; then
        cp "$TEMPLATE/root/CLAUDE.md" "$repo/CLAUDE.md"
        actions+=("created CLAUDE.md (one-line \`@AGENTS.md\` importer)")
      fi
      for asset in "${CANONICAL_ROOT[@]}"; do
        if [[ ! -f "$repo/$asset" ]]; then
          cp "$TEMPLATE/root/$asset" "$repo/$asset"
          actions+=("created $asset")
        fi
      done
    fi
    for p in "${PIPELINE_ICM[@]}" "${PIPELINE_PROJECT[@]}"; do
      if [[ ! -f "$repo/.icm/$p" ]]; then
        mkdir -p "$(dirname "$repo/.icm/$p")"
        if [[ "$p" == "project.json" && -n "$JQ" ]]; then
          # The one stub with a value to fill: the repo's own name. Everything else in it
          # stays the template's default until the repo edits it.
          "$JQ" --arg n "$base" '.name = $n' "$TEMPLATE/icm-pipeline/$p" > "$repo/.icm/$p"
        else
          cp "$TEMPLATE/icm-pipeline/$p" "$repo/.icm/$p"
        fi
        case "$p" in scripts/lib/*) ;; scripts/*|skills/*/scripts/*.sh) chmod +x "$repo/.icm/$p" ;; esac
        actions+=("created .icm/$p")
      fi
    done
    for p in "${PIPELINE_CLAUDE[@]}"; do
      if [[ ! -f "$repo/.claude/$p" ]]; then
        mkdir -p "$(dirname "$repo/.claude/$p")"
        cp "$TEMPLATE/claude-pipeline/$p" "$repo/.claude/$p"
        actions+=("created .claude/$p")
      fi
    done
    for p in "${PIPELINE_GITHUB[@]}"; do
      if [[ ! -f "$repo/.github/$p" ]]; then
        mkdir -p "$repo/.github"
        cp "$TEMPLATE/github-pipeline/$p" "$repo/.github/$p"
        actions+=("created .github/$p")
      fi
    done
    fixed=$((fixed + 1)); repo_fixed=1
    missing=()
    # re-verify what we just created
    for p in .icm/CONTEXT.md .icm/intake/README.md .icm/intake/triage .icm/intake/_done .icm/docs .claude/settings.json; do
      [[ -e "$repo/$p" ]] || missing+=("$p (fix failed)")
    done
    for asset in "${assets[@]}"; do
      [[ -f "$repo/.claude/$asset" ]] || missing+=(".claude/$asset (fix failed)")
    done
    if (( migrated )); then
      [[ -f "$repo/CLAUDE.md" ]] || missing+=("CLAUDE.md (fix failed)")
      for asset in "${CANONICAL_ROOT[@]}"; do
        [[ -f "$repo/$asset" ]] || missing+=("$asset (fix failed)")
      done
    fi
    for p in "${PIPELINE_ICM[@]}" "${PIPELINE_PROJECT[@]}"; do [[ -f "$repo/.icm/$p" ]] || missing+=(".icm/$p (fix failed)"); done
    for p in "${PIPELINE_CLAUDE[@]}"; do [[ -f "$repo/.claude/$p" ]] || missing+=(".claude/$p (fix failed)"); done
    for p in "${PIPELINE_GITHUB[@]}"; do [[ -f "$repo/.github/$p" ]] || missing+=(".github/$p (fix failed)"); done
  fi

  # --- hook registration (D18) ---
  # A hook on disk is inert until settings.json names it, and 13 repos carried both
  # canonical hooks under a settings.json written before the `hooks` key existed. This
  # runs AFTER the seeding above so a hook created on this very pass is judged on the
  # state it leaves behind, not the state it arrived in.
  #
  # The merge is the one edit --fix makes to a file it did not create. Its discipline is
  # D7's, one level down: the template is read for the event and the entry, and the entry
  # is appended ONLY for a hook the repo's file does not already mention anywhere. No
  # value the repo already holds is changed — an entry it already names is never
  # rewritten, and its own extra hooks and permissions survive untouched. Both sides come
  # from the template rather than being hardcoded here, so adding a hook to
  # template/claude/settings.json is all it takes to have this register it.
  #
  # One caveat worth knowing before you run it: jq re-emits the whole document, so a repo
  # that hand-packs an array onto one line gets it reflowed. Content-identical, but a repo
  # whose CI format-checks .claude/ will notice. (2026-09-08: courseday, and only
  # courseday — every other file here is the template's own shape, which jq reproduces
  # byte-for-byte.)
  #
  # `vercel-env-hydrate.sh` is deliberately absent from the loop: it rides
  # session-start.sh, which invokes it, so registering that one registers both.
  if [[ -f "$repo/.claude/settings.json" ]]; then
    for hook in session-start.sh wrap-reminder.sh; do
      [[ -f "$repo/.claude/hooks/$hook" ]] || continue
      grep -q "$hook" "$repo/.claude/settings.json" 2>/dev/null && continue
      merged=0
      if (( FIX )) && [[ -n "$JQ" ]]; then
        # Which event does the template file this hook under, and under what entry?
        event="$("$JQ" -r --arg h "$hook" \
          '.hooks // {} | to_entries[]
             | select(any(.value[]?; any(.hooks[]?; .command // "" | contains($h))))
             | .key' "$TEMPLATE/claude/settings.json" 2>/dev/null | head -1)"
        if [[ -n "$event" ]]; then
          entry="$("$JQ" -c --arg h "$hook" --arg e "$event" \
            '.hooks[$e] | map(select(any(.hooks[]?; .command // "" | contains($h))))' \
            "$TEMPLATE/claude/settings.json" 2>/dev/null)"
          tmp="$repo/.claude/settings.json.icm-check.$$"
          if [[ -n "$entry" && "$entry" != "null" && "$entry" != "[]" ]] && \
             "$JQ" --arg e "$event" --argjson add "$entry" \
               '.hooks = ((.hooks // {}) | .[$e] = ((.[$e] // []) + $add))' \
               "$repo/.claude/settings.json" > "$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
            mv "$tmp" "$repo/.claude/settings.json"
            actions+=("registered .claude/hooks/$hook in settings.json (${event})")
            merged=1
          else
            rm -f "$tmp"
          fi
        fi
      fi
      if (( ! merged )); then
        why=""
        (( FIX )) && [[ -z "$JQ" ]] && why=" — jq not installed, so --fix could not merge it"
        warns+=("hook .claude/hooks/$hook exists but settings.json never registers it (inert)${why}")
      fi
    done
  fi
  # A repo whose only repair was the merge above is still a repo this pass fixed.
  if (( FIX )) && (( ! repo_fixed )) && (( ${#actions[@]} > 0 )); then
    fixed=$((fixed + 1)); repo_fixed=1
  fi

  # --- report ---
  # Every repo is a pipeline repo (D22); what is worth showing beside the name is the one thing
  # that still varies — a repo that has declared itself `micro` in its own project.json.
  label="$name"
  if [[ -n "$JQ" && -f "$repo/.icm/project.json" ]] && \
     [[ "$("$JQ" -r '.complexity // empty' "$repo/.icm/project.json" 2>/dev/null)" == "micro" ]]; then
    label="$name ${dim}(micro)${off}"
  fi
  if (( ${#missing[@]} == 0 && ${#warns[@]} == 0 && ${#actions[@]} == 0 )); then
    echo "${green}ok${off}   $label"
    conformant=$((conformant + 1))
  else
    if (( ${#missing[@]} > 0 )); then
      echo "${red}GAP${off}  ${bold}$label${off}"
      gaps=$((gaps + 1))
    else
      echo "${green}ok${off}   ${bold}$label${off}"
      conformant=$((conformant + 1))
    fi
    for a in "${actions[@]}"; do echo "       ${green}+${off} $a"; done
    for m in "${missing[@]}"; do echo "       ${red}missing${off} $m"; done
    for w in "${warns[@]}"; do echo "       ${yellow}warn${off} $w"; warnings=$((warnings + 1)); done
  fi
done

echo
echo "RESULT: $total repos checked, $conformant conformant, $gaps with gaps, $fixed fixed, $warnings warnings$( (( FIX )) || echo ' (check only — rerun with --fix to populate)')"
# Exit convention (decision D15, 2026-08-28): gaps exit 0 — conformance REPORTS, it does
# not repair, so a gap is the report's content, not the report failing. Only a bad
# invocation (2) is a failure. estate-conformance.sh follows the same convention.
exit 0

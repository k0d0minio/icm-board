#!/usr/bin/env bash
# project-labels.sh — project a run's labels onto its PR from spec.md (one direction: file → PR).
# Estate pipeline template (icm-board _system/template/icm-pipeline/scripts/), adapted from the
# sustentus reference implementation (its persona vocabulary removed — personas are that repo's
# spec header, not the template's).
#
# Replaces the conversational "build the label set and write it" step. The label set is a pure
# function of the spec header plus the stage, so a script can project it exactly — no "mostly". It
# reads the PR number from run.md and the complexity from spec.md, assembles the FULL label set,
# and PUTs it (the GitHub labels API replaces the whole set, which is what we want).
#
# Callers: the Define stage once, by hand after a spec revision, and CI on every push touching
# `.icm/runs/**` if the repo wires a labels job. Spine runs only — a lane run has no spec, so
# there is nothing to project.
#
# The label vocabulary is the repo's own. This script writes `type:feature`, `stage:<name>` and
# `complexity:<name>`; a repo that wants them coloured and described defines them (a
# `.github/labels.yml` is the usual shape). Nothing here creates or curates them.
#
# Config from the process environment (no .env loading):
#   GITHUB_TOKEN / GH_TOKEN  (one required)  GitHub token with repo scope.
#   GITHUB_REPO              (optional)      owner/repo; default: derived from `origin`.
#   GITHUB_API_URL           (optional)      API base. Default: https://api.github.com.
#
# Usage:
#   .icm/scripts/project-labels.sh <slug> --stage <define|build|release|auto> [--pr <n>]
#
#   --stage auto   derive the stage from which run outputs exist on disk (define → build →
#                  release), so an automated caller doesn't have to know the stage.
#   --pr <n>       use this PR number instead of reading it from run.md — for CI, where the PR
#                  number comes from the event and run.md's pointer may not be the one being
#                  labelled.
#
# Verdict (stdout, last line):
#   RESULT: APPLIED   exit 0  — the full label set was written to the PR (the set is echoed above).
set -euo pipefail

command -v curl >/dev/null || { echo "curl not found" >&2; exit 1; }
command -v jq   >/dev/null || { echo "jq not found"   >&2; exit 1; }

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

die() { echo "error: $*" >&2; exit 1; }

# --- args ------------------------------------------------------------------------------

slug=""; stage=""; pr_override=""
while [ $# -gt 0 ]; do
  case "$1" in
    --stage) stage="${2:-}"; shift 2 ;;
    --pr)    pr_override="${2:-}"; shift 2 ;;
    --*)     die "unknown flag: $1" ;;
    *)       [ -z "$slug" ] && slug="$1" || die "unexpected argument: $1"; shift ;;
  esac
done
[ -n "$slug" ]  || die "usage: project-labels.sh <slug> --stage <define|build|release|auto> [--pr <n>]"
[ -n "$stage" ] || die "--stage <define|build|release|auto> is required"

run_dir="$repo_root/.icm/runs/$slug"
spec="$run_dir/02_define/output/spec.md"
[ -f "$spec" ] || die "no spec at .icm/runs/$slug/02_define/output/spec.md — spine runs only (a lane run has no spec to project from)"

# --stage auto: derive the current stage from which run outputs exist on disk. Newest wins.
# Release writes no run-folder file of its own — it appends a `## Release` section to Build's
# notes.md, and that section is the signal.
if [ "$stage" = "auto" ]; then
  notes="$run_dir/03_build/output/notes.md"
  if [ -f "$notes" ] && grep -q '^## Release' "$notes"; then
    stage="release"
  elif [ -f "$notes" ]; then
    stage="build"
  else
    stage="define"
  fi
fi
case "$stage" in define|build|release) : ;; *) die "--stage must be define|build|release|auto, got: $stage" ;; esac

run_md="$run_dir/run.md"
if [ -z "$pr_override" ]; then
  [ -f "$run_md" ] || die "no run.md at $run_md — resolve the run first (resolve-run.sh), or pass --pr <n>"
fi

# --- config from env (repo derived from origin when unset) -----------------------------

GH_API="${GITHUB_API_URL:-https://api.github.com}"
repo="${GITHUB_REPO:-$(git -C "$repo_root" remote get-url origin 2>/dev/null \
  | sed -E 's#^(git@[^:]+:|https?://[^/]+/)##; s#\.git$##' || true)}"
[ -n "$repo" ] || die "GITHUB_REPO is not set and no origin remote to derive it from"
gh_token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
[ -n "$gh_token" ] || die "GITHUB_TOKEN (or GH_TOKEN) is not set — needed to write PR labels"

# --- PR number: explicit --pr wins, else read it from run.md ---------------------------

if [ -n "$pr_override" ]; then
  pr_number="$(printf '%s' "$pr_override" | grep -oE '[0-9]+' | head -n1 || true)"
  [ -n "$pr_number" ] || die "--pr must be a number, got: '$pr_override'"
else
  pr_number="$(grep -m1 '^- pr:' "$run_md" \
    | sed -E 's/^- pr:[[:space:]]*//; s/[[:space:]]+#.*$//' \
    | grep -oE '[0-9]+' | head -n1 || true)"
  [ -n "$pr_number" ] || die "could not read a PR number from $run_md ('- pr:' line)"
fi

# --- spec header → label set -----------------------------------------------------------

complexity="$(grep -m1 '^- complexity:' "$spec" | sed -E 's/^- complexity:[[:space:]]*//; s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')"
case "$complexity" in trivial|standard|complex) : ;; *) die "spec complexity must be trivial|standard|complex, found: '$complexity'" ;; esac

labels=("type:feature" "stage:${stage}" "complexity:${complexity}")

# --- write the full set (PUT replaces every label on the PR) ---------------------------

payload="$(printf '%s\n' "${labels[@]}" | jq -R . | jq -s '{labels: .}')"
echo "Projecting labels onto PR #$pr_number: ${labels[*]}" >&2

resp="$(curl -sS -m 30 -w $'\n%{http_code}' -X PUT \
  -H "Authorization: Bearer $gh_token" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "$GH_API/repos/${repo}/issues/${pr_number}/labels")" \
  || die "label write request failed (network/egress)"

http="$(printf '%s' "$resp" | tail -n1)"
body="$(printf '%s' "$resp" | sed '$d')"
if [ "$http" != "200" ]; then
  reason="$(printf '%s' "$body" | jq -r '.message // empty' 2>/dev/null || true)"
  die "label write returned HTTP $http — ${reason:-no message}"
fi

echo "RESULT: APPLIED"

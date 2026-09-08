#!/usr/bin/env bash
# new-run.sh — scaffold a pipeline run: commit it, open its PR, consume the stub.
# Estate pipeline template (icm-board _system/template/icm-pipeline/scripts/), adapted
# from the sustentus reference implementation. It does not project labels: that is
# `project-labels.sh`, called separately, so a repo without the label vocabulary still
# gets its run scaffolded.
#
# Two modes:
#   • Spine (default) — the mechanical half of Define (.icm/stages/02_define/CONTEXT.md).
#     Define writes spec.md and hands the one-line PR Summary in via --summary; this
#     script commits the run + pushes, opens the DRAFT PR with a body projected from
#     spec.md (both gate anchors + acceptance criteria mirrored unticked), writes/extends
#     run.md, and — if --stub was passed — git mv's the stub into its _done/.
#   • Lane (--lane bug|tweak|chore) — the fast-lane scaffold (.icm/lanes/*/CONTEXT.md).
#     No spec: opens a READY (non-draft) PR whose body carries ONLY the ready-to-merge
#     gate, and writes run.md with a `lane:` line.
#
# The PR body mirrors .github/pull_request_template.md — headings and gate anchors are
# kept verbatim because the pipeline parses them (see .icm/_shared/github.md). A missing
# spec-approved anchor on a lane PR is by design: a missing anchor means "not required".
#
# Config from the process environment (no .env loading):
#   GITHUB_TOKEN / GH_TOKEN  (one required)  GitHub token with repo scope.
#   GITHUB_REPO              (optional)      owner/repo; default: derived from `origin`.
#   GITHUB_API_URL           (optional)      API base. Default: https://api.github.com.
#
# Usage:
#   .icm/scripts/new-run.sh <slug> --summary "<one plain sentence>" \
#       [--stub .icm/intake/<epic>/<feature>.md] [--steps "<steps to test>"] [--base main] \
#       [--lane bug|tweak|chore] [--title "<PR title — lane mode, default: the slug>"]
#
#   With --lane, --stub may name a TRIAGE stub only (.icm/intake/triage/<name>.md);
#   epic stubs go through /pipeline new → Define.
#
# Verdict (stdout, last line):
#   RESULT: CREATED   exit 0  — run committed, PR opened, run.md written/extended,
#                              stub consumed (if given). The PR URL is echoed above.
set -euo pipefail

command -v curl >/dev/null || { echo "curl not found" >&2; exit 1; }
command -v jq   >/dev/null || { echo "jq not found"   >&2; exit 1; }
command -v git  >/dev/null || { echo "git not found"  >&2; exit 1; }

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

die() { echo "error: $*" >&2; exit 1; }

# --- args ------------------------------------------------------------------------------

slug=""; summary=""; stub=""; steps=""; base="main"; lane=""; title_flag=""
while [ $# -gt 0 ]; do
  case "$1" in
    --summary) summary="${2:-}"; shift 2 ;;
    --stub)    stub="${2:-}"; shift 2 ;;
    --steps)   steps="${2:-}"; shift 2 ;;
    --base)    base="${2:-}"; shift 2 ;;
    --lane)    lane="${2:-}"; shift 2 ;;
    --title)   title_flag="${2:-}"; shift 2 ;;
    --*)       die "unknown flag: $1" ;;
    *)         [ -z "$slug" ] && slug="$1" || die "unexpected argument: $1"; shift ;;
  esac
done
[ -n "$slug" ]    || die "usage: new-run.sh <slug> --summary \"<one sentence>\" [--stub <path>] [--lane bug|tweak|chore]"
[ -n "$summary" ] || die "--summary \"<one plain sentence>\" is required (the PR Summary — the one AI-authored line)"
case "$lane" in ""|bug|tweak|chore) : ;; *) die "--lane must be bug|tweak|chore, got: $lane" ;; esac
if [ -n "$lane" ] && [ -n "$stub" ]; then
  case "$stub" in
    *.icm/intake/triage/*|.icm/intake/triage/*) : ;;
    *) die "--lane consumes only triage stubs (.icm/intake/triage/*) — epic stubs go through /pipeline new" ;;
  esac
fi

run_dir="$repo_root/.icm/runs/$slug"
run_md="$run_dir/run.md"

spec=""
if [ -z "$lane" ]; then
  spec="$run_dir/02_define/output/spec.md"
  [ -f "$spec" ] || die "no spec at .icm/runs/$slug/02_define/output/spec.md — Define must write spec.md first"
fi

# Guard the "exactly one PR per run" rule.
if [ -f "$run_md" ] && grep -Eq '^- pr:[[:space:]]*#?[0-9]+' "$run_md"; then
  die "run.md already records a PR for '$slug' — use '/pipeline define $slug' to revise, not new-run.sh"
fi

# --- config from env (repo derived from origin when unset) -----------------------------

GH_API="${GITHUB_API_URL:-https://api.github.com}"
repo="${GITHUB_REPO:-$(git -C "$repo_root" remote get-url origin 2>/dev/null \
  | sed -E 's#^(git@[^:]+:|https?://[^/]+/)##; s#\.git$##' || true)}"
[ -n "$repo" ] || die "GITHUB_REPO is not set and no origin remote to derive it from"
gh_token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
[ -n "$gh_token" ] || die "GITHUB_TOKEN (or GH_TOKEN) is not set — needed to open the PR"

git_c() { git -C "$repo_root" "$@"; }

# Push with bounded exponential backoff — network blips shouldn't fail the scaffold.
git_push() {
  local delay=2 attempt
  for attempt in 1 2 3 4; do
    if git_c push -u origin "$1"; then return 0; fi
    [ "$attempt" -lt 4 ] || break
    echo "  push failed (attempt $attempt) — retrying in ${delay}s" >&2
    sleep "$delay"; delay=$((delay * 2))
  done
  die "git push of '$1' failed after retries"
}

# --- branch ----------------------------------------------------------------------------

branch="$(git_c rev-parse --abbrev-ref HEAD)"
if [ "$branch" = "main" ] || [ "$branch" = "master" ] || [ "$branch" = "HEAD" ]; then
  branch="claude/$slug"
  echo "on $base/detached — creating run branch $branch" >&2
  git_c checkout -b "$branch"
fi

# --- PR title + body -------------------------------------------------------------------

if [ -z "$lane" ]; then
  title="$(grep -m1 '^# ' "$spec" | sed -E 's/^#[[:space:]]+//; s/^Spec:[[:space:]]*//; s/[[:space:]]*$//')"
  [ -n "$title" ] || title="$slug"

  # Mirror the whole Acceptance criteria section body verbatim; only a bullet's leading
  # checkbox is reset to unticked (the PR tracks tick state; the text stays the spec's).
  criteria="$(awk '
    /^##[[:space:]]+Acceptance criteria[[:space:]]*$/ { grab=1; next }
    grab && /^##[[:space:]]/ { grab=0 }
    grab {
      if ($0 ~ /^[[:space:]]*-[[:space:]]+\[[ xX]\]/) sub(/\[[ xX]\]/, "[ ]")
      lines[++n] = $0
    }
    END {
      s = 1; while (s <= n && lines[s] ~ /^[[:space:]]*$/) s++
      e = n; while (e >= s && lines[e] ~ /^[[:space:]]*$/) e--
      for (i = s; i <= e; i++) print lines[i]
    }
  ' "$spec")"
  [ -n "$criteria" ] || die "no acceptance-criteria checkboxes found in $spec — run validate-spec.sh"

  [ -n "$steps" ] || steps=$'1. Run the app (or open the preview)\n2. Exercise each acceptance criterion above'

  spec_rel="${spec#"$repo_root/"}"
  # Branch link so the spec is readable while the PR is open; Release repoints it to
  # blob/main right after the squash-merge.
  spec_link="https://github.com/${repo}/blob/${branch}/${spec_rel}"

  body="$(cat <<EOF
<!-- PIPELINE RUN — do not delete the markers; the pipeline reads them. -->

## Summary

${summary}

## Spec

- slug: ${slug}
- Full spec (canonical — read here): ${spec_link}

## Acceptance criteria

<!-- text mirrored from spec.md — edit the spec, not these lines; the PR tracks tick state only -->

${criteria}

## Steps to test

${steps}

## Pipeline checklist

<!-- gate:spec-approved -->

- [ ] Spec approved (Define gate — a human ticks this before Build)

<!-- gate:ready-to-merge -->

- [ ] Ready to merge (Release gate — a human ticks this to authorise the squash-merge; ticking it attests your own testing of the change)
EOF
)"
  draft=true
else
  title="${title_flag:-$slug}"
  [ -n "$steps" ] || steps=$'1. Run the app (or open the preview)\n2. Confirm the change described above'

  body="$(cat <<EOF
<!-- PIPELINE RUN (lane: ${lane}) — do not delete the markers; the pipeline reads them. -->

## Summary

${summary}

## Steps to test

${steps}

## Pipeline checklist

<!-- gate:ready-to-merge -->

- [ ] Ready to merge (lane gate — a human ticks this to authorise the squash-merge)
EOF
)"
  draft=false
fi

# --- commit the run (+ consume the stub) + push ----------------------------------------
# The stub is retired BEFORE the PR opens: if anything here fails, no PR exists yet and
# the run is cleanly re-runnable.

if [ -z "$lane" ]; then
  commit_msg="feat: $slug — define spec"
else
  commit_msg="chore: $slug — open $lane lane"
fi
git_c add ".icm/runs/$slug/"
if git_c diff --cached --quiet; then
  echo "run files already committed" >&2
else
  git_c commit -m "$commit_msg" >/dev/null
fi

if [ -n "$stub" ]; then
  stub_path="$stub"
  [ -f "$stub_path" ] || stub_path="$repo_root/$stub"
  [ -f "$stub_path" ] || die "--stub given but no file at: $stub"
  stub_dir="$(dirname "$stub_path")"
  done_dir="$stub_dir/_done"
  mkdir -p "$done_dir"
  feature_slug="$(basename "$stub_path" .md)"
  git_c mv "$stub_path" "$done_dir/$(basename "$stub_path")"
  git_c commit -m "chore: mark $feature_slug stub spun out" >/dev/null
  echo "marked stub consumed: $stub → $done_dir/" >&2
fi

git_push "$branch"

# --- open the PR -----------------------------------------------------------------------

payload="$(jq -n --arg title "$title" --arg head "$branch" --arg base "$base" --arg body "$body" \
  --argjson draft "$draft" '{title: $title, head: $head, base: $base, draft: $draft, body: $body}')"

resp="$(curl -sS -m 30 -w $'\n%{http_code}' -X POST \
  -H "Authorization: Bearer $gh_token" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "$GH_API/repos/${repo}/pulls")" \
  || die "PR create request failed (network/egress)"

http="$(printf '%s' "$resp" | tail -n1)"
pr_body="$(printf '%s' "$resp" | sed '$d')"
if [ "$http" != "201" ]; then
  reason="$(printf '%s' "$pr_body" | jq -r '.errors[0].message // .message // empty' 2>/dev/null || true)"
  die "PR create returned HTTP $http — ${reason:-no message}"
fi
pr_number="$(printf '%s' "$pr_body" | jq -r '.number')"
pr_url="$(printf '%s' "$pr_body" | jq -r '.html_url')"
[ -n "$pr_number" ] && [ "$pr_number" != "null" ] || die "PR create returned no number"

# --- write / extend run.md (stub + branch + pr pointers), commit, push -----------------

mkdir -p "$run_dir"
if [ ! -f "$run_md" ]; then
  {
    echo "# Run: $slug"
    echo
    [ -n "$lane" ] && echo "- lane: $lane"
  } > "$run_md"
fi
if [ -n "$stub" ]; then
  stub_rel="${stub#"$repo_root/"}"; stub_rel="${stub_rel#.icm/}"
  grep -Eq '^- stub:' "$run_md" || echo "- stub: ${stub_rel}" >> "$run_md"
fi
grep -Eq '^- branch:' "$run_md" || echo "- branch: $branch" >> "$run_md"
grep -Eq '^- pr:'     "$run_md" || echo "- pr: #$pr_number" >> "$run_md"
git_c add ".icm/runs/$slug/run.md"
git_c diff --cached --quiet || git_c commit -m "chore: $slug — run pointers (branch + PR)" >/dev/null
git_push "$branch"

# --- verdict ---------------------------------------------------------------------------

echo "run '$slug' created — branch: $branch, ${lane:+$lane lane }PR: $pr_url"
echo "RESULT: CREATED"

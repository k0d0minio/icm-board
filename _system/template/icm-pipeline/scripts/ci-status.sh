#!/usr/bin/env bash
# ci-status.sh — wait for a run's CI to settle, then print one verdict: GREEN, RED or PENDING.
# Estate pipeline template (icm-board _system/template/icm-pipeline/scripts/), adapted
# from the sustentus reference implementation.
#
# The deterministic answer to "is this PR green?" (.icm/_shared/ci.md). It reads BOTH
# surfaces a commit's health lives on — GitHub Actions check runs AND commit statuses
# (deploy providers land there) — discards the known noise, and blocks until the run
# settles, so a stage can genuinely wait without spending model turns on a
# sleep-and-re-read loop. Requires curl + jq.
#
# What it filters, and why (rationale in .icm/_shared/ci.md):
#   * "Vercel Preview Comments" is a zero-second always-success marker — ignored.
#   * A status reading "Canceled by Ignored Build Step" is a SKIPPED deploy, not a pass.
#   * Check runs whose name ends "(advisory)" are reported but never make the verdict RED.
#   * A required check that has not appeared yet is PENDING, never GREEN. With no
#     required checks configured, ZERO signals on the head is also PENDING — an empty
#     check list on a fresh push is CI not having started, not CI having passed.
#
# Config from the process environment (no .env loading):
#   GITHUB_TOKEN / GH_TOKEN     (one required)
#   GITHUB_REPO                 (optional)  owner/repo; default: derived from `origin`.
#   GITHUB_API_URL              (optional)  API base. Default: https://api.github.com.
#   PIPELINE_REQUIRED_CHECKS    (optional)  Newline/comma-separated check-run names that
#                                           must be present and completed before GREEN.
#                                           Set this to the repo's own CI check names.
#
# Usage:
#   .icm/scripts/ci-status.sh <slug> [--timeout <seconds>] [--interval <seconds>] [--no-wait]
#   .icm/scripts/ci-status.sh --pr <number> [...]
#
# Verdict (stdout, last line):
#   RESULT: GREEN    exit 0  — every blocking check and status completed, none failed.
#   RESULT: RED      exit 3  — something blocking failed. STOP: read logs, fix, push, re-run.
#   RESULT: PENDING  exit 4  — unsettled (or required checks never registered). Not a pass.
set -euo pipefail

command -v curl >/dev/null || { echo "curl not found" >&2; exit 1; }
command -v jq   >/dev/null || { echo "jq not found"   >&2; exit 1; }

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

die() { echo "error: $*" >&2; exit 1; }

# --- args ------------------------------------------------------------------------------

slug=""; pr_number=""; timeout=900; interval=20; wait=1
while [ $# -gt 0 ]; do
  case "$1" in
    --pr)       pr_number="${2:-}"; shift 2 ;;
    --timeout)  timeout="${2:-}";   shift 2 ;;
    --interval) interval="${2:-}";  shift 2 ;;
    --no-wait)  wait=0;             shift   ;;
    --*)        die "unknown flag: $1" ;;
    *)          [ -z "$slug" ] && slug="$1" || die "unexpected argument: $1"; shift ;;
  esac
done
[ -n "$slug" ] || [ -n "$pr_number" ] || die "usage: ci-status.sh <slug> | --pr <number> [--timeout s] [--interval s] [--no-wait]"

case "$timeout"  in ''|*[!0-9]*) die "--timeout must be a whole number of seconds" ;; esac
case "$interval" in ''|*[!0-9]*) die "--interval must be a whole number of seconds" ;; esac
[ "$interval" -ge 5 ] || die "--interval must be at least 5 seconds — don't hammer the API"

# --- config from env (repo derived from origin when unset) -----------------------------

GH_API="${GITHUB_API_URL:-https://api.github.com}"
repo="${GITHUB_REPO:-$(git -C "$repo_root" remote get-url origin 2>/dev/null \
  | sed -E 's#^(git@[^:]+:|https?://[^/]+/)##; s#\.git$##' || true)}"
[ -n "$repo" ] || die "GITHUB_REPO is not set and no origin remote to derive it from"
gh_token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
[ -n "$gh_token" ] || die "GITHUB_TOKEN (or GH_TOKEN) is not set — needed to read the PR's checks"

required_raw="${PIPELINE_REQUIRED_CHECKS:-}"
required_checks="$(printf '%s' "$required_raw" | tr ',' '\n' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | grep -v '^$' || true)"

gh_get() {
  curl -sS -m 30 -w $'\n%{http_code}' \
    -H "Authorization: Bearer $gh_token" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$GH_API$1"
}

api() { # api <path> <what> -> body on stdout, dies on non-200
  local resp http body
  resp="$(gh_get "$1")" || die "GitHub request failed for $2 (network/egress)"
  http="$(printf '%s' "$resp" | tail -n1)"
  body="$(printf '%s' "$resp" | sed '$d')"
  [ "$http" = "200" ] || die "reading $2 returned HTTP $http: $(printf '%s' "$body" | jq -r '.message // empty' 2>/dev/null)"
  printf '%s' "$body"
}

# --- resolve the PR ---------------------------------------------------------------------

if [ -z "$pr_number" ]; then
  run_md="$repo_root/.icm/runs/$slug/run.md"
  [ -f "$run_md" ] || die "no .icm/runs/$slug/run.md in the working tree — run resolve-run.sh $slug first, or pass --pr <number>"
  pr_number="$(grep -m1 '^- pr:' "$run_md" \
    | sed -E 's/^- pr:[[:space:]]*//; s/[[:space:]]+#.*$//; s#^.*/pull/##; s/^#//; s/[^0-9].*$//' || true)"
  [ -n "$pr_number" ] || die "run.md for '$slug' has no usable '- pr:' line — the PR isn't open yet (or pass --pr <number>)"
fi
case "$pr_number" in ''|*[!0-9]*) die "PR number must be numeric, got: $pr_number" ;; esac

pr_json="$(api "/repos/${repo}/pulls/${pr_number}" "PR #$pr_number")"
head_sha="$(printf '%s' "$pr_json" | jq -r '.head.sha // empty')"
pr_state="$(printf '%s' "$pr_json" | jq -r '.state // empty')"
pr_merged="$(printf '%s' "$pr_json" | jq -r '.merged // false')"
[ -n "$head_sha" ] || die "PR #$pr_number has no head SHA"

echo "PR #$pr_number (${pr_state}${pr_merged:+, merged: $pr_merged}) — head ${head_sha:0:7}" >&2

# --- one read of both surfaces ----------------------------------------------------------
# Emits one TSV line per meaningful signal:  <class>\t<state>\t<name>\t<detail>
# class:  blocking | advisory | skipped | noise
# state:  pass | fail | pending
read_signals() {
  local checks statuses
  checks="$(api "/repos/${repo}/commits/${head_sha}/check-runs?per_page=100" "check runs for ${head_sha:0:7}")"
  statuses="$(api "/repos/${repo}/commits/${head_sha}/status?per_page=100" "commit statuses for ${head_sha:0:7}")"

  # Dedupe by check name, newest attempt wins — reading a stale attempt is how a green
  # PR reports RED forever.
  printf '%s' "$checks" | jq -r '
    (.check_runs // [])
    | group_by(.name) | map(sort_by(.started_at, .id) | last)[]
    | . as $c
    | (if   ($c.name | test("Vercel Preview Comments")) then "noise"
       elif ($c.name | test("\\(advisory\\)$"))         then "advisory"
       else "blocking" end) as $class
    | (if   $c.status != "completed"                    then "pending"
       elif ($c.conclusion // "") | IN("success","neutral","skipped") then "pass"
       else "fail" end) as $state
    | [$class, $state, $c.name, ($c.details_url // "")] | @tsv
  '

  # Deploy providers land here, not in check runs. "Canceled by Ignored Build Step" is a
  # project skipped for this diff — neither a pass nor a failure.
  printf '%s' "$statuses" | jq -r '
    (.statuses // [])
    | group_by(.context) | map(max_by(.created_at))[]   # newest status per context wins
    | . as $s
    | (if ($s.description // "") | test("Ignored Build Step") then "skipped" else "blocking" end) as $class
    | (if   $class == "skipped"                  then "skipped"
       elif $s.state == "pending"                then "pending"
       elif $s.state == "success"                then "pass"
       else "fail" end) as $state
    | [$class, $state, $s.context, ($s.target_url // "")] | @tsv
  '
}

# --- wait for the run to settle ---------------------------------------------------------

deadline=$(( SECONDS + timeout ))
verdict=""
signals=""

while :; do
  # Re-read the head each pass: a push landing mid-wait moves the SHA.
  latest_sha="$(printf '%s' "$(api "/repos/${repo}/pulls/${pr_number}" "PR #$pr_number")" | jq -r '.head.sha // empty')"
  if [ -n "$latest_sha" ] && [ "$latest_sha" != "$head_sha" ]; then
    echo "head moved ${head_sha:0:7} → ${latest_sha:0:7} — a new push restarts the wait" >&2
    head_sha="$latest_sha"
  fi

  signals="$(read_signals)"

  blocking_any="$(printf '%s\n' "$signals" | awk -F'\t' '$1=="blocking"'                 || true)"
  blocking_fail="$(printf '%s\n' "$signals" | awk -F'\t' '$1=="blocking" && $2=="fail"'   || true)"
  blocking_wait="$(printf '%s\n' "$signals" | awk -F'\t' '$1=="blocking" && $2=="pending"' || true)"

  # Required checks that have not registered (or registered but are pending) keep the
  # run PENDING; with none configured, zero blocking signals at all is also PENDING.
  missing_required=""
  if [ -n "$required_checks" ]; then
    while IFS= read -r req; do
      [ -n "$req" ] || continue
      printf '%s\n' "$signals" | awk -F'\t' -v r="$req" '$3==r && $2!="pending"' | grep -q . \
        || missing_required="${missing_required:+$missing_required, }$req"
    done <<< "$required_checks"
  elif [ -z "$blocking_any" ]; then
    missing_required="(no CI signals on this head yet)"
  fi

  if [ -n "$blocking_fail" ]; then
    verdict="RED"; break                       # a failure is final — later checks cannot un-fail it
  elif [ -z "$blocking_wait" ] && [ -z "$missing_required" ]; then
    verdict="GREEN"; break
  fi

  if [ "$wait" -eq 0 ] || [ "$SECONDS" -ge "$deadline" ]; then
    verdict="PENDING"; break
  fi

  waiting_on="$(printf '%s\n' "$blocking_wait" | awk -F'\t' 'NF{print $3}' | paste -sd', ' - || true)"
  echo "waiting ${interval}s — unsettled: ${waiting_on:-none}${missing_required:+; not yet registered: $missing_required}" >&2
  sleep "$interval"
done

# --- report -----------------------------------------------------------------------------

emit() { # emit <heading> <awk-filter>
  local rows; rows="$(printf '%s\n' "$signals" | awk -F'\t' "$2" || true)"
  [ -n "$rows" ] || return 0
  echo "$1" >&2
  printf '%s\n' "$rows" | awk -F'\t' 'NF{printf "  %-9s %s%s\n", $2, $3, ($4=="" ? "" : "  " $4)}' >&2
}

emit "Blocking:" '$1=="blocking"'
emit "Advisory (never blocks a merge):" '$1=="advisory"'
emit "Deploys skipped for this diff (no preview — not a pass):" '$1=="skipped"'

case "$verdict" in
  GREEN)
    echo "every blocking check and status completed without failure"
    echo "RESULT: GREEN"; exit 0 ;;
  RED)
    echo "failing: $(printf '%s\n' "$blocking_fail" | awk -F'\t' 'NF{print $3}' | paste -sd', ' -)" >&2
    echo "read the failing job's logs, fix on the branch, push, then re-run this call"
    echo "RESULT: RED"; exit 3 ;;
  *)
    if [ "$wait" -eq 0 ]; then
      echo "run is unsettled${missing_required:+ (never registered: $missing_required)} and --no-wait was passed — this is NOT a pass" >&2
    else
      echo "still unsettled after ${timeout}s${missing_required:+ (never registered: $missing_required)} — this is NOT a pass" >&2
    fi
    echo "RESULT: PENDING"; exit 4 ;;
esac

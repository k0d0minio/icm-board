#!/usr/bin/env bash
# close-out.sh — move the work to done: archive the run, and the epic if this stub finished it.
# Estate pipeline template (icm-board _system/template/icm-pipeline/scripts/), adapted from the
# sustentus reference implementation (which archives into its docs app; here the archive is the
# estate's own `_done/` convention — contracts/TICKETS.md).
#
# RUN BY THE RELEASE STAGE, ON THE RUN'S OWN BRANCH, BEFORE THE MERGE. The archive move rides in
# the run's own PR, so the squash-merge is what publishes it. Nothing is pushed to `main` here and
# nothing runs after the merge.
#
# Why before the merge and not after: a close-out that pushes straight to `main` cannot succeed on
# a branch protected by required status checks — no direct push carries them — and the archive
# commit strands on a branch nobody merges, leaving every shipped run still sitting in
# `.icm/runs/`. Moving the archive into the PR removes the second commit and the whole class of
# problem: no push to a protected branch, no bypass, no token, no fallback PR.
#
# The objection to this shape is that "a run folder moved before the squash is a claim about a
# merge that hasn't happened". It isn't: the move reaches `main` only if the PR merges, and if the
# PR never merges the move never happened.
#
# What it does, in order:
#   1. Refuses to run on `main` — this commits to the run's branch, and only there.
#   2. Establishes the run may be closed out:
#        - its PR is OPEN            → the normal path: this run is about to merge.
#        - its PR is already MERGED  → recovery for a run that merged without its archive; the
#                                      move is committed here for a sweep PR to carry.
#        - its PR is CLOSED unmerged → STOP. An abandoned run is not history.
#        - no `- pr:` line at all    → a FRONT (Scope + approve, which open no PR). Its epic
#                                      stands in for a merge: it archives once
#                                      `.icm/intake/<slug>/` has moved to `.icm/intake/_done/`,
#                                      and is refused while that epic is still live.
#   3. Moves .icm/runs/<slug>/ -> .icm/runs/_done/<slug>/.
#   4. If the run came from an intake stub, and that epic now has no active stubs left AND every
#      one of its OTHER spun-out runs has merged, moves .icm/intake/<epic>/ ->
#      .icm/intake/_done/<epic>/ — and with it the front run .icm/runs/<epic>/ that cut the epic,
#      if one is still here, in the same commit. This run is excluded from that sibling test
#      because it is the one merging now. `_done/` alone is not the signal: it means spun out,
#      not shipped, which is why each sibling's PR is checked.
#      .icm/intake/triage/ is exempt: it is a permanent backlog, never an epic to archive.
#   5. Commits the move on the current branch.
#
# It is idempotent: a run already archived is reported and skipped, so a re-run after a partial
# close-out finishes the job rather than doubling it.
#
# Config from the process environment (no .env loading):
#   GITHUB_TOKEN / GH_TOKEN  (one required)  GitHub token with repo scope — reads this run's PR
#                                            state and each sibling's.
#   GITHUB_REPO              (optional)      owner/repo; default: derived from `origin`.
#   GITHUB_API_URL           (optional)      API base. Default: https://api.github.com.
#
# Usage:
#   .icm/scripts/close-out.sh <slug> [--dry-run]
#
# Verdict (stdout, last line):
#   RESULT: CLOSED    exit 0  — the run (and the epic, if finished) are archived in a commit on
#                               this branch. Push it; the merge publishes it.
#   RESULT: STOP      exit 3  — nothing was moved, and the reason is on stderr: the PR was closed
#                               unmerged, or a front's epic is still live.
set -euo pipefail

command -v curl >/dev/null || { echo "curl not found" >&2; exit 1; }
command -v jq   >/dev/null || { echo "jq not found"   >&2; exit 1; }
command -v git  >/dev/null || { echo "git not found"  >&2; exit 1; }

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

die()  { echo "error: $*" >&2; exit 1; }
stop() { echo "$*" >&2; echo "RESULT: STOP"; exit 3; }

# --- args ------------------------------------------------------------------------------

slug=""; dry_run=0
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --*)       die "unknown flag: $1" ;;
    *)         [ -z "$slug" ] && slug="$1" || die "unexpected argument: $1"; shift ;;
  esac
done
[ -n "$slug" ] || die "usage: close-out.sh <slug> [--dry-run]"

# --- config from env (repo derived from origin when unset) -----------------------------

GH_API="${GITHUB_API_URL:-https://api.github.com}"
repo="${GITHUB_REPO:-$(git -C "$repo_root" remote get-url origin 2>/dev/null \
  | sed -E 's#^(git@[^:]+:|https?://[^/]+/)##; s#\.git$##' || true)}"
[ -n "$repo" ] || die "GITHUB_REPO is not set and no origin remote to derive it from"
gh_token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
[ -n "$gh_token" ] || die "GITHUB_TOKEN (or GH_TOKEN) is not set — needed to read the PR's state"

gh_get() {
  curl -sS -m 30 -w $'\n%{http_code}' \
    -H "Authorization: Bearer $gh_token" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$GH_API$1"
}

run_dir="$repo_root/.icm/runs/$slug"
runs_archive="$repo_root/.icm/runs/_done"
intake_archive="$repo_root/.icm/intake/_done"

# The `- pr:` line carries anything from "#456" to a full URL with a trailing "# comment".
pr_from_run_md() {
  grep -m1 '^- pr:' "$1" 2>/dev/null \
    | sed -E 's/^- pr:[[:space:]]*//; s/[[:space:]]+#.*$//; s#^.*/pull/##; s/^#//; s/[^0-9].*$//'
}

# A front run (Scope + approve only) never opens a PR of its own — the front pushes straight to
# main — so a run.md with no usable `- pr:` line is the whole test for one.
front_only() {
  [ -f "$1" ] || return 1
  [ -z "$(pr_from_run_md "$1")" ]
}

# Echoes "merged" / "open" / "closed"; empty when the PR could not be read at all.
pr_status() {
  local n="$1" resp http body
  case "$n" in ''|*[!0-9]*) echo ""; return 0 ;; esac
  resp="$(gh_get "/repos/${repo}/pulls/${n}")" || { echo ""; return 0; }
  http="$(printf '%s' "$resp" | tail -n1)"
  body="$(printf '%s' "$resp" | sed '$d')"
  [ "$http" = "200" ] || { echo ""; return 0; }
  printf '%s' "$body" | jq -r 'if .merged then "merged" else .state end'
}

# --- 1. this commits to the run's branch, and only there -------------------------------

branch="$(git symbolic-ref --quiet --short HEAD || echo '')"
if [ "$dry_run" = "0" ] && { [ "$branch" = "main" ] || [ "$branch" = "master" ] || [ -z "$branch" ]; }; then
  die "close-out commits to the run's own branch (currently: ${branch:-detached HEAD}). The archive rides in the run's PR — it is never pushed to main."
fi

# --- 2. the run must be closable -------------------------------------------------------

if [ ! -d "$run_dir" ]; then
  if [ -d "$runs_archive/$slug" ]; then
    echo "run '$slug' is already archived — nothing to move" >&2
    echo "RESULT: CLOSED"; exit 0
  fi
  die "no .icm/runs/$slug/ and no archive entry for it — wrong slug?"
fi

pr_number="$(pr_from_run_md "$run_dir/run.md" || true)"

front_close=0
if [ -z "$pr_number" ]; then
  # No PR to check, so this is a front. Its work left the front as an intake epic under the same
  # slug, and that epic's own archival is the record that every stub it cut has shipped — which
  # makes the archived epic the front's merge, and the only signal there is.
  if [ -d "$intake_archive/$slug" ]; then
    front_close=1
    echo "front-only run '$slug' — its epic is archived, so the front is history too" >&2
  elif [ -d "$repo_root/.icm/intake/$slug" ]; then
    stop "'$slug' is a front-only run and its epic .icm/intake/$slug/ is still live — the front stays until the epic is archived with it."
  else
    stop "run.md for '$slug' has no usable '- pr:' line and there is no '$slug' epic in .icm/intake/ or .icm/intake/_done/ — nothing here says this run is finished."
  fi
else
  status="$(pr_status "$pr_number")"
  [ -n "$status" ] || die "could not read PR #$pr_number — close-out needs its state, and must not guess"
  case "$status" in
    open)
      echo "PR #$pr_number is open — archiving on '$branch' so the squash-merge publishes it" >&2 ;;
    merged)
      # A run that merged before its archive rode along: a Release that skipped this step. The
      # move still belongs in a PR — a sweep branch, this time.
      echo "PR #$pr_number already merged — archiving late; carry this commit in a sweep PR" >&2 ;;
    closed)
      stop "PR #$pr_number for '$slug' was closed without merging. An abandoned run is not history — delete the folder deliberately or reopen the PR." ;;
    *)
      die "unexpected state '$status' for PR #$pr_number" ;;
  esac
fi

# --- 3. archive the run ----------------------------------------------------------------

moved_run=0
if [ -d ".icm/runs/$slug" ]; then
  [ -d ".icm/runs/_done/$slug" ] && die ".icm/runs/_done/$slug already exists — resolve by hand"
  mkdir -p ".icm/runs/_done"
  if [ "$dry_run" = "1" ]; then
    echo "[dry-run] would move .icm/runs/$slug/ → .icm/runs/_done/$slug/" >&2
  else
    git mv ".icm/runs/$slug" ".icm/runs/_done/$slug" || die "could not archive the run folder"
    echo "archived run: .icm/runs/$slug/ → .icm/runs/_done/$slug/" >&2
  fi
  moved_run=1
else
  echo "run '$slug' already archived on this branch — skipping" >&2
fi

# --- 4. archive the epic, if this stub finished it -------------------------------------

epic=""
moved_epic=0
moved_front=0
epic_note="no intake epic behind this run"

if [ "$front_close" = "1" ]; then
  # The front IS the epic's other half — and the epic went first, which is why we are here.
  epic_note="'$slug' is the front for the already-archived '$slug' epic"
else
  for d in .icm/intake/*/; do
    # triage/ is the permanent parking lane, not an epic — a lane run spun out of one of its
    # stubs must never cause the folder to be archived, however empty it gets. _done/ is the
    # archive itself.
    case "$(basename "$d")" in triage|_done) continue ;; esac
    [ -e "$d/_done/$slug.md" ] && { epic="$(basename "$d")"; break; }
  done
fi

if [ -n "$epic" ]; then
  active="$(find ".icm/intake/$epic" -maxdepth 1 -name '*.md' ! -name 'breakdown.md' | wc -l | tr -d ' ')"
  if [ "$active" != "0" ]; then
    epic_note="epic '$epic' has $active stub(s) still to spin out — left in place"
  else
    unmerged=""
    for stub in ".icm/intake/$epic/_done/"*.md; do
      [ -e "$stub" ] || continue
      sib="$(basename "$stub" .md)"
      # This run is the one merging now — it is why the epic can finish, so it is not a sibling
      # the epic waits on. (Its folder has just moved to the archive anyway.)
      [ "$sib" = "$slug" ] && continue
      sib_run_md=""
      [ -f ".icm/runs/$sib/run.md" ] && sib_run_md=".icm/runs/$sib/run.md"
      [ -z "$sib_run_md" ] && [ -f ".icm/runs/_done/$sib/run.md" ] \
        && sib_run_md=".icm/runs/_done/$sib/run.md"
      if [ -z "$sib_run_md" ]; then
        unmerged="${unmerged:+$unmerged, }$sib (no run folder)"; continue
      fi
      sib_pr="$(pr_from_run_md "$sib_run_md" || true)"
      [ "$(pr_status "$sib_pr")" = "merged" ] || unmerged="${unmerged:+$unmerged, }$sib"
    done
    if [ -n "$unmerged" ]; then
      epic_note="epic '$epic' is fully spun out but not fully shipped — waiting on: $unmerged"
    else
      [ -d ".icm/intake/_done/$epic" ] && die ".icm/intake/_done/$epic already exists — resolve by hand"
      mkdir -p ".icm/intake/_done"
      if [ "$dry_run" = "1" ]; then
        echo "[dry-run] would move .icm/intake/$epic/ → .icm/intake/_done/$epic/" >&2
      else
        git mv ".icm/intake/$epic" ".icm/intake/_done/$epic" || die "could not archive the intake epic"
      fi
      moved_epic=1
      epic_note="epic '$epic' shipped in full — archived"

      # The front that cut this epic carries the same slug and never opened a PR of its own, so
      # nothing else will ever move it. It is finished history the moment the epic is: it rides
      # along in this commit. A run folder at that slug WITH a PR is a spine run, not a front —
      # left alone, for rule 2 to close out on its own Release.
      if [ -d ".icm/runs/$epic" ] && front_only ".icm/runs/$epic/run.md"; then
        [ -d ".icm/runs/_done/$epic" ] && die ".icm/runs/_done/$epic already exists — resolve by hand"
        mkdir -p ".icm/runs/_done"
        if [ "$dry_run" = "1" ]; then
          echo "[dry-run] would move the front .icm/runs/$epic/ → .icm/runs/_done/$epic/" >&2
        else
          git mv ".icm/runs/$epic" ".icm/runs/_done/$epic" \
            || die "could not archive the front run behind the epic"
          echo "archived front run: .icm/runs/$epic/ → .icm/runs/_done/$epic/" >&2
        fi
        moved_front=1
      fi
    fi
  fi
fi
echo "$epic_note" >&2

# --- 5. commit on this branch ----------------------------------------------------------

if [ "$dry_run" = "1" ]; then
  echo "[dry-run] nothing committed"
  echo "RESULT: CLOSED"; exit 0
fi

if [ "$moved_run" = "0" ] && [ "$moved_epic" = "0" ] && [ "$moved_front" = "0" ]; then
  echo "nothing left to archive for '$slug'"
  echo "RESULT: CLOSED"; exit 0
fi

msg="Wrap: close out $slug — archive the shipped run"
[ "$front_close" = "1" ] && msg="Wrap: close out $slug — archive the front behind the archived epic"
[ "$moved_epic" = "1" ] && msg="$msg and the completed $epic epic"
[ "$moved_front" = "1" ] && msg="$msg (front included)"

git commit -q -m "$msg" || die "nothing staged to commit — the git mv did not take"

echo "committed on '$branch': $msg"
echo "RESULT: CLOSED"; exit 0

#!/usr/bin/env bash
# ticket-hygiene.sh — report ticket drift across the estate (read-only, never fixes).
#
# For every repo with .icm/intake/ (sustentus included — decision D44), reports:
#
#   board drift
#     possibly-done      open stub whose slug (or a legacy ticket's ID) appears in a
#                        commit that changed something outside .icm/ — the work, not the
#                        ticket admin. Reports the commit, so /day judges in one line.
#     off-ticket         repo committed to in the last 14 days but has zero open tickets
#     legacy-unmigrated  flat PREFIX-NNN tickets still awaiting a /project re-cut
#
#   run drift (pipeline repos — .icm/runs/, the live runs; `_`-prefixed archives skipped)
#     run-unclosed       a live run whose work is over — the case close-out.sh archives late:
#                        its `- pr:` merge is on main (a Release that merged without its
#                        close-out), or it is a front (no PR) whose epic is already in the
#                        intake archive. The fix is close-out.sh on a branch, merged by its
#                        own PR — it refuses main, so nothing here can be a direct commit.
#     run-unsettled      a live run close-out.sh would STOP on: its PR is not merged on main,
#                        or it is a front with no epic live or archived. A human decides.
#
#   contract lint (contracts/TICKETS.md) — per epic / stub:
#     no-breakdown       an epic with stubs but no breakdown.md
#     slug-mismatch      '- feature-slug:' disagreeing with the filename
#     no-sequence        a stub without '- sequence: <n> of <m>'
#     no-lane            a triage stub without '- lane: bug|tweak|chore'
#     no-prompt          a stub without '## Prompt' in a repo that has no /pipeline
#                        (the board's pick-up depends on it)
#
#   today.md (this repo's .icm/today.md — the one home of the today flag)
#     today-unresolved   an entry pointing at a stub that is done, archived or missing
#     today-dilution     more than 10 entries (spec cap, estate-wide)
#     stale-today        the file predates yesterday — a plan from a past day
#
# Where it reads: a client repo at `origin/main` — the one home of its ticket state (D39 §8;
# lib/ticket-base.sh) — intake, dormant flag and log alike. Never the shared `projects/<repo>`
# checkout; no ref → the working tree, said on stderr. icm-board reads its own disk and HEAD.
#
# Dormancy: a repo carrying an empty `.icm/dormant` file is parked — `off-ticket` is
# silenced for it; every other check still runs.
#
# Fixing is judgment work — the /day command applies fixes, this script never does.
#
# Usage: _system/scripts/ticket-hygiene.sh [root]
# Exit:  0 clean · 1 findings · 2 bad invocation

set -uo pipefail

APPS_ROOT="${1:-}"
[[ -n "$APPS_ROOT" ]] || APPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
[[ -d "$APPS_ROOT" ]] || { echo "Not a directory: $APPS_ROOT" >&2; exit 2; }

# shellcheck source=lib/ticket-base.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib/ticket-base.sh"
TB_TMP="$(mktemp -d)"; trap 'rm -rf "$TB_TMP"' EXIT

bold=$'\033[1m'; yellow=$'\033[33m'; green=$'\033[32m'; dim=$'\033[2m'; off=$'\033[0m'
[[ -t 1 ]] || { bold=; yellow=; green=; dim=; off=; }

mapfile -t repos < <(
  find "$APPS_ROOT" -mindepth 2 -maxdepth 3 -name .git \
    \( -type d -o -type f \) \
    -not -path '*/node_modules/*' \
    -not -path '*/.*/.*/.git' \
    -printf '%h\n' | sort
)
[[ -e "$APPS_ROOT/.git" ]] && repos=("$APPS_ROOT" "${repos[@]}")

findings=0
now="$(date +%s)"

dash_field() {
  grep -m1 -iE "^- *${2}:" "$1" 2>/dev/null \
    | sed -E "s/^- *[A-Za-z-]+:[[:space:]]*//; s/[[:space:]]*\$//" || true
}

for repo in "${repos[@]}"; do
  view="$(ticket_view "$repo" "$APPS_ROOT")"
  intake="$view/.icm/intake"
  [[ -d "$intake" ]] || continue
  name="${repo#"$APPS_ROOT"/}"
  [[ "$repo" == "$APPS_ROOT" ]] && name="icm-board"
  # The log origin/main carries — where a merged run actually is.
  logref=HEAD
  [[ "$view" != "$repo" ]] && logref="$(ticket_ref "$repo")"

  dormant=0
  [[ -e "$view/.icm/dormant" ]] && dormant=1

  has_pipeline=0
  [[ -f "$view/.claude/skills/pipeline/SKILL.md" ]] && has_pipeline=1

  issues=()
  open_keys=()   # slugs (and legacy IDs) used by possibly-done

  # --- epics + triage ---
  for d in "$intake"/*/; do
    [[ -d "$d" ]] || continue
    epic="$(basename "$d")"
    [[ "$epic" == "_done" ]] && continue

    if [[ "$epic" == "triage" ]]; then
      for f in "$d"*.md; do
        [[ -e "$f" ]] || continue
        fn="$(basename "$f")"
        slug="${fn%.md}"
        open_keys+=("$slug")
        lane="$(dash_field "$f" lane)"
        case "$lane" in
          bug|tweak|chore) ;;
          *) issues+=("no-lane: triage/$fn — '- lane: bug|tweak|chore' required") ;;
        esac
        if (( ! has_pipeline )) && ! grep -qiE '^## +(prompt|agent prompt) *$' "$f"; then
          issues+=("no-prompt: triage/$fn — the board's pick-up depends on it")
        fi
      done
      continue
    fi

    stubs=0
    for f in "$d"*.md; do
      [[ -e "$f" ]] || continue
      fn="$(basename "$f")"
      [[ "$fn" == "breakdown.md" ]] && continue
      stubs=$((stubs + 1))
      slug="${fn%.md}"
      open_keys+=("$slug")
      fslug="$(dash_field "$f" feature-slug)"
      if [[ -n "$fslug" && "$fslug" != "$slug" ]]; then
        issues+=("slug-mismatch: $epic/$fn — '- feature-slug: $fslug' vs filename")
      elif [[ -z "$fslug" ]]; then
        issues+=("slug-mismatch: $epic/$fn — no '- feature-slug:' header")
      fi
      seq="$(dash_field "$f" sequence)"
      [[ "$seq" =~ ^[0-9]+[[:space:]]+of[[:space:]]+[0-9]+ ]] \
        || issues+=("no-sequence: $epic/$fn — missing or malformed '- sequence: <n> of <m>'")
      if (( ! has_pipeline )) && ! grep -qiE '^## +(prompt|agent prompt) *$' "$f"; then
        issues+=("no-prompt: $epic/$fn — the board's pick-up depends on it")
      fi
    done
    if (( stubs > 0 )) && [[ ! -f "${d}breakdown.md" ]]; then
      issues+=("no-breakdown: $epic/ has $stubs stub(s) but no breakdown.md")
    fi
  done

  # --- legacy flat tickets ---
  legacy=0
  for f in "$intake"/*.md; do
    [[ -e "$f" ]] || continue
    fn="$(basename "$f")"
    case "${fn,,}" in readme.md|context.md) continue ;; esac
    legacy=$((legacy + 1))
    id="$(grep -oE '^[A-Z]+-[0-9]+' <<<"$fn" || true)"
    [[ -n "$id" ]] && open_keys+=("$id")
  done
  (( legacy > 0 )) && issues+=("legacy-unmigrated: $legacy flat ticket(s) awaiting a /project re-cut")

  # possibly-done: an open key appearing in a commit that changed something OUTSIDE
  # .icm/ — the work itself, not the ticket admin. Slugs shorter than 6 chars are
  # skipped (too generic to match against subjects honestly).
  if (( ${#open_keys[@]} > 0 )); then
    log="$(git -C "$repo" log --format='%H %s' -300 "$logref" 2>/dev/null || true)"
    for key in "${open_keys[@]}"; do
      [[ "${#key}" -ge 6 ]] || continue
      while read -r sha subject; do
        [[ -n "$sha" ]] || continue
        git -C "$repo" show --pretty=format: --name-only "$sha" 2>/dev/null \
          | grep -qvE '^(\.icm/|$)' || continue
        issues+=("possibly-done: $key — work merged in ${sha:0:7} \"$subject\"")
        break
      done < <(grep -F "$key" <<<"$log")
    done
  fi

  # off-ticket work: recent commits, zero open tickets. Silenced for dormant repos.
  if (( ${#open_keys[@]} == 0 && !dormant )); then
    last="$(git -C "$repo" log -1 --format=%ct "$logref" 2>/dev/null || echo 0)"
    if (( last > 0 && (now - last) < 14 * 86400 )); then
      issues+=("off-ticket: commits in the last 14 days but no open tickets — work is invisible to the board")
    fi
  fi

  # run-unclosed / run-unsettled: close-out.sh's own test, read from git instead of the PR API.
  # A squash merge ends its subject "(#N)"; a merge commit reads "Merge pull request #N ".
  if [[ -d "$view/.icm/runs" ]]; then
    intake_archive="$(git -C "$repo" show "$logref:.icm/project.json" 2>/dev/null \
      | jq -r '.intake_archive // empty' 2>/dev/null || true)"
    intake_archive="${intake_archive:-.icm/intake/_done}"
    intake_archive="${intake_archive%/}"
    for rd in "$view/.icm/runs"/*/; do
      [[ -d "$rd" ]] || continue
      run="$(basename "$rd")"
      [[ "$run" == _* ]] && continue
      pr="$(grep -m1 '^- pr:' "$rd/run.md" 2>/dev/null \
        | sed -E 's/^- pr:[[:space:]]*//; s/[[:space:]]+#.*$//; s#^.*/pull/##; s/^#//; s/[^0-9].*$//' || true)"
      if [[ -n "$pr" ]]; then
        merge="$(git -C "$repo" log -1 --format=%h -E \
          --grep="\\(#${pr}\\)\$" --grep="^Merge pull request #${pr} " "$logref" 2>/dev/null || true)"
        if [[ -n "$merge" ]]; then
          issues+=("run-unclosed: runs/$run — PR #$pr merged in $merge without its close-out; close-out.sh on a branch, its own PR")
        else
          issues+=("run-unsettled: runs/$run — PR #$pr has no merge on main; read the PR (closed unmerged is abandoned, not history)")
        fi
      elif [[ -d "$intake/$run" ]]; then
        :   # a front whose epic is live — it stays until the epic archives with it
      elif git -C "$repo" cat-file -e "$logref:$intake_archive/$run" 2>/dev/null; then
        issues+=("run-unclosed: runs/$run — a front whose epic is archived in $intake_archive/; close-out.sh on a branch, its own PR")
      else
        issues+=("run-unsettled: runs/$run — no '- pr:' line and no '$run' epic live or archived; close-out.sh stops on it")
      fi
    done
  fi

  suffix=""
  (( dormant )) && suffix=" (dormant)"

  if (( ${#issues[@]} == 0 )); then
    echo "${green}ok${off}   ${dim}$name$suffix${off}"
  else
    echo "${yellow}drift${off} ${bold}$name${off}${dim}$suffix${off}"
    for i in "${issues[@]}"; do echo "       $i"; findings=$((findings + 1)); done
  fi
done

# --- today.md (root-level, once) -------------------------------------------------------
today_md="$APPS_ROOT/.icm/today.md"
if [[ -f "$today_md" ]]; then
  t_issues=()
  n_today=0
  while IFS= read -r line; do
    [[ "$line" =~ ^-[[:space:]] ]] || continue
    n_today=$((n_today + 1))
    t_repo="$(sed -E 's/^- *([^·]+) ·.*/\1/; s/[[:space:]]*$//' <<<"$line")"
    t_path="$(sed -E 's/^- *[^·]+ · *([^[:space:]]+).*/\1/' <<<"$line")"
    rdir="$APPS_ROOT"
    [[ "$t_repo" == "icm-board" ]] || rdir="$(ticket_view "$APPS_ROOT/projects/$t_repo" "$APPS_ROOT")"
    if [[ ! -f "$rdir/.icm/intake/$t_path.md" && ! -f "$rdir/.icm/intake/$t_path" ]]; then
      t_issues+=("today-unresolved: '$t_repo · $t_path' — no such open stub")
    fi
  done < "$today_md"
  (( n_today > 10 )) && t_issues+=("today-dilution: $n_today entries (cap is 10 estate-wide)")
  ts="$(git -C "$APPS_ROOT" log -1 --format=%ct -- .icm/today.md 2>/dev/null || echo 0)"
  if (( ts > 0 && (now - ts) > 86400 && n_today > 0 )); then
    t_issues+=("stale-today: today.md is $(( (now - ts) / 86400 ))+ days old — a plan from a past day")
  fi
  if (( ${#t_issues[@]} > 0 )); then
    echo "${yellow}drift${off} ${bold}.icm/today.md${off}"
    for i in "${t_issues[@]}"; do echo "       $i"; findings=$((findings + 1)); done
  fi
fi

echo
echo "RESULT: $findings findings$( (( findings == 0 )) && echo ' — clean')"
(( findings == 0 ))

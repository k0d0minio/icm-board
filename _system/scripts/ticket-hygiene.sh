#!/usr/bin/env bash
# ticket-hygiene.sh — report ticket drift across the estate (read-only, never fixes).
#
# For every repo with .icm/intake/ (sustentus exempt), reports:
#
#   board drift
#     possibly-done   open ticket whose ID appears in commits on the default branch
#     today-dilution  more than 10 tickets flagged `today` (spec cap, estate-wide)
#     stale-today     a `today` flag whose ticket file hasn't been touched in over a day
#     off-ticket      repo committed to in the last 14 days but has zero open tickets
#     no-status       count of open tickets with no Status row (spec: means `ready`)
#
#   contract lint (contracts/TICKETS.md) — per ticket, on open tickets:
#     bad-h1          H1 is not `# <ID> · <title>`
#     no-priority     no Priority row (P0/P1/P2)
#     no-prompt       no standalone `## Prompt` (or `## Agent prompt`) section — the
#                     whole pick-up contract; without it the ticket cannot be picked up
#     duplicate-id    a number used by two tickets across intake/ + _done/ (never reused)
#
# Dormancy: a repo carrying an empty `.icm/dormant` file is finished work parked on a
# shelf — a build-once-hand-off client site, say. `off-ticket` is silenced for it (there
# is no board to be invisible to); every other check, lint included, still runs.
#
# Fixing is judgment work — the /day command applies fixes, this script never does.
#
# Usage: _system/scripts/ticket-hygiene.sh [root]
# Exit:  0 clean · 1 findings · 2 bad invocation

set -uo pipefail

APPS_ROOT="${1:-}"
[[ -n "$APPS_ROOT" ]] || APPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
[[ -d "$APPS_ROOT" ]] || { echo "Not a directory: $APPS_ROOT" >&2; exit 2; }

EXEMPT=("sustentus")

bold=$'\033[1m'; yellow=$'\033[33m'; green=$'\033[32m'; dim=$'\033[2m'; off=$'\033[0m'
[[ -t 1 ]] || { bold=; yellow=; green=; dim=; off=; }

mapfile -t repos < <(
  find "$APPS_ROOT" -mindepth 2 -maxdepth 3 -name .git \
    \( -type d -o -type f \) \
    -not -path '*/node_modules/*' \
    -not -path '*/.*/.*/.git' \
    -printf '%h\n' | sort
)
# The root repo (jamienisbet, .git at the root) carries the JN-* tickets.
[[ -e "$APPS_ROOT/.git" ]] && repos=("$APPS_ROOT" "${repos[@]}")

findings=0
total_today=0
now="$(date +%s)"

for repo in "${repos[@]}"; do
  base="$(basename "$repo")"
  skip=0
  for e in "${EXEMPT[@]}"; do [[ "$base" == "$e" ]] && skip=1; done
  (( skip )) && continue

  intake="$repo/.icm/intake"
  [[ -d "$intake" ]] || continue
  name="${repo#"$APPS_ROOT"/}"
  [[ "$repo" == "$APPS_ROOT" ]] && name="jamienisbet"

  # An empty .icm/dormant marks a repo as parked — see the header.
  dormant=0
  [[ -e "$repo/.icm/dormant" ]] && dormant=1

  issues=()
  open_ids=()
  today_n=0
  nostatus_n=0
  unset seen_id; declare -A seen_id

  # intake/ then _done/ — _done tickets are read for number reuse only.
  for f in "$intake"/*.md "$intake"/_done/*.md; do
    [[ -e "$f" ]] || continue
    fn="$(basename "$f")"
    [[ "${fn,,}" == "readme.md" ]] && continue
    id="$(grep -oE '^[A-Z]+-[0-9]+' <<<"$fn" || true)"

    if [[ -n "$id" ]]; then
      if [[ -n "${seen_id[$id]:-}" ]]; then
        issues+=("duplicate-id: $id used by both ${seen_id[$id]} and $fn — numbers are never reused")
      else
        seen_id[$id]="$fn"
      fi
    fi

    [[ "$f" == "$intake/_done/"* ]] && continue

    [[ -n "$id" ]] && open_ids+=("$id")

    # ── contract lint (contracts/TICKETS.md) ──
    if [[ -n "$id" ]]; then
      grep -qE "^# ${id} · .+" "$f" || issues+=("bad-h1: $fn — expected '# $id · Title'")
    else
      grep -qE '^# [A-Z]+-[0-9]+ · .+' "$f" \
        || issues+=("bad-h1: $fn — no '# <ID> · Title' H1, and the filename carries no ID")
    fi
    grep -qiE '^\| *\**priority\** *\|' "$f" \
      || issues+=("no-priority: $fn — no Priority row (P0/P1/P2)")
    grep -qiE '^## +(prompt|agent prompt) *$' "$f" \
      || issues+=("no-prompt: $fn — no standalone '## Prompt' section; the ticket cannot be picked up")

    # ── status ──
    if grep -qiE '^\| *\**status\** *\| *today' "$f"; then
      today_n=$((today_n + 1))
      # `today` is flipped the evening before; the flag's age is the file's last commit.
      ts="$(git -C "$repo" log -1 --format=%ct -- "$f" 2>/dev/null || true)"
      if [[ -n "$ts" ]] && (( ts > 0 && (now - ts) > 86400 )); then
        issues+=("stale-today: $fn has been flagged today for $(( (now - ts) / 86400 ))+ days — a flag from a past day reads as ready")
      fi
    fi
    grep -qiE '^\| *\**status\** *\|' "$f" || nostatus_n=$((nostatus_n + 1))
  done
  total_today=$((total_today + today_n))

  # possibly-done: open ticket IDs referenced by commits already on the default branch
  if (( ${#open_ids[@]} > 0 )); then
    log="$(git -C "$repo" log --oneline -300 2>/dev/null || true)"
    for id in "${open_ids[@]}"; do
      if grep -qF "$id" <<<"$log"; then
        issues+=("possibly-done: $id appears in merged commits but the ticket is still open")
      fi
    done
  fi

  (( today_n > 10 )) && issues+=("today-dilution: $today_n tickets flagged today (cap is 10 estate-wide)")

  # off-ticket work: recent commits, zero open tickets. Silenced for dormant repos.
  if (( ${#open_ids[@]} == 0 && !dormant )); then
    last="$(git -C "$repo" log -1 --format=%ct 2>/dev/null || echo 0)"
    if (( last > 0 && (now - last) < 14 * 86400 )); then
      issues+=("off-ticket: commits in the last 14 days but no open tickets — work is invisible to the board")
    fi
  fi

  (( nostatus_n > 0 )) && issues+=("no-status: $nostatus_n open tickets have no Status row (reads as ready)")

  suffix=""
  (( dormant )) && suffix=" (dormant)"

  if (( ${#issues[@]} == 0 )); then
    echo "${green}ok${off}   ${dim}$name$suffix${off}"
  else
    echo "${yellow}drift${off} ${bold}$name${off}${dim}$suffix${off}"
    for i in "${issues[@]}"; do echo "       $i"; findings=$((findings + 1)); done
  fi
done

echo
(( total_today > 10 )) && { echo "${yellow}estate-wide: $total_today tickets flagged today — cap is 10 total${off}"; findings=$((findings + 1)); }
echo "RESULT: $findings findings$( (( findings == 0 )) && echo ' — clean')"
(( findings == 0 ))

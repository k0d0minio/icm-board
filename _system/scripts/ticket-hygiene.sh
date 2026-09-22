#!/usr/bin/env bash
# ticket-hygiene.sh — report ticket drift across the estate (read-only, never fixes).
#
# For every repo with .icm/intake/ (sustentus exempt — it lints itself), reports:
#
#   board drift
#     possibly-done      open stub whose slug (or a legacy ticket's ID) appears in a
#                        commit that changed something outside .icm/ — the work, not the
#                        ticket admin. Reports the commit, so /day judges in one line.
#     off-ticket         repo committed to in the last 14 days but has zero open tickets
#     legacy-unmigrated  flat PREFIX-NNN tickets still awaiting a /project re-cut
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
[[ -e "$APPS_ROOT/.git" ]] && repos=("$APPS_ROOT" "${repos[@]}")

findings=0
now="$(date +%s)"

dash_field() {
  grep -m1 -iE "^- *${2}:" "$1" 2>/dev/null \
    | sed -E "s/^- *[A-Za-z-]+:[[:space:]]*//; s/[[:space:]]*\$//" || true
}

for repo in "${repos[@]}"; do
  base="$(basename "$repo")"
  skip=0
  for e in "${EXEMPT[@]}"; do [[ "$base" == "$e" ]] && skip=1; done
  (( skip )) && continue

  intake="$repo/.icm/intake"
  [[ -d "$intake" ]] || continue
  name="${repo#"$APPS_ROOT"/}"
  [[ "$repo" == "$APPS_ROOT" ]] && name="icm-board"

  dormant=0
  [[ -e "$repo/.icm/dormant" ]] && dormant=1

  has_pipeline=0
  [[ -f "$repo/.claude/skills/pipeline/SKILL.md" ]] && has_pipeline=1

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
    log="$(git -C "$repo" log --format='%H %s' -300 2>/dev/null || true)"
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
    last="$(git -C "$repo" log -1 --format=%ct 2>/dev/null || echo 0)"
    if (( last > 0 && (now - last) < 14 * 86400 )); then
      issues+=("off-ticket: commits in the last 14 days but no open tickets — work is invisible to the board")
    fi
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
    rdir="$APPS_ROOT/projects/$t_repo"
    [[ "$t_repo" == "icm-board" ]] && rdir="$APPS_ROOT"
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

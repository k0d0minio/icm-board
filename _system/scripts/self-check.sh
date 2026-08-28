#!/usr/bin/env bash
# self-check.sh — hold this repo to the rules it enforces on everyone else.
#
# Two checks, both cheap enough to run on every push:
#   links    every relative markdown link in this repo resolves to a real file.
#            The estate's named failure mode is "aspirational docs are richer than the
#            running system" (_system/AUDIT.md); a dead link is that failure in miniature,
#            and this repo is almost entirely docs.
#   tickets  every ticket in .icm/intake/ meets contracts/TICKETS.md: stubs live in an
#            epic (feature-slug matching the filename, a sequence, a breakdown.md) or in
#            triage/ (lane-tagged), each with a standalone `## Prompt`; nothing loose;
#            .icm/today.md entries resolve and respect the ≤10 cap.
#
# The ticket half is deliberately narrow — it checks *this* repo only, on every push.
# The same lint runs across the estate in ticket-hygiene.sh (ICM-003), which already
# walks every repo but only runs on Jamie's machine.
#
# Usage: _system/scripts/self-check.sh [root]
# Exit:  0 clean · 1 problems found · 2 bad invocation

set -uo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
[[ -d "$ROOT" ]] || { echo "Not a directory: $ROOT" >&2; exit 2; }
cd "$ROOT" || exit 2

bold=$'\033[1m'; red=$'\033[31m'; green=$'\033[32m'; off=$'\033[0m'
[[ -t 1 ]] || { bold=; red=; green=; off=; }

problems=0
report() { printf '  %s%s%s %s\n' "$red" "$1" "$off" "$2"; problems=$((problems + 1)); }

mapfile -t docs < <(git ls-files '*.md' 2>/dev/null || find . -name '*.md' -not -path './projects/*')

# ── links ────────────────────────────────────────────────────────────────────────────
echo "${bold}Links${off}"
for f in "${docs[@]}"; do
  dir="$(dirname "$f")"
  # [text](target) — skip absolute URLs, mailto, and pure anchors.
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    case "$target" in
      http://*|https://*|mailto:*|'#'*) continue ;;
    esac
    path="${target%%#*}"          # drop any anchor
    [[ -n "$path" ]] || continue
    case "$path" in
      /*) resolved=".${path}" ;;  # repo-absolute
      *)  resolved="$dir/$path" ;;
    esac
    [[ -e "$resolved" ]] || report "dead link" "$f → $target"
  done < <(grep -oE '\]\([^)]+\)' "$f" | sed -E 's/^\]\(//; s/\)$//')
done
(( problems == 0 )) && echo "  ${green}every relative link resolves${off}"

# ── tickets (contracts/TICKETS.md — epics, stubs, triage, today.md) ──────────────────
before=$problems
echo
echo "${bold}Tickets${off}"
n_stubs=0

dash_field() {
  grep -m1 -iE "^- *${2}:" "$1" 2>/dev/null \
    | sed -E "s/^- *[A-Za-z-]+:[[:space:]]*//; s/[[:space:]]*\$//" || true
}

# Nothing lives loose in intake/ — a flat ticket here is unmigrated (this repo migrated
# with the spec change, so any reappearance is a regression).
for f in .icm/intake/*.md; do
  [[ -e "$f" ]] || continue
  fn="$(basename "$f")"
  [[ "${fn,,}" == "readme.md" ]] && continue
  report "loose file" "$f — tickets are stubs in an epic or triage/ (contracts/TICKETS.md)"
done

for d in .icm/intake/*/; do
  [[ -d "$d" ]] || continue
  epic="$(basename "$d")"
  [[ "$epic" == "_done" ]] && continue

  if [[ "$epic" == "triage" ]]; then
    for f in "$d"*.md; do
      [[ -e "$f" ]] || continue
      n_stubs=$((n_stubs + 1))
      lane="$(dash_field "$f" lane)"
      case "$lane" in
        bug|tweak|chore) ;;
        *) report "lane" "$f — '- lane: bug|tweak|chore' required" ;;
      esac
      grep -qE '^## Prompt *$' "$f" || report "prompt" "$f — no standalone '## Prompt' section"
    done
    continue
  fi

  stubs=0
  for f in "$d"*.md; do
    [[ -e "$f" ]] || continue
    fn="$(basename "$f")"
    [[ "$fn" == "breakdown.md" ]] && continue
    stubs=$((stubs + 1)); n_stubs=$((n_stubs + 1))
    slug="${fn%.md}"
    fslug="$(dash_field "$f" feature-slug)"
    [[ "$fslug" == "$slug" ]] || report "feature-slug" "$f — '- feature-slug:' must match the filename"
    seq="$(dash_field "$f" sequence)"
    [[ "$seq" =~ ^[0-9]+[[:space:]]+of[[:space:]]+[0-9]+ ]] \
      || report "sequence" "$f — missing or malformed '- sequence: <n> of <m>'"
    grep -qE '^## Prompt *$' "$f" || report "prompt" "$f — no standalone '## Prompt' section"
  done
  (( stubs == 0 )) || [[ -f "${d}breakdown.md" ]] \
    || report "breakdown" "${d} — $stubs stub(s) but no breakdown.md"
done

# today.md: the one home of the today flag — ≤10 entries; this repo's entries resolve.
if [[ -f .icm/today.md ]]; then
  n_today=0
  while IFS= read -r line; do
    [[ "$line" =~ ^-[[:space:]] ]] || continue
    n_today=$((n_today + 1))
    t_repo="$(sed -E 's/^- *([^·]+) ·.*/\1/; s/[[:space:]]*$//' <<<"$line")"
    t_path="$(sed -E 's/^- *[^·]+ · *([^[:space:]]+).*/\1/' <<<"$line")"
    if [[ "$t_repo" == "icm-board" ]]; then
      [[ -f ".icm/intake/$t_path.md" || -f ".icm/intake/$t_path" ]] \
        || report "today" ".icm/today.md → '$t_path' — no such open stub in this repo"
    fi
  done < .icm/today.md
  (( n_today <= 10 )) || report "today cap" ".icm/today.md has $n_today entries — the estate cap is 10"
fi

(( problems == before )) && echo "  ${green}every ticket meets the contract${off}"

echo
if (( problems == 0 )); then
  echo "RESULT: clean — ${#docs[@]} docs, $n_stubs open stubs"
else
  echo "RESULT: $problems problem(s) across ${#docs[@]} docs and $n_stubs open stubs"
fi
(( problems == 0 ))

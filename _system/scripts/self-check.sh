#!/usr/bin/env bash
# self-check.sh — hold this repo to the rules it enforces on everyone else.
#
# Two checks, both cheap enough to run on every push:
#   links    every relative markdown link in this repo resolves to a real file.
#            The estate's named failure mode is "aspirational docs are richer than the
#            running system" (_system/AUDIT.md); a dead link is that failure in miniature,
#            and this repo is almost entirely docs.
#   tickets  every ticket in .icm/intake/ meets contracts/TICKETS.md: an `ID · Title` H1,
#            a Priority row, a standalone `## Prompt`, and a number no other ticket uses.
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

# ── tickets ──────────────────────────────────────────────────────────────────────────
before=$problems
echo
echo "${bold}Tickets${off}"
declare -A seen_id
for f in .icm/intake/*.md .icm/intake/_done/*.md; do
  [[ -e "$f" ]] || continue
  fn="$(basename "$f")"
  [[ "${fn,,}" == "readme.md" ]] && continue

  [[ "$fn" =~ ^ICM-[0-9]+-.+\.md$ ]] || report "filename" "$f — expected ICM-NNN-slug.md"

  id="$(grep -oE '^ICM-[0-9]+' <<<"$fn" || true)"
  if [[ -n "$id" ]]; then
    if [[ -n "${seen_id[$id]:-}" ]]; then
      report "duplicate id" "$id used by both ${seen_id[$id]} and $f"
    else
      seen_id[$id]="$f"
    fi
  fi

  grep -qE "^# ${id} · .+" "$f"       || report "h1"       "$f — expected '# $id · Title'"
  grep -qiE '^\| *\**priority\** *\|' "$f" || report "priority" "$f — no Priority row"
  grep -qE '^## Prompt *$' "$f"       || report "prompt"   "$f — no standalone '## Prompt' section"
done
(( problems == before )) && echo "  ${green}every ticket meets the contract${off}"

echo
if (( problems == 0 )); then
  echo "RESULT: clean — ${#docs[@]} docs, ${#seen_id[@]} tickets"
else
  echo "RESULT: $problems problem(s) across ${#docs[@]} docs and ${#seen_id[@]} tickets"
fi
(( problems == 0 ))

#!/usr/bin/env bash
# validate-spec.sh — Define's structural self-check on a run's spec.md.
# Estate pipeline template (icm-board _system/template/icm-pipeline/scripts/), adapted
# from the sustentus reference implementation.
#
# Checks only the DETERMINISTIC, non-AI properties of the spec — the slug header, the
# required sections, acceptance criteria written as checkboxes. Whether an open question
# actually *blocks* a criterion is a judgement the agent still owns; entries are surfaced
# as an advisory, never a failure. Requires no network. Pure awk/grep.
#
# Usage:
#   .icm/scripts/validate-spec.sh <slug>            # resolves .icm/runs/<slug>/01_define/output/spec.md
#   .icm/scripts/validate-spec.sh <path-to-spec.md> # or validate a spec file directly
#
# Verdict (stdout, last line):
#   RESULT: OK        exit 0  — structure is sound; ready for the human to review.
#   RESULT: INVALID   exit 2  — structural problems (listed on stderr) — fix and re-run.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

die() { echo "error: $*" >&2; exit 1; }

# --- args → spec path ------------------------------------------------------------------

arg=""
while [ $# -gt 0 ]; do
  case "$1" in
    --*) die "unknown flag: $1" ;;
    *)   [ -z "$arg" ] && arg="$1" || die "unexpected argument: $1"; shift ;;
  esac
done
[ -n "$arg" ] || die "usage: validate-spec.sh <slug | path-to-spec.md>"

if [ -f "$arg" ]; then
  spec="$arg"
else
  spec="$repo_root/.icm/runs/$arg/01_define/output/spec.md"
fi
[ -f "$spec" ] || die "no spec at .icm/runs/$arg/01_define/output/spec.md (write spec.md first, or pass an explicit path)"

# --- checks ----------------------------------------------------------------------------

problems=()
add() { problems+=("$1"); }

# 1. The slug header (the PR search key — resolve-run.sh finds the PR by it).
grep -Eq "^- slug:[[:space:]]*[^[:space:]]" "$spec" || add "missing or empty header field: '- slug:'"

# complexity is optional; when present it must be in vocabulary (it maps to review effort).
complexity="$(grep -m1 '^- complexity:' "$spec" | sed -E 's/^- complexity:[[:space:]]*//; s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]' || true)"
case "$complexity" in
  ""|trivial|standard|complex) : ;;
  *) add "complexity must be trivial|standard|complex when present, found: '$complexity'" ;;
esac

# 2. Required sections present.
for section in "Problem" "Proposed change" "Acceptance criteria" "Out of scope" "Open questions"; do
  grep -Eq "^##[[:space:]]+${section}[[:space:]]*$" "$spec" || add "missing required section: '## ${section}'"
done

# 3. Acceptance criteria are checkboxes — at least one, and every bullet is a checkbox.
ac_section="$(awk '
  /^##[[:space:]]+Acceptance criteria[[:space:]]*$/ { grab=1; next }
  grab && /^##[[:space:]]/ { grab=0 }
  grab { print }
' "$spec")"

ac_checkboxes="$(printf '%s\n' "$ac_section" | grep -Ec '^[[:space:]]*-[[:space:]]+\[[ xX]\]' || true)"
ac_plain_bullets="$(printf '%s\n' "$ac_section" | grep -E '^[[:space:]]*-[[:space:]]' | grep -Evc '^[[:space:]]*-[[:space:]]+\[[ xX]\]' || true)"

if grep -Eq "^##[[:space:]]+Acceptance criteria[[:space:]]*$" "$spec"; then
  [ "$ac_checkboxes" -ge 1 ] || add "## Acceptance criteria has no checkbox items (use '- [ ] <outcome>')"
  [ "$ac_plain_bullets" -eq 0 ] || add "## Acceptance criteria has $ac_plain_bullets non-checkbox bullet(s) — every criterion must be a '- [ ]' checkbox"
fi

# --- advisory (not a failure): open questions ------------------------------------------
oq_section="$(awk '
  /^##[[:space:]]+Open questions[[:space:]]*$/ { grab=1; next }
  grab && /^##[[:space:]]/ { grab=0 }
  grab { print }
' "$spec")"
oq_entries="$(printf '%s\n' "$oq_section" | grep -E '^[[:space:]]*-[[:space:]]' | grep -Eiv '^[[:space:]]*-[[:space:]]+none[[:space:].]*$' || true)"

# --- verdict ---------------------------------------------------------------------------

if [ -n "$oq_entries" ]; then
  echo "advisory: ## Open questions has entries — confirm none of them block an acceptance criterion. Move anything you won't do this run to ## Out of scope." >&2
fi

if [ "${#problems[@]}" -eq 0 ]; then
  echo "spec ok: $spec"
  echo "RESULT: OK"
  exit 0
fi

echo "spec invalid: $spec" >&2
for p in "${problems[@]}"; do echo "  ✗ $p" >&2; done
echo "RESULT: INVALID"
exit 2

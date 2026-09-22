#!/usr/bin/env bash
# validate-deal.sh — do a deal's quote, proposal and agreement still say the same thing? (icm-board)
#
# Read-only. For one engagement (`<client>/<engagement>`, or the client's live one from
# `DEAL.md` → `- engagement:`), it checks what `04_proposal` and `05_agreement` promise:
#   • every bullet under `## What you'll get` in 04-proposal.md appears as a scope line in
#     03-quote.md (the first significant words of the bullet, matched case-insensitively);
#   • every number in the proposal's price table equals the quote's for that tier;
#   • 05-agreement.md's `- tier:` names a tier the quote offered, and its `- agreed:` equals that
#     tier's number — or a `- deviation:` line explains;
#   • every `[LAWYER]` tag in the quote survives into the proposal and the agreement;
#   • `- language:` agrees across the three (where present);
#   • no client-facing file references a path under `private/`;
#   • nothing anywhere in the client folder matches the estate's credential patterns
#     (sk_live_, sk_test_, whsec_, ghp_, -----BEGIN, password=, token=, and the AKIA/xoxb shapes).
# It never edits a deal file: an adopted engagement may legitimately report DRIFT (its quote and
# proposal predate this check) — that is the report's content, not a failure.
#
# Usage: _system/scripts/validate-deal.sh <client>[/<engagement>] | --all
# Verdict (stdout, last line per engagement):
#   RESULT: OK · RESULT: DRIFT <n> (exit 0 — a report) · RESULT: SKIP (no engagement)
#   exit 2 — an unreadable folder (no DEAL.md, or the named engagement does not exist)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEALS="$ROOT/workspaces/deals"

dash() { grep -m1 -E "^- *$2:" "$1" 2>/dev/null | sed -E "s/^- *$2:[[:space:]]*//; s/[[:space:]]+#.*$//; s/[[:space:]]*$//"; }
norm() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[*_`]//g; s/[[:space:]]+/ /g; s/^ //; s/ $//'; }
numbers() { grep -oE '€ ?[0-9][0-9.,]*|[0-9][0-9.,]* ?€' "$1" 2>/dev/null | tr -d '€ ' | sed -E 's/[.,]([0-9]{3})/\1/g; s/,/./' | sort -u; }

check_engagement() { # <client> <engagement>
  local client="$1" eng="$2" dir="$DEALS/$1/$2" drift=0
  [ -d "$dir" ] || { echo "  unreadable: $dir does not exist"; echo "RESULT: UNREADABLE"; return 2; }
  local q="$dir/03-quote.md" p="$dir/04-proposal.md" a="$dir/05-agreement.md"
  note() { echo "  [DRIFT] $*"; drift=$((drift+1)); }
  echo "--- $client/$eng"
  # 1. proposal bullets ⊂ quote scope
  if [ -f "$p" ] && [ -f "$q" ]; then
    while IFS= read -r b; do
      [ -n "$b" ] || continue
      local key; key="$(norm "$b" | cut -d' ' -f1-4)"
      grep -qiF -- "$key" "$q" || note "proposal bullet not in the quote's scope: \"${b:0:70}\""
    done < <(awk '/^## What you.ll get/{f=1; next} /^## /{f=0} f && /^[-*] /{sub(/^[-*] +/, ""); print}' "$p" | grep -v -i '^\*\*not included' | head -40)
    # 2. price table numbers ⊂ quote numbers
    while IFS= read -r n; do
      [ -n "$n" ] || continue
      numbers "$q" | grep -qxF "$n" || note "proposal price €$n is not a number the quote carries"
    done < <(awk '/^## What it costs/{f=1; next} /^## /{f=0} f' "$p" | grep -oE '€ ?[0-9][0-9.,]*' | tr -d '€ ' | sed -E 's/[.,]([0-9]{3})/\1/g; s/,/./' | sort -u)
  elif [ -f "$p" ]; then note "04-proposal.md exists without a 03-quote.md"; fi
  # 3. agreement tier and agreed number
  if [ -f "$a" ]; then
    local tier agreed dev; tier="$(dash "$a" tier)"; agreed="$(dash "$a" agreed | tr -d '€ ,')"; dev="$(dash "$a" deviation)"
    [ -n "$tier" ] || note "05-agreement.md has no '- tier:' line"
    if [ -n "$tier" ] && [ -f "$q" ] && ! grep -qiE "$tier|$(printf '%s' "$tier" | tr '-' ' ')" "$q"; then note "agreement tier '$tier' is not a tier the quote offers"; fi
    if [ -n "$agreed" ] && [ -f "$q" ] && ! numbers "$q" | grep -qxF "$agreed" && [ -z "$dev" ]; then note "agreement '- agreed: $agreed' is not a number in the quote and no '- deviation:' explains it"; fi
    for f in "$q" "$p"; do [ -f "$f" ] || continue; done
  fi
  # 4. [LAWYER] tags survive
  if [ -f "$q" ] && grep -q '\[LAWYER\]' "$q"; then
    for f in "$p" "$a"; do [ -f "$f" ] && ! grep -q '\[LAWYER\]' "$f" && note "$(basename "$f") dropped the quote's [LAWYER] tag(s)"; done
  fi
  # 5. language agrees
  local langs; langs="$(for f in "$q" "$p" "$a"; do [ -f "$f" ] && dash "$f" language; done | grep -v '^$' | sort -u | wc -l)"
  [ "$langs" -le 1 ] || note "'- language:' disagrees across quote/proposal/agreement"
  # 6. no client-facing reference to private/
  for f in "$dir"/0[1-8]-*.md; do [ -f "$f" ] && grep -qE '(^|[^a-z])private/' "$f" && note "$(basename "$f") references a path under private/ — client-facing files never do"; done
  # 7. credential patterns anywhere in the client folder
  local hits; hits="$(grep -rnoE 'sk_live_[A-Za-z0-9]+|sk_test_[A-Za-z0-9]+|whsec_[A-Za-z0-9]+|ghp_[A-Za-z0-9]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY|password=[^ ]+|token=[^ ]+|AKIA[0-9A-Z]{16}|xox[bp]-[0-9A-Za-z-]+' "$DEALS/$client" 2>/dev/null | grep -v 'validate-deal' || true)"
  [ -z "$hits" ] || { note "credential-shaped string(s) in the client folder — flag to Jamie, never commit around: $(printf '%s' "$hits" | head -3 | tr '\n' ' ')"; }
  if [ "$drift" -eq 0 ]; then echo "RESULT: OK"; else echo "RESULT: DRIFT $drift"; fi
  return 0
}

check_client() { # <client> [<engagement>]
  local client="$1" eng="${2:-}" deal="$DEALS/$1/DEAL.md"
  [ -f "$deal" ] || { echo "$client: no DEAL.md"; echo "RESULT: UNREADABLE"; return 2; }
  [ -n "$eng" ] || eng="$(dash "$deal" engagement)"
  if [ -z "$eng" ] || [ "$eng" = "none" ]; then echo "$client: - engagement: none"; echo "RESULT: SKIP (no engagement)"; return 0; fi
  check_engagement "$client" "$eng"
}

case "${1:-}" in
  --all)
    rc=0
    for d in "$DEALS"/*/; do c="$(basename "$d")"; check_client "$c" || rc=2; done
    exit $rc ;;
  ""|-h|--help) sed -n '2,28p' "${BASH_SOURCE[0]}"; exit 2 ;;
  *)
    client="${1%%/*}"; eng=""; [ "$1" != "$client" ] && eng="${1#*/}"
    check_client "$client" "$eng" ;;
esac

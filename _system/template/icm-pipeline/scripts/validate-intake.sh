#!/usr/bin/env bash
# validate-intake.sh — structural self-check on an intake epic (the cut).
# Estate pipeline template (icm-board _system/template/icm-pipeline/scripts/), adapted
# from the sustentus reference implementation. The invariants are the estate intake
# spec's (contracts/TICKETS.md in icm-board):
#
#   1. every stub carries '- sequence: n of m', unique and contiguous over 1..m;
#   2. m agrees with how many stubs there actually are (including _done/);
#   3. every 'depends-on:' names a stub in the same epic, sequenced BEFORE its dependent;
#   4. '## Build order' in breakdown.md lists the same slugs, in the same order.
#
# Stubs already done/spun-out live in <epic>/_done/ — still part of the epic for every
# check here: a partially consumed epic must still be a contiguous 1..m, or "next" stops
# meaning anything. Requires no network. Pure bash/awk.
#
# Usage:
#   .icm/scripts/validate-intake.sh <epic-slug>          # resolves .icm/intake/<epic-slug>/
#   .icm/scripts/validate-intake.sh <path-to-intake-dir> # or point at the folder directly
#
# Verdict (stdout, last line):
#   RESULT: OK        exit 0  — the epic's bookkeeping holds.
#   RESULT: SKIP      exit 0  — nothing to validate (no breakdown.md and no stubs).
#   RESULT: INVALID   exit 2  — one or more problems (listed on stderr) — fix and re-cut.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

die() { echo "error: $*" >&2; exit 1; }

# --- args → intake dir -----------------------------------------------------------------

arg=""
while [ $# -gt 0 ]; do
  case "$1" in
    --*) die "unknown flag: $1" ;;
    *)   [ -z "$arg" ] && arg="$1" || die "unexpected argument: $1"; shift ;;
  esac
done
[ -n "$arg" ] || die "usage: validate-intake.sh <epic-slug | path-to-intake-dir>"

if [ -d "$arg" ]; then
  dir="${arg%/}"
else
  dir="$repo_root/.icm/intake/$arg"
fi
[ -d "$dir" ] || die "no intake folder at '$dir' (cut the epic first — contracts/TICKETS.md)"

# --- triage/ is a backlog, not a batch -------------------------------------------------
# The only invariant is that every stub names the lane that will consume it.

if [ "$(basename "$dir")" = "triage" ]; then
  shopt -s nullglob
  t_problems=(); t_count=0
  for f in "$dir"/*.md "$dir"/_done/*.md; do
    t_count=$((t_count + 1))
    lane="$(awk '/^-[[:space:]]+lane:/ { val = substr($0, index($0, ":") + 1);
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", val); print val; exit }' "$f")"
    case "$lane" in
      bug|tweak|chore) : ;;
      "") t_problems+=("$(basename "$f"): missing '- lane: bug|tweak|chore' — nothing can consume it") ;;
      *)  t_problems+=("$(basename "$f"): '- lane: $lane' is not bug|tweak|chore") ;;
    esac
  done
  shopt -u nullglob
  if [ "${#t_problems[@]}" -eq 0 ]; then
    echo "triage ok: $dir ($t_count stub(s), lane-tagged; no batch invariants apply)"
    echo "RESULT: OK"
    exit 0
  fi
  echo "triage invalid: $dir" >&2
  for p in "${t_problems[@]}"; do echo "  ✗ $p" >&2; done
  echo "RESULT: INVALID"
  exit 2
fi

breakdown="$dir/breakdown.md"

# --- collect the stubs -----------------------------------------------------------------

shopt -s nullglob
stubs=()
for f in "$dir"/*.md "$dir"/_done/*.md; do
  [ "$(basename "$f")" = "breakdown.md" ] && continue
  stubs+=("$f")
done
shopt -u nullglob

if [ ! -f "$breakdown" ] && [ "${#stubs[@]}" -eq 0 ]; then
  echo "intake skipped: $dir has no breakdown.md and no stubs — nothing cut yet"
  echo "RESULT: SKIP"
  exit 0
fi

problems=()
add() { problems+=("$1"); }

[ -f "$breakdown" ] || add "missing breakdown.md — the cut's single review surface"

# --- header field reader (joins wrapped continuation lines) ----------------------------

field() { # <file> <field-name>
  awk -v want="$2" '
    !grab && $0 ~ "^-[[:space:]]+" want ":" { val = substr($0, index($0, ":") + 1); grab = 1; next }
    grab && /^[[:space:]]+[^[:space:]]/ { val = val " " $0; next }
    grab { exit }
    END { gsub(/^[[:space:]]+|[[:space:]]+$/, "", val); gsub(/[[:space:]]+/, " ", val); print val }
  ' "$1"
}

# --- per-stub parse --------------------------------------------------------------------

declare -A seq_of=()      # feature-slug → sequence n
declare -A slug_at=()     # sequence n   → feature-slug
declare -A deps_of=()     # feature-slug → space-separated depends-on
declare -a batch_slugs=()
declared_m=""

for stub in "${stubs[@]}"; do
  base="$(basename "$stub" .md)"
  slug="$(field "$stub" "feature-slug")"

  if [ -z "$slug" ]; then
    add "$(basename "$stub"): missing '- feature-slug:' header"
    slug="$base"
  elif [ "$slug" != "$base" ]; then
    add "$(basename "$stub"): '- feature-slug: $slug' doesn't match the filename ('$base.md') — everything resolves stubs by filename"
    slug="$base"
  fi

  if [ -n "${seq_of[$slug]+x}" ]; then
    add "duplicate feature-slug '$slug' — two stubs claim the same slug"
    continue
  fi

  raw_seq="$(field "$stub" "sequence")"
  n="" ; m=""
  if [[ "$raw_seq" =~ ^([0-9]+)[[:space:]]+of[[:space:]]+([0-9]+) ]]; then
    n="${BASH_REMATCH[1]}"; m="${BASH_REMATCH[2]}"
  else
    add "$slug: missing or malformed '- sequence: <n> of <m>' (found: '${raw_seq:-}')"
  fi

  batch_slugs+=("$slug")
  deps_of[$slug]="$(field "$stub" "depends-on")"

  [ -n "$n" ] || continue
  seq_of[$slug]="$n"
  if [ -n "${slug_at[$n]+x}" ]; then
    add "sequence $n is claimed twice: '${slug_at[$n]}' and '$slug' — sequence must be unique"
  else
    slug_at[$n]="$slug"
  fi
  if [ -z "$declared_m" ]; then
    declared_m="$m"
  elif [ "$m" != "$declared_m" ]; then
    add "$slug: 'of $m' disagrees with 'of $declared_m' elsewhere in the epic — every stub sees the same total"
  fi
done

count="${#batch_slugs[@]}"

# 1. m agrees with the stub count.
if [ -n "$declared_m" ] && [ "$declared_m" -ne "$count" ]; then
  add "stubs say 'of $declared_m' but the epic holds $count stub(s) (including _done/) — re-cut, or a stub is missing"
fi

# 2. sequences are contiguous 1..count.
i=1
while [ "$i" -le "$count" ]; do
  [ -n "${slug_at[$i]+x}" ] || add "no stub carries 'sequence: $i of $count' — the order isn't contiguous"
  i=$((i + 1))
done

# 3. depends-on names an in-epic stub, sequenced before its dependent.
for slug in "${batch_slugs[@]}"; do
  deps="${deps_of[$slug]:-}"
  deps="${deps//\`/}"
  printf '%s' "$deps" | grep -Eiq '^[[:space:]]*none[[:space:].]*$' && continue
  [ -n "$deps" ] || { add "$slug: missing '- depends-on:' header (write 'none' when there are none)"; continue; }
  IFS=',' read -r -a dep_list <<< "$deps"
  for dep in "${dep_list[@]}"; do
    dep="$(printf '%s' "$dep" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [ -n "$dep" ] && [ "$dep" != "none" ] || continue
    if [ -z "${seq_of[$dep]+x}" ]; then
      add "$slug: depends-on '$dep', which isn't a stub in this epic (cross-epic dependencies belong in the stub's prose, not the header)"
    elif [ -n "${seq_of[$slug]+x}" ] && [ "${seq_of[$dep]}" -ge "${seq_of[$slug]}" ]; then
      add "$slug (sequence ${seq_of[$slug]}) depends-on '$dep' (sequence ${seq_of[$dep]}) — a dependency must be sequenced first"
    fi
  done
done

# 4. '## Build order' agrees with the stubs' sequences.
if [ -f "$breakdown" ]; then
  order_section="$(awk '
    /^##[[:space:]]+Build order[[:space:]]*$/ { grab = 1; next }
    grab && /^##[[:space:]]/ { grab = 0 }
    grab { print }
  ' "$breakdown")"

  if ! grep -Eq '^##[[:space:]]+Build order[[:space:]]*$' "$breakdown"; then
    add "breakdown.md has no '## Build order' section — the order the epic is walked in"
  else
    order_lines="$(printf '%s\n' "$order_section" | grep -E '^[0-9]+\.[[:space:]]' || true)"
    order_n=0
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      order_n=$((order_n + 1))
      num="$(printf '%s' "$line" | sed -E 's/^([0-9]+)\..*/\1/')"
      ord_slug="$(printf '%s' "$line" | sed -E 's/^[0-9]+\.[[:space:]]+//; s/^`?([A-Za-z0-9_-]+)`?.*/\1/')"
      if [ "$num" -ne "$order_n" ]; then
        add "breakdown.md ## Build order: line $order_n is numbered '$num.' — the list must be contiguous 1..$count"
      fi
      if [ -z "${slug_at[$num]+x}" ]; then
        add "breakdown.md ## Build order: '$num. $ord_slug' has no stub at sequence $num"
      elif [ "${slug_at[$num]}" != "$ord_slug" ]; then
        add "breakdown.md ## Build order: '$num. $ord_slug' but the stub at sequence $num is '${slug_at[$num]}' — the two must agree"
      fi
    done <<< "$order_lines"

    if [ "$order_n" -ne "$count" ]; then
      add "breakdown.md ## Build order lists $order_n feature(s) but the epic holds $count stub(s) — every stub gets a line, including ones already in _done/"
    fi
  fi
fi

# --- verdict ---------------------------------------------------------------------------

if [ "${#problems[@]}" -eq 0 ]; then
  echo "intake ok: $dir ($count stub(s), sequenced 1..$count)"
  echo "RESULT: OK"
  exit 0
fi

echo "intake invalid: $dir" >&2
for p in "${problems[@]}"; do echo "  ✗ $p" >&2; done
echo "RESULT: INVALID"
exit 2

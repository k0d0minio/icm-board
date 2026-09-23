#!/usr/bin/env bash
# tickets-board.sh — print the estate ticket board (read-only).
#
# Walks every repo's .icm/ the same way icm-check.sh discovers repos (the root repo plus
# up to 2 levels below Apps/) and prints the positional board (contracts/TICKETS.md):
#
#   Today      entries of .icm/today.md in THIS repo (the one home of the today flag)
#   In flight  .icm/runs/<slug>/ present (pipeline repos) · legacy Status in-progress
#   Blocked    stubs carrying a `- blocked: <reason>` line · legacy Status blocked
#   Next       each epic's lowest-sequence open stub · triage stubs · legacy ready
#   Queued     epic stubs behind their epic's next
#
# A client repo is read at its TICKET BASE BRANCH — `origin/<uat.branch>` where its
# `.icm/project.json` declares one, else `origin/main` (D38; lib/ticket-base.sh) — never the
# shared `projects/<repo>` checkout, which sits on `main` and on a UAT repo lags every stub
# finished on `uat`. No ref → the working tree, said on stderr. icm-board reads its own disk.
#
# Sustentus is NOT exempt here — the board reads everything (its stubs parse natively);
# writing tooling still leaves it alone. Legacy flat PREFIX-NNN tickets parse under the
# old rules until their repo migrates.
#
# Usage: _system/scripts/tickets-board.sh [--today] [root]
#   --today   print only the Today group (used by the SessionStart hook)
# Exit: 0 (always, unless bad invocation → 2)

set -uo pipefail

TODAY_ONLY=0
APPS_ROOT=""
for arg in "$@"; do
  case "$arg" in
    --today) TODAY_ONLY=1 ;;
    -*) echo "Unknown flag: $arg" >&2; exit 2 ;;
    *) APPS_ROOT="$arg" ;;
  esac
done
[[ -n "$APPS_ROOT" ]] || APPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
[[ -d "$APPS_ROOT" ]] || { echo "Not a directory: $APPS_ROOT" >&2; exit 2; }

# shellcheck source=lib/ticket-base.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib/ticket-base.sh"
TB_TMP="$(mktemp -d)"; trap 'rm -rf "$TB_TMP"' EXIT

bold=$'\033[1m'; off=$'\033[0m'
[[ -t 1 ]] || { bold=; off=; }

mapfile -t repos < <(
  find "$APPS_ROOT" -mindepth 2 -maxdepth 3 -name .git \
    \( -type d -o -type f \) \
    -not -path '*/node_modules/*' \
    -not -path '*/.*/.*/.git' \
    -printf '%h\n' | sort
)
# The root repo (icm-board, .git at the root) carries its own tickets and today.md.
[[ -e "$APPS_ROOT/.git" ]] && repos=("$APPS_ROOT" "${repos[@]}")

# One line per row: group|prio|repo|path|title
rows=""
n_open=0; n_repos=0; n_flight=0; n_blocked=0; n_done=0

# --- today.md — the one home of the today flag -----------------------------------------
declare -A today_of=()   # "<repo> <path>" → 1
n_today=0
today_lines=()
today_md="$APPS_ROOT/.icm/today.md"
if [[ -f "$today_md" ]]; then
  while IFS= read -r line; do
    [[ "$line" =~ ^-[[:space:]] ]] || continue
    t_repo="$(sed -E 's/^- *([^·]+) ·.*/\1/; s/[[:space:]]*$//' <<<"$line")"
    t_path="$(sed -E 's/^- *[^·]+ · *([^[:space:]]+).*/\1/' <<<"$line")"
    [[ -n "$t_repo" && -n "$t_path" ]] || continue
    today_of["$t_repo $t_path"]=1
    n_today=$((n_today + 1))
    today_lines+=("$line")
  done < "$today_md"
fi

dash_field() { # <file> <name> → value of "- name: value"
  grep -m1 -iE "^- *${2}:" "$1" 2>/dev/null \
    | sed -E "s/^- *[A-Za-z-]+:[[:space:]]*//; s/[[:space:]]*\$//" || true
}

prio_norm() { # normalise to P0..P2, else P9
  local p; p="$(grep -oE 'P[0-9]' <<<"${1:-}" | head -1 || true)"
  printf '%s' "${p:-P9}"
}

stub_title() { # H1 minus "Stub: "
  grep -m1 -E '^# ' "$1" 2>/dev/null | sed -E 's/^# +(Stub: *)?//' || true
}

for repo in "${repos[@]}"; do
  view="$(ticket_view "$repo" "$APPS_ROOT")"
  intake="$view/.icm/intake"
  [[ -d "$intake" ]] || continue
  name="${repo#"$APPS_ROOT"/}"
  [[ "$repo" == "$APPS_ROOT" ]] && name="icm-board"
  repo_has=0

  # --- runs in flight (pipeline repos) ---
  # Every pipeline repo moves a merged run out of runs/ in the close-out that rides the
  # run's own PR (into runs/_done/, or wherever its project.json points), so runs/ = in
  # flight — sustentus included, since its close-out moved into the PR in September 2026.
  if [[ -d "$view/.icm/runs" ]]; then
    for rd in "$view/.icm/runs"/*/; do
      [[ -d "$rd" ]] || continue
      slug="$(basename "$rd")"
      [[ "$slug" == "_done" ]] && continue
      rows+="flight|P9|$name|runs/$slug|(run in flight)"$'\n'
      n_flight=$((n_flight + 1)); repo_has=1
    done
  fi

  # --- epics + triage + legacy ---
  for d in "$intake"/*/; do
    [[ -d "$d" ]] || continue
    epic="$(basename "$d")"
    [[ "$epic" == "_done" ]] && continue

    if [[ "$epic" == "triage" ]]; then
      for f in "$d"*.md; do
        [[ -e "$f" ]] || continue
        slug="$(basename "$f" .md)"
        path="triage/$slug"
        prio="$(prio_norm "$(dash_field "$f" priority)")"
        title="$(stub_title "$f")"; [[ -n "$title" ]] || title="$slug"
        lane="$(dash_field "$f" lane)"; [[ -n "$lane" ]] && title="[$lane] $title"
        group="next"
        [[ -n "$(dash_field "$f" blocked)" ]] && group="blocked" && n_blocked=$((n_blocked + 1))
        [[ -n "${today_of["${name#projects/} $path"]:-}" ]] && group="today"
        rows+="$group|$prio|$name|$path|$title"$'\n'
        n_open=$((n_open + 1)); repo_has=1
      done
      if [[ -d "${d}_done" ]]; then
        c=$(find "${d}_done" -maxdepth 1 -name '*.md' | wc -l); n_done=$((n_done + c))
      fi
      continue
    fi

    # An epic: find the next open stub (lowest sequence) then classify the rest.
    next_seq=999999; next_slug=""
    for f in "$d"*.md; do
      [[ -e "$f" ]] || continue
      fn="$(basename "$f")"
      [[ "$fn" == "breakdown.md" ]] && continue
      slug="${fn%.md}"
      seq="$(dash_field "$f" sequence | grep -oE '^[0-9]+' || true)"
      [[ -n "$seq" ]] || seq=999998
      if [[ -z "$(dash_field "$f" blocked)" ]] && (( seq < next_seq )); then
        next_seq=$seq; next_slug="$slug"
      fi
    done
    for f in "$d"*.md; do
      [[ -e "$f" ]] || continue
      fn="$(basename "$f")"
      [[ "$fn" == "breakdown.md" ]] && continue
      slug="${fn%.md}"
      path="$epic/$slug"
      prio="$(prio_norm "$(dash_field "$f" priority)")"
      title="$(stub_title "$f")"; [[ -n "$title" ]] || title="$slug"
      if [[ -n "$(dash_field "$f" blocked)" ]]; then
        group="blocked"; n_blocked=$((n_blocked + 1))
      elif [[ "$slug" == "$next_slug" ]]; then
        group="next"
      else
        group="queued"
      fi
      [[ -n "${today_of["${name#projects/} $path"]:-}" ]] && group="today"
      rows+="$group|$prio|$name|$path|$title"$'\n'
      n_open=$((n_open + 1)); repo_has=1
    done
    if [[ -d "${d}_done" ]]; then
      c=$(find "${d}_done" -maxdepth 1 -name '*.md' | wc -l); n_done=$((n_done + c))
    fi
  done

  # Legacy flat tickets (pre-migration shape) — parsed under the old rules.
  for f in "$intake"/*.md; do
    [[ -e "$f" ]] || continue
    fn="$(basename "$f")"
    case "${fn,,}" in readme.md|context.md) continue ;; esac
    id="$(grep -oE '^[A-Z]+-[0-9]+' <<<"$fn" || true)"
    [[ -n "$id" ]] || id="${fn%.md}"
    title="$(grep -m1 -E '^# ' "$f" | sed -E 's/^# +[^·]+· *//; s/^# +//' || true)"
    [[ -n "$title" ]] || title="${fn%.md}"
    status="$(grep -m1 -iE '^\| *\**status\** *\|' "$f" \
      | sed -E 's/^\|[^|]*\| *([^|]*)\|.*/\1/' | tr -d ' *' | tr '[:upper:]' '[:lower:]' || true)"
    prio="$(grep -m1 -iE '^\| *\**priority\** *\|' "$f" \
      | sed -E 's/^\|[^|]*\| *([^|]*)\|.*/\1/' | grep -oE 'P[0-9]' | head -1 || true)"
    [[ -n "$prio" ]] || prio="P9"
    case "$status" in
      today)               group="today" ;;
      in-progress|inprogress) group="flight"; n_flight=$((n_flight + 1)) ;;
      blocked)             group="blocked"; n_blocked=$((n_blocked + 1)) ;;
      *)                   group="next" ;;
    esac
    [[ -n "${today_of["${name#projects/} $id"]:-}" ]] && group="today"
    rows+="$group|$prio|$name|$id|$title"$'\n'
    n_open=$((n_open + 1)); repo_has=1
  done

  # The root archive: flat legacy files and archived epics.
  if [[ -d "$intake/_done" ]]; then
    c=$(find "$intake/_done" -maxdepth 2 -name '*.md' ! -iname 'readme.md' ! -name 'breakdown.md' | wc -l)
    n_done=$((n_done + c))
  fi

  (( repo_has )) && n_repos=$((n_repos + 1))
done

print_group() {
  local want="$1" label="$2" out
  out="$(sort -t'|' -k2,2 -k3,3 -k4,4 <<<"$rows" | awk -F'|' -v s="$want" '$1 == s')"
  [[ -n "$out" ]] || return 0
  echo "${bold}${label}${off}"
  while IFS='|' read -r _ prio name path title; do
    p="$prio"; [[ "$p" == "P9" ]] && p="--"
    printf '  %-3s %-20s %-34s %s\n' "$p" "$name" "$path" "$title"
  done <<<"$out"
  echo
}

if (( TODAY_ONLY )); then
  if (( n_today == 0 )); then
    echo "No .icm/today.md picks. Plan the day with /day."
  else
    echo "${bold}Today ($n_today)${off}"
    printf '  %s\n' "${today_lines[@]}"
    (( n_today > 10 )) && echo "warn: $n_today entries in today.md — spec cap is 10 (see _system/contracts/TICKETS.md)"
  fi
  echo "RESULT: $n_today today · $n_open open across $n_repos repos"
  exit 0
fi

print_group today   "Today"
print_group flight  "In flight"
print_group blocked "Blocked"
print_group next    "Next"
print_group queued  "Queued"

echo "RESULT: $n_open open tickets across $n_repos repos ($n_today today, $n_flight in flight, $n_blocked blocked) · $n_done in _done"
exit 0

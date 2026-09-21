#!/usr/bin/env bash
# check-migrations.sh — are this branch's migrations still newer than main's? (TEMPLATE-OWNED)
#
# Timestamped SQL migrations (`YYYYMMDDHHMMSS_<name>.sql`) are applied in filename order, and a
# database that has already applied main's newest one will refuse, skip or misorder a migration
# stamped BEFORE it. That is exactly what a run's migration becomes when it was written on Monday
# and another run's — written on Tuesday — merged first: nothing in either diff is wrong, the two
# never conflict in git, and production breaks on the deploy. Runs are built in parallel
# (`_shared/stage-preamble.md` → Run-scoped isolation), so this is an ordinary Tuesday, not an
# edge case. Release runs this after it has merged `origin/main` into the run branch
# (`stages/04_release/CONTEXT.md` step 7), which is the last moment the answer can change.
#
# What it compares, per migrations folder:
#   main's   — the timestamped migrations in <base>'s tree (default origin/main), newest = M
#   local    — the ones in the working tree that <base> does not have: this branch's own
#   stale    — a local migration stamped at or before M
# One stale migration re-stamps EVERY local one, in their existing order, one second apart, starting
# after the latest of {now (UTC), M, the newest local stamp}: re-stamping only the stale ones would
# move them past a sibling they were written to run before.
#
# It REPORTS by default. `--apply` renames (`git mv` for a tracked file, `mv` otherwise) and
# commits nothing — the stage commits the renames with a message that says what happened. The
# rename is the operator-visible part of this script, and the one thing to know before using it:
#   a database that ALREADY APPLIED a migration under its old stamp — a persistent preview or
#   staging database — does not know the renamed file is the same migration. Production never saw
#   the old name, which is the point; a preview database that did is reset the way the repo says
#   (`_shared/project-rules.md` → The factory). The files it renames are listed so that is a
#   decision, not a surprise.
# Anything else in the repo that mentions an old stamp (a snapshot, a journal, a test) is listed
# too — the script renames files, it does not edit them.
#
# Where migrations live: `--path <dir>` (repeatable) · else `.icm/project.json` → `migrations_path`
# (a string or an array) · else every folder named `migrations/` that holds a timestamped `.sql`
# file. Other schemes — numbered (`0007_x.sql`), epoch-stamped, one folder per migration — are not
# this script's: it reports SKIP and the repo's own tooling owns the ordering.
#
# No network: it reads <base> as it is in the local clone, so fetch first (Release step 7 does).
#
# Usage: .icm/scripts/check-migrations.sh [--base <ref>] [--path <dir>]... [--apply]
# Verdict (stdout, last line):
#   RESULT: OK            exit 0  — every local migration is stamped after main's newest
#   RESULT: SKIP          exit 0  — no timestamped SQL migrations here (or none of this branch's own)
#   RESULT: STALE <n>     exit 2  — <n> local migration(s) would be re-stamped; re-run with --apply
#   RESULT: RESTAMPED <n> exit 0  — --apply renamed <n> file(s); review, commit, push
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"
die() { echo "error: $*" >&2; exit 1; }

base="origin/main"; apply=0; paths=()
while [ $# -gt 0 ]; do
  case "$1" in
    --base)    base="${2:-}"; [ -n "$base" ] || die "--base needs a ref"; shift 2 ;;
    --path)    [ -n "${2:-}" ] || die "--path needs a directory"; paths+=("${2%/}"); shift 2 ;;
    --apply)   apply=1; shift ;;
    -h|--help) sed -n '2,45p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *)         die "unknown argument: $1 (usage: check-migrations.sh [--base <ref>] [--path <dir>]... [--apply])" ;;
  esac
done

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repository"
git rev-parse --verify --quiet "${base}^{commit}" >/dev/null \
  || die "base ref '$base' does not resolve — run 'git fetch origin' first, or pass --base <ref>"

stamped='^[0-9]{14}_[^/]+\.sql$'

# --- where the migrations live ------------------------------------------------------------------------
if [ "${#paths[@]}" -eq 0 ] && command -v jq >/dev/null 2>&1 && [ -f .icm/project.json ]; then
  mapfile -t paths < <(jq -r '(.migrations_path // empty) | if type == "array" then .[] else . end' \
    .icm/project.json 2>/dev/null | sed 's:/*$::' | grep -v '^$' || true)
fi
if [ "${#paths[@]}" -eq 0 ]; then
  # Auto-detect: folders named migrations/ holding a timestamped .sql file — here, or on <base>.
  mapfile -t paths < <(
    {
      git ls-files --cached --others --exclude-standard
      git ls-tree -r --name-only "$base"
    } | grep -E '(^|/)migrations/[0-9]{14}_[^/]+\.sql$' | sed -E 's:/[^/]+$::' | sort -u
  )
fi
if [ "${#paths[@]}" -eq 0 ]; then
  echo "no timestamped SQL migrations (YYYYMMDDHHMMSS_<name>.sql) in this repo — nothing to order"
  echo "RESULT: SKIP"; exit 0
fi

# --- stamp arithmetic: 14 digits ↔ epoch seconds, GNU date first, BSD date second --------------------
to_epoch() { # YYYYMMDDHHMMSS → epoch
  local t="$1"
  date -u -d "${t:0:4}-${t:4:2}-${t:6:2} ${t:8:2}:${t:10:2}:${t:12:2}" +%s 2>/dev/null \
    || date -u -j -f '%Y%m%d%H%M%S' "$t" +%s 2>/dev/null \
    || die "cannot read '$t' as a UTC timestamp — is it a real date?"
}
to_stamp() { # epoch → YYYYMMDDHHMMSS
  date -u -d "@$1" +%Y%m%d%H%M%S 2>/dev/null || date -u -r "$1" +%Y%m%d%H%M%S
}

total_stale=0; total_local=0; renamed=0; dirs_seen=0

for dir in "${paths[@]}"; do
  mapfile -t on_main < <(git ls-tree -r --name-only "$base" -- "$dir/" 2>/dev/null \
    | sed -E 's:^.*/::' | grep -E "$stamped" | sort || true)
  here=()
  if [ -d "$dir" ]; then
    mapfile -t here < <(find "$dir" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null \
      | grep -E "$stamped" | sort || true)
  fi
  [ "${#on_main[@]}" -gt 0 ] || [ "${#here[@]}" -gt 0 ] || continue
  dirs_seen=$((dirs_seen + 1))

  # local = in the working tree, not on <base>.
  mapfile -t locals < <(comm -23 <(printf '%s\n' "${here[@]}") <(printf '%s\n' "${on_main[@]}") | grep . || true)
  # main has migrations this tree lacks → <base> was not merged in; the answer below is still right
  # (it is measured against <base>), but the branch is about to find out the hard way.
  unmerged="$(comm -13 <(printf '%s\n' "${here[@]}") <(printf '%s\n' "${on_main[@]}") | grep -c . || true)"

  newest_main=""
  [ "${#on_main[@]}" -eq 0 ] || newest_main="${on_main[-1]:0:14}"

  echo "$dir/"
  echo "  on $base: ${#on_main[@]} migration(s)${newest_main:+, newest $newest_main}"
  echo "  this branch's own: ${#locals[@]}"
  [ "$unmerged" -eq 0 ] || echo "  note: $base has $unmerged migration(s) this tree lacks — merge $base in first (Release step 7a)"

  [ "${#locals[@]}" -gt 0 ] || continue
  total_local=$((total_local + ${#locals[@]}))

  stale=()
  for f in "${locals[@]}"; do
    if [ -n "$newest_main" ] && [ ! "${f:0:14}" \> "$newest_main" ]; then stale+=("$f"); fi
  done
  if [ "${#stale[@]}" -eq 0 ]; then
    echo "  ok — every local migration is stamped after $base's newest"
    continue
  fi

  for f in "${stale[@]}"; do echo "  STALE  $f   (stamped at or before $newest_main)"; done
  total_stale=$((total_stale + ${#locals[@]}))

  # Re-stamp ALL locals, in order, from one second after the latest stamp anything already has.
  start="$(date -u +%Y%m%d%H%M%S)"
  [ ! "$newest_main" \> "$start" ] || start="$newest_main"
  newest_local="${locals[-1]:0:14}"
  [ ! "$newest_local" \> "$start" ] || start="$newest_local"
  epoch="$(to_epoch "$start")"

  i=0
  for f in "${locals[@]}"; do
    i=$((i + 1))
    new="$(to_stamp $((epoch + i)))${f:14}"
    while [ -e "$dir/$new" ]; do i=$((i + 1)); new="$(to_stamp $((epoch + i)))${f:14}"; done
    if [ "$apply" -eq 1 ]; then
      if git ls-files --error-unmatch -- "$dir/$f" >/dev/null 2>&1; then
        git mv -- "$dir/$f" "$dir/$new"
      else
        mv -- "$dir/$f" "$dir/$new"
      fi
      renamed=$((renamed + 1))
      echo "  renamed  $f → $new"
    else
      echo "  would rename  $f → $new"
    fi
    # Anything else that spells the old stamp out is the operator's to read — never edited here.
    mentions="$(git grep -l -F -e "${f:0:14}" -- . ":(exclude)$dir/$f" ":(exclude)$dir/$new" 2>/dev/null | head -5 || true)"
    [ -z "$mentions" ] || printf '    also mentions %s: %s\n' "${f:0:14}" "$(printf '%s' "$mentions" | tr '\n' ' ')"
  done
done

echo "-------------------------------------------------"
if [ "$dirs_seen" -eq 0 ] || [ "$total_local" -eq 0 ]; then
  echo "no timestamped SQL migrations of this branch's own — nothing to order"
  echo "RESULT: SKIP"; exit 0
fi
if [ "$total_stale" -eq 0 ]; then
  echo "RESULT: OK"; exit 0
fi
if [ "$apply" -eq 1 ]; then
  echo "renamed, not committed — review 'git status', commit the renames on this branch, push, and"
  echo "reset any preview database that applied the old stamps (_shared/project-rules.md → The factory)"
  echo "RESULT: RESTAMPED $renamed"; exit 0
fi
echo "main has advanced past this branch's migrations — re-run with --apply to re-stamp them"
echo "RESULT: STALE $total_stale"; exit 2

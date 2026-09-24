#!/usr/bin/env bash
# icm-sync-branch-guard.sh — regression check for icm-sync.sh's provenance guard.
#
# Found by decision-numbering + estate sync review, 2026-09-23: every pipeline repo's
# .icm/template-version named a commit `origin/main` never held — five a pre-squash head,
# sustentus's a D35–D37-without-D38 state that never existed on main — because icm-sync.sh
# stamps whatever commit its own checkout happens to be on, with no check that origin/main
# ever held it. `.icm/intake/triage/icm-sync-stamps-unmerged-commit.md` is the ticket.
#
# Builds a throwaway "icm-board" checkout (this script's own icm-sync.sh, copied — never
# edited — plus a one-file template/MANIFEST) with a real bare "origin" remote carrying
# `main`, and a fresh throwaway target repo per case, then exercises the four acceptance
# criteria:
#   1. --apply from main                       → behaves exactly as before, no branch stamp
#   2. --apply from an unmerged feature branch  → refuses, one-line reason, writes nothing
#   3. --apply --from-branch from that branch   → proceeds, stamps `branch: <name>`
#   4. --dry-run from that branch               → warns, refuses nothing, writes nothing
#
# Never touches projects/ — everything lives under a mktemp dir.
# Usage: _system/scripts/icm-sync-branch-guard.sh     Exit: 0 pass · 1 a check failed
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
lab="$(mktemp -d)"
trap 'rm -rf "$lab"' EXIT

fails=0
check() { if eval "$2"; then echo "  ok    $1"; else echo "  FAIL  $1"; fails=$((fails + 1)); fi; }

# --- a throwaway "icm-board" checkout with a real origin/main ------------------------------------
board="$lab/icm-board"
bare="$lab/origin.git"
git init --quiet --bare "$bare"

mkdir -p "$board/_system/scripts" "$board/_system/template/icm-pipeline/stages"
cp "$ROOT/_system/scripts/icm-sync.sh" "$board/_system/scripts/icm-sync.sh"
chmod +x "$board/_system/scripts/icm-sync.sh"
sync="$board/_system/scripts/icm-sync.sh"
printf 'T stages/CONTEXT.md\n' > "$board/_system/template/icm-pipeline/MANIFEST"
echo "# stage v1" > "$board/_system/template/icm-pipeline/stages/CONTEXT.md"

git -C "$board" init --quiet -b main
git -C "$board" config user.email test@example.com
git -C "$board" config user.name Test
git -C "$board" add -A
git -C "$board" commit --quiet -m seed
git -C "$board" remote add origin "$bare"
git -C "$board" push --quiet origin main

new_target() {
  local d="$lab/target-$1"
  mkdir -p "$d/.icm"
  git -C "$d" init --quiet -b main
  git -C "$d" config user.email test@example.com
  git -C "$d" config user.name Test
  echo "# ctx" > "$d/.icm/CONTEXT.md"
  git -C "$d" add -A
  git -C "$d" commit --quiet -m seed
  echo "$d"
}

# --- 1. HEAD on main: apply exactly as today ------------------------------------------------------
t1="$(new_target main)"
out="$("$sync" --apply "$t1" 2>&1)"; rc=$?
check "1. apply from main succeeds" "[ $rc -eq 0 ]"
check "1. RESULT SYNCED or UNCHANGED" "grep -qE 'RESULT: (SYNCED|UNCHANGED)' <<<\"\$out\""
check "1. no branch stamp" "! grep -q '^branch:' '$t1/.icm/template-version'"
check "1. commit stamp present" "grep -q '^template: icm-board ' '$t1/.icm/template-version'"

# --- move the template checkout to an unmerged feature branch -------------------------------------
git -C "$board" checkout --quiet -b feature/unmerged
echo "# stage v2 — not on main" > "$board/_system/template/icm-pipeline/stages/CONTEXT.md"
git -C "$board" commit --quiet -am "unmerged template change"

# --- 2. --apply from the unmerged branch, no --from-branch: refuse --------------------------------
t2="$(new_target unmerged)"
out="$("$sync" --apply "$t2" 2>&1)"; rc=$?
check "2. apply from unmerged branch refuses (exit 2)" "[ $rc -eq 2 ]"
check "2. refusal names 'not on origin/main'" "grep -q 'not on origin/main' <<<\"\$out\""
check "2. RESULT REFUSED" "grep -q 'RESULT: REFUSED' <<<\"\$out\""
check "2. writes nothing" "[ ! -e '$t2/.icm/template-version' ] && [ ! -e '$t2/.icm/stages/CONTEXT.md' ]"

# --- 3. --apply --from-branch from the same branch: proceeds, stamps the branch -------------------
t3="$(new_target from-branch)"
out="$("$sync" --apply --from-branch "$t3" 2>&1)"; rc=$?
check "3. apply --from-branch succeeds" "[ $rc -eq 0 ]"
check "3. stamps branch: feature/unmerged" "grep -q '^branch: feature/unmerged$' '$t3/.icm/template-version'"
check "3. commit stamp still present" "grep -q '^template: icm-board ' '$t3/.icm/template-version'"
check "3. warns about the override" "grep -qi 'from-branch' <<<\"\$out\""

# --- 4. --dry-run from the unmerged branch: warns, refuses nothing, writes nothing ----------------
t4="$(new_target dry-run)"
out="$("$sync" --dry-run "$t4" 2>&1)"; rc=$?
check "4. dry-run does not refuse (exit 0)" "[ $rc -eq 0 ]"
check "4. dry-run warns" "grep -qi 'WARN' <<<\"\$out\""
check "4. RESULT DRY-RUN" "grep -q 'RESULT: DRY-RUN' <<<\"\$out\""
check "4. writes nothing" "[ ! -e '$t4/.icm/template-version' ]"

echo
if (( fails == 0 )); then
  echo "RESULT: clean — provenance guard holds on main, an unmerged branch, --from-branch, and dry-run"
else
  echo "RESULT: $fails check(s) failed"
fi
(( fails == 0 ))

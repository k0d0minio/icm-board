#!/usr/bin/env bash
# icm-sync.sh — bring one repo's TEMPLATE-OWNED pipeline files up to the template (decisions D20, D22).
#
# The pipeline is split at file level (template/icm-pipeline/MANIFEST): template-owned
# files — the stage and lane contracts, the shared doctrine, the factory scripts and their lib —
# are byte-identical in every pipeline repo and carry no repo's identity; project-owned files —
# `.icm/project.json`, `_shared/project-rules.md`, `_shared/knowledge-map.md`, the local feedback
# scripts, `report.sh`, `runs/README.md` — are the repo's own. This script overwrites the first
# set from the template and NEVER touches the second: rsync is given the manifest's T entries as
# an explicit file list, so nothing outside it can move. It never deletes: a file the template
# retired (a substage, `scripts/notify.sh`) is REPORTED for the operator to `git rm`, never removed
# here. On `--apply` it also writes `.icm/template-version` — the icm-board commit the template
# came from and the date — so a repo's `setup.sh` can say how current it is without icm-board
# (the MANIFEST itself is template-owned and lands as `.icm/MANIFEST`; agency brief §4.7).
#
# It is the one deliberate exception to "drift is reported, never repaired" — narrowed to these
# files, invoked by a human, defaulting to a dry run. `icm-check.sh` still reports the drift; this
# is the repair, and only on `--apply`. Canonical `.claude/` assets keep D7: never synced.
#
# Guards, all of which refuse rather than proceed:
#   • the target must be a git repository that carries `.icm/CONTEXT.md` — an adopted estate repo.
#     There is no profile gate (decision D22): every adopted repo is a pipeline repo, so a leftover
#     `- profile: intake` line is ignored rather than refused. A repo with no `.icm/` is still
#     never a target — nothing is mkdir'd for a repo the estate has not adopted;
#   • the target's `.icm/` must have no uncommitted changes on `--apply` — a sync over local
#     edits makes the resulting diff unreadable; commit or discard first (dry runs don't care);
#   • rsync, jq and git must be present.
#
# Idempotent: `--apply` twice in a row changes nothing the second time, and the itemised output
# says so (zero `>f` lines). Runs from the icm-board checkout; four worktrees share one
# `projects/` tree, so run it from one session with no sweeper active.
#
# Usage: _system/scripts/icm-sync.sh [--apply|--dry-run] <path-to-target-repo>
# Exit:  0 synced, or simulated · 2 refused (usage, not an adopted repo, dirty .icm/, missing tool)
#        · 1 rsync itself failed
# Last line on stdout: RESULT: DRY-RUN <n> | SYNCED <n> | UNCHANGED  (n = files that changed)
set -euo pipefail

DRY_RUN=1
TARGET_REPO=""

usage() { echo "Usage: icm-sync.sh [--apply|--dry-run] <path-to-target-repo>" >&2; }
refuse() { echo "  [REFUSED] $*" >&2; echo "RESULT: REFUSED"; exit 2; }

for arg in "$@"; do
  case "$arg" in
    --apply)   DRY_RUN=0 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    -*)        usage; refuse "unknown flag: $arg" ;;
    *)         if [ -z "$TARGET_REPO" ]; then TARGET_REPO="$arg"; else usage; refuse "unexpected argument: $arg"; fi ;;
  esac
done
[ -n "$TARGET_REPO" ] || { usage; refuse "no target repo given"; }

for tool in rsync jq git; do
  command -v "$tool" >/dev/null 2>&1 || refuse "$tool not found"
done

# Resolve TEMPLATE_DIR relative to the script's own location — never a hardcoded home path.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../template/icm-pipeline" && pwd)"
MANIFEST="$TEMPLATE_DIR/MANIFEST"
[ -f "$MANIFEST" ] || refuse "template manifest missing: $MANIFEST"

[ -d "$TARGET_REPO" ] || refuse "not a directory: $TARGET_REPO"
TARGET_REPO="$(cd "$TARGET_REPO" && pwd)"
ICM_TARGET="$TARGET_REPO/.icm"

echo "=== ICM Template Sync ==="
echo "  Template Source: $TEMPLATE_DIR"
echo "  Target Repo:     $TARGET_REPO"
echo "  Execution Mode:  $([ "$DRY_RUN" -eq 1 ] && echo "DRY-RUN (simulated — nothing is written)" || echo "APPLY (live changes)")"

# --- adoption guard: a git repo the estate has adopted, and nothing else ------------------------------
# No profile is read (D22): the pipeline is every repo's shape, weighted by `complexity` in its own
# `.icm/project.json`. What still refuses is a target the estate never adopted.
TARGET_CONTEXT="$ICM_TARGET/CONTEXT.md"
git -C "$TARGET_REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || refuse "$TARGET_REPO is not a git repository"
[ -f "$TARGET_CONTEXT" ] \
  || refuse "$TARGET_REPO has no .icm/CONTEXT.md — not an ICM repo, or not adopted yet (icm-check.sh --fix seeds the baseline)"

# --- clean-tree guard: an apply over uncommitted .icm/ edits is unreadable afterwards ------------------
if [ "$DRY_RUN" -eq 0 ]; then
  dirty="$(git -C "$TARGET_REPO" status --porcelain -- .icm 2>/dev/null || true)"
  [ -z "$dirty" ] || refuse "target has uncommitted changes under .icm/ — commit or discard them first:"$'\n'"$dirty"
fi

# --- the file list: the manifest's template-owned entries, and nothing else ---------------------------
list="$(mktemp)"; trap 'rm -f "$list"' EXIT
awk '$1=="T"{print $2}' "$MANIFEST" > "$list"
n_owned="$(wc -l < "$list" | tr -d ' ')"
missing_in_template=""
while IFS= read -r p; do
  [ -f "$TEMPLATE_DIR/$p" ] || missing_in_template="${missing_in_template:+$missing_in_template, }$p"
done < "$list"
[ -z "$missing_in_template" ] || refuse "MANIFEST names template-owned files the template does not carry: $missing_in_template"
echo "  Template-owned:  $n_owned files (template/icm-pipeline/MANIFEST)"

# --- sync -------------------------------------------------------------------------------------------
# --files-from is the whole safety of this script: only listed files move, directories are created
# as needed, nothing is deleted. --checksum compares content, not mtimes, so a repo that edited a
# file is synced and a repo whose copy already matches is left alone. -p carries the executable
# bit from the template (scripts +x, lib/ −x), so no chmod is needed afterwards.
RSYNC_FLAGS=(-a --checksum --itemize-changes --files-from="$list")
[ "$DRY_RUN" -eq 1 ] && RSYNC_FLAGS+=(--dry-run)

out="$(rsync "${RSYNC_FLAGS[@]}" "$TEMPLATE_DIR/" "$ICM_TARGET/" 2>&1)" || {
  printf '%s\n' "$out" >&2; echo "RESULT: FAILED"; exit 1
}
changed="$(printf '%s\n' "$out" | grep -E '^[>c<][fd]' | grep -E '^>f' || true)"
n_changed="$(printf '%s' "$changed" | grep -c . || true)"
if [ -n "$changed" ]; then
  echo "  $([ "$DRY_RUN" -eq 1 ] && echo "Would change" || echo "Changed"):  $n_changed file(s)"
  printf '%s\n' "$changed" | awk '{ flag=$1; $1=""; sub(/^ /,""); what = (substr(flag,3,1)=="+") ? "new" : "updated"; printf "    %-8s %s\n", what, $0 }'
else
  echo "  Every template-owned file already matches the template"
fi

# --- report, never repair: project-owned files, and files the template no longer ships ----------------
echo "  Project-owned (never synced):"
while IFS= read -r p; do
  if [ -e "$ICM_TARGET/$p" ]; then echo "    present  $p"; else echo "    missing  $p   ← seed once with: icm-check.sh --fix"; fi
done < <(awk '$1=="P"{print $2}' "$MANIFEST")

retired=""
while IFS= read -r f; do
  rel="${f#"$ICM_TARGET"/}"
  grep -qxF "$rel" "$list" || retired="${retired:+$retired$'\n'}    $rel"
done < <(find "$ICM_TARGET/stages" "$ICM_TARGET/lanes" -name 'CONTEXT.md' 2>/dev/null | sort)
# Files the template retired by name — replaced, never deleted here.
for r in scripts/notify.sh; do
  [ -e "$ICM_TARGET/$r" ] && retired="${retired:+$retired$'\n'}    $r   ← retired (report.sh replaces it)"
done
if [ -n "$retired" ]; then
  echo "  Not in the template's manifest (the repo's own addition — say so in _shared/project-rules.md — or a file the template retired: git rm it; nothing is deleted here):"
  printf '%s\n' "$retired"
fi

# --- template-version: which template this repo was last brought up to ----------------------------------
# Written on --apply only, never synced (it differs per repo by construction). setup.sh reads it.
if [ "$DRY_RUN" -eq 0 ]; then
  tv_commit="$(git -C "$TEMPLATE_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
  printf 'template: icm-board %s\nsynced: %s\nmanifest: %s T files\n' "$tv_commit" "$(date -u +%F)" "$n_owned" > "$ICM_TARGET/template-version"
  echo "  Wrote .icm/template-version (icm-board $tv_commit, $(date -u +%F))"
fi

echo "-------------------------------------------------"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== Sync simulated — re-run with --apply to write ==="
  echo "RESULT: DRY-RUN $n_changed"
elif [ "$n_changed" -eq 0 ]; then
  echo "=== Sync complete — nothing to change ==="
  echo "RESULT: UNCHANGED"
else
  echo "=== Sync complete — review with: git -C $TARGET_REPO status -- .icm ==="
  echo "RESULT: SYNCED $n_changed"
fi

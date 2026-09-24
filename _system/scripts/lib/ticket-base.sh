# shellcheck shell=bash
# lib/ticket-base.sh — where a repo's ticket state lives, read from git rather than the disk.
#
# Sourced by tickets-board.sh and ticket-hygiene.sh; never executed. A client repo's ticket state
# has one home, `main`, reached by a direct commit (D39 §8 — D38's per-repo UAT base branch is
# retired). These helpers read `origin/main` rather than the shared `projects/<repo>` checkout:
# that tree is shared by every worktree and session, and whatever branch or half-finished state
# another session left it in is not the board's truth. `git archive` materialises the ref into a
# scratch dir instead.
#
# Refs are as fresh as the last fetch — /day's survey follows `pull-all.sh`, whose `git pull`
# refreshes every remote-tracking branch. Nothing here fetches, writes or moves a checkout.
#
# icm-board itself (the root repo) is read from its working tree, as before: it commits its
# tickets straight to `main`, so the disk is the truth.
#
# Callers set TB_TMP (a scratch dir they remove on exit) before calling ticket_view.

# ticket_ref <repo> → "origin/main" when that ref exists, else nothing (the caller falls back).
ticket_ref() {
  local repo="$1"
  git -C "$repo" rev-parse --verify -q "origin/main^{commit}" >/dev/null 2>&1 \
    && printf 'origin/main'
}

# ticket_view <repo> <root_repo> → prints a directory whose `.icm/` holds the repo's ticket state:
# intake/, runs/, the dormant flag (and `.claude/skills/pipeline/SKILL.md`, whether the repo has
# the /pipeline router), as `origin/main` has them. The root repo, and any repo with no
# `origin/main` ref, get the working tree itself — the latter noted on stderr when it has an
# intake (a local-only repo with no tickets stays quiet).
ticket_view() {
  local repo="$1" root="$2" ref dir p paths=()
  if [[ "$repo" == "$root" ]]; then printf '%s' "$repo"; return 0; fi
  ref="$(ticket_ref "$repo")"
  if [[ -z "$ref" ]]; then
    [[ -d "$repo/.icm/intake" ]] && echo "note: ${repo##*/} — no origin/main ref; read from the working tree" >&2
    printf '%s' "$repo"; return 0
  fi
  dir="$(mktemp -d "$TB_TMP/view.XXXXXX")"
  for p in .icm/intake .icm/runs .icm/dormant .claude/skills/pipeline/SKILL.md; do
    git -C "$repo" cat-file -e "$ref:$p" 2>/dev/null && paths+=("$p")
  done
  if (( ${#paths[@]} > 0 )); then
    git -C "$repo" archive "$ref" -- "${paths[@]}" 2>/dev/null | tar -x -C "$dir" 2>/dev/null || true
  fi
  printf '%s' "$dir"
}

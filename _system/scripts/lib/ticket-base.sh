# shellcheck shell=bash
# lib/ticket-base.sh — where a repo's ticket state lives, read from git rather than the disk (D38).
#
# Sourced by tickets-board.sh and ticket-hygiene.sh; never executed. A client repo's ticket state
# has one home, its TICKET BASE BRANCH: `.icm/project.json` → `uat.branch` where declared, else
# `main` — the same answer as the template's `lib/project.sh → pipeline_base_branch`, with
# project.json read from `origin/main` (where /setup writes it). The shared `projects/<repo>`
# checkout sits on `main`, so on a UAT repo its disk shows a lagging copy: a stub finished on
# `uat` still reads as open there. These helpers read `origin/<base>` instead.
#
# Refs are as fresh as the last fetch — /day's survey follows `pull-all.sh`, whose `git pull`
# refreshes every remote-tracking branch. Nothing here fetches, writes or moves a checkout.
#
# icm-board itself (the root repo) is read from its working tree, as before: it has no UAT branch
# and commits its tickets straight to `main`, so the disk is the truth.
#
# Callers set TB_TMP (a scratch dir they remove on exit) before calling ticket_view.

# ticket_base <repo> → the ticket base branch name (uat.branch, else main).
ticket_base() {
  local repo="$1" ub=""
  ub="$(git -C "$repo" show origin/main:.icm/project.json 2>/dev/null \
        | jq -r '.uat.branch // empty' 2>/dev/null || true)"
  printf '%s' "${ub:-main}"
}

# ticket_ref <repo> → "origin/<base>" when that ref exists, else nothing (the caller falls back).
ticket_ref() {
  local repo="$1" base
  base="$(ticket_base "$repo")"
  git -C "$repo" rev-parse --verify -q "origin/$base^{commit}" >/dev/null 2>&1 \
    && printf 'origin/%s' "$base"
}

# ticket_view <repo> <root_repo> → prints a directory whose `.icm/` holds the repo's ticket state:
# intake/, runs/, the dormant flag (and `.claude/skills/pipeline/SKILL.md`, whether the repo has
# the /pipeline router), as its ticket base branch has them. The root repo, and any
# repo with no `origin/<base>` ref, get the working tree itself — the latter noted on stderr when
# it has an intake (a local-only repo with no tickets stays quiet).
ticket_view() {
  local repo="$1" root="$2" ref dir p paths=()
  if [[ "$repo" == "$root" ]]; then printf '%s' "$repo"; return 0; fi
  ref="$(ticket_ref "$repo")"
  if [[ -z "$ref" ]]; then
    [[ -d "$repo/.icm/intake" ]] && echo "note: ${repo##*/} — no origin/$(ticket_base "$repo") ref; read from the working tree" >&2
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

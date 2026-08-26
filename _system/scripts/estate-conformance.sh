#!/usr/bin/env bash
# estate-conformance.sh — check the estate's .icm/.claude baseline over the GitHub API,
# without needing a single repo on disk.
#
# The sibling icm-check.sh answers the same question by reading `projects/`, which only
# works on Jamie's machine because the estate is gitignored. This one asks GitHub, so it
# runs in CI — and so a repo that exists on GitHub but was never cloned here still gets
# checked. Neither supersedes the other: icm-check.sh can also *fix* gaps from the
# template, and this one deliberately cannot. It reports and never writes.
#
# It mirrors icm-check.sh's severity model exactly, because two tools disagreeing about
# what "conformant" means is worse than one tool:
#   GAP   what --fix would seed — intake/, intake/README.md, _done/, docs/,
#         .claude/, .claude/settings.json. These fail the run.
#   warn  agent/human territory, never auto-fixed — no CLAUDE.md, no project.md,
#         a tracked settings.local.json, a loose TODO.md. Reported, never fatal.
#
# Membership is the one thing the API cannot tell us: on disk, "in projects/" means
# "in the estate". Here, a repo carrying no .icm/ at all is reported as **not adopted**
# rather than as six gaps — it is either outside the estate or has never been through
# /project, and either way that is a different conversation from a repo that has drifted.
#
# Config from the environment, never a .env file:
#   ESTATE_OWNER   GitHub account that owns the estate (default: k0d0minio)
#   ESTATE_EXEMPT  space-separated repo names to skip (default: sustentus — which in
#                  practice lives under its own org and so never appears here anyway)
#   GH_TOKEN       read-only token. In Actions supply a PAT (ticket ICM-005): the
#                  built-in GITHUB_TOKEN can only see the repo it runs in.
#
# Usage: _system/scripts/estate-conformance.sh [--quiet]
# Exit:  0 no gaps (warnings allowed) · 1 gaps found · 2 bad invocation or unreachable

set -uo pipefail

QUIET=0
for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=1 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

command -v gh >/dev/null 2>&1 || { echo "gh (GitHub CLI) is required" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }

OWNER="${ESTATE_OWNER:-k0d0minio}"
read -r -a EXEMPT <<<"${ESTATE_EXEMPT:-sustentus}"

bold=$'\033[1m'; dim=$'\033[2m'; red=$'\033[31m'; green=$'\033[32m'; yellow=$'\033[33m'; off=$'\033[0m'
[[ -t 1 ]] || { bold=; dim=; red=; green=; yellow=; off=; }

# /users/{u}/repos is public-only and the estate is private, so list the authenticated
# account's own repos and filter. Archived repos and forks are not the estate.
if ! repos_json=$(gh api --paginate "/user/repos?per_page=100&affiliation=owner" 2>&1); then
  echo "Could not list repositories for '$OWNER'." >&2
  printf '  %s\n' "$repos_json" >&2
  echo "RESULT: unreachable — no token, or the token cannot see $OWNER's repositories"
  exit 2
fi

mapfile -t repos < <(
  printf '%s' "$repos_json" \
    | jq -r --arg o "$OWNER" '.[]
        | select(.owner.login == $o and .archived == false and .fork == false)
        | .name' \
    | sort -u
)

if (( ${#repos[@]} == 0 )); then
  echo "RESULT: unreachable — token authenticated but returned no repositories for $OWNER"
  exit 2
fi

# One contents listing per directory, space-padded for substring matching. A 404 (path
# absent) and an empty directory are the same answer here, so both become "".
ls_path() {
  local out
  out=$(gh api "/repos/$OWNER/$1/contents/${2:-}" --jq '[.[].name] | join(" ")' 2>/dev/null) || out=""
  printf ' %s ' "$out"
}

gap_rows=""; warn_rows=""; unadopted=(); exempted=()
n_ok=0; n_gap=0; n_warn=0

for repo in "${repos[@]}"; do
  skip=0
  for e in "${EXEMPT[@]}"; do [[ "$repo" == "$e" ]] && skip=1; done
  if (( skip )); then exempted+=("$repo"); continue; fi

  root=$(ls_path "$repo")

  if [[ "$root" == "  " ]]; then
    unadopted+=("$repo (empty — nothing on the default branch)")
    continue
  fi
  if [[ "$root" != *" .icm "* ]]; then
    unadopted+=("$repo")
    continue
  fi

  missing=(); warns=()

  icm=$(ls_path "$repo" .icm)
  if [[ "$icm" == *" intake "* ]]; then
    intake=$(ls_path "$repo" .icm/intake)
    [[ "$intake" == *" README.md "* ]] || missing+=(".icm/intake/README.md")
    [[ "$intake" == *" _done "*     ]] || missing+=(".icm/intake/_done/")
  else
    missing+=(".icm/intake/" ".icm/intake/README.md" ".icm/intake/_done/")
  fi
  [[ "$icm" == *" docs "* ]] || missing+=(".icm/docs/")

  if [[ "$root" == *" .claude "* ]]; then
    cl=$(ls_path "$repo" .claude)
    [[ "$cl" == *" settings.json "* ]] || missing+=(".claude/settings.json")
    # Visible over the API at all means it is committed — which is the warn condition.
    [[ "$cl" == *" settings.local.json "* ]] && \
      warns+=(".claude/settings.local.json is tracked (accretion layer should stay local)")
  else
    missing+=(".claude/" ".claude/settings.json")
  fi

  [[ "$root" == *" CLAUDE.md "* ]] || warns+=("no CLAUDE.md (Layer-0 identity/routing file)")
  [[ "$icm" == *" project.md "*  ]] || warns+=("no .icm/project.md — /project has never run here")
  for loose in TODO.md BACKLOG.md; do
    [[ "$root" == *" $loose "* ]] && warns+=("loose $loose at root — should be tickets in .icm/intake/")
  done

  if (( ${#missing[@]} > 0 )); then
    gap_rows+="$repo|${missing[*]}"$'\n'
    n_gap=$((n_gap + 1))
  else
    n_ok=$((n_ok + 1))
  fi
  for w in "${warns[@]}"; do
    warn_rows+="$repo|$w"$'\n'
    n_warn=$((n_warn + 1))
  done
done

if (( ! QUIET )); then
  echo "${bold}Estate conformance — $OWNER, over the GitHub API${off}"
  echo "${dim}GAP = what icm-check.sh --fix would seed · warn = never auto-fixed${off}"
  echo
  while IFS='|' read -r name miss; do
    [[ -n "$name" ]] || continue
    printf '%sGAP%s  %s%s%s\n' "$red" "$off" "$bold" "$name" "$off"
    printf '       %smissing%s %s\n' "$red" "$off" "$miss"
  done <<<"$gap_rows"
  while IFS='|' read -r name w; do
    [[ -n "$name" ]] || continue
    printf '      %swarn%s %-24s %s\n' "$yellow" "$off" "$name" "$w"
  done <<<"$warn_rows"
  if (( ${#unadopted[@]} > 0 )); then
    echo
    echo "${dim}Not adopted — no .icm/ at all. Outside the estate, or /project has never run:${off}"
    printf '  %s%s%s\n' "$dim" "${unadopted[*]}" "$off" | fold -s -w 88 | sed '2,$s/^/  /'
  fi
  (( ${#exempted[@]} > 0 )) && echo "${dim}exempt: ${exempted[*]}${off}"
  echo
fi

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "## Estate conformance — \`$OWNER\`"
    echo
    echo "**$n_ok conformant · $n_gap with gaps · $n_warn warnings · ${#unadopted[@]} not adopted**"
    echo
    if [[ -n "${gap_rows//[$'\n']/}" ]]; then
      echo "### Gaps — what \`icm-check.sh --fix\` would seed"
      echo
      echo "| Repo | Missing |"
      echo "|---|---|"
      while IFS='|' read -r name miss; do
        [[ -n "$name" ]] || continue
        echo "| \`$name\` | $miss |"
      done <<<"$gap_rows"
      echo
    fi
    if [[ -n "${warn_rows//[$'\n']/}" ]]; then
      echo "### Warnings — never auto-fixed"
      echo
      echo "| Repo | Warning |"
      echo "|---|---|"
      while IFS='|' read -r name w; do
        [[ -n "$name" ]] || continue
        echo "| \`$name\` | $w |"
      done <<<"$warn_rows"
      echo
    fi
    if (( ${#unadopted[@]} > 0 )); then
      echo "### Not adopted"
      echo
      echo "No \`.icm/\` at all — outside the estate, or \`/project\` has never run:"
      echo
      printf '%s\n' "${unadopted[@]}" | sed 's/^/- `/; s/$/`/'
    fi
  } >>"$GITHUB_STEP_SUMMARY"
fi

echo "RESULT: $n_ok conformant · $n_gap with gaps · $n_warn warnings · ${#unadopted[@]} not adopted (of ${#repos[@]} repos)"
(( n_gap == 0 ))

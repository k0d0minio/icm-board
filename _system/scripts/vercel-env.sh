#!/usr/bin/env bash
# vercel-env.sh — the estate's Vercel environment plumbing: three one-way flows over one
# registry, and no two-way sync anywhere.
#
# Every estate project deploys on Vercel across three teams — kodominio (the client
# estate), sustentus and remi21 — and each team's env vars are managed in Vercel itself.
# Vercel can carry a note (`comment`, <=500 chars) on every variable, but only over the
# REST API: the CLI (54.18.6) can neither set, show nor pull one. So this script is bash
# + curl + jq with the Vercel CLI where it already does the job, and it owns three flows
# that each point one way on purpose (epic vercel-env-system):
#
#   notes   .env.example (committed, keys and prose, values never) -> Vercel comments
#   values  Vercel (dashboard / `vercel env add`) -> a generated .env.local
#   docs    those same notes interleaved as `#` lines into the generated .env.local
#
# Nothing flows back up. A value never leaves Vercel for git, a note never leaves git for
# a human's memory, and drift between them is a thing to report, not to silently
# reconcile. Only `link` — the prerequisite for every other flow — exists so far; the
# rest of the epic fills in `init`, `push-notes`, `pull` and `audit` behind it.
#
# `link` writes the `.vercel/project.json` that `vercel env pull` needs, into every
# directory the registry names. It is idempotent: a directory already pointing at the
# right project is left alone, and one pointing at a stale project name (a Vercel rename
# — messy-play carried `v0-messy-play-website` for months) is re-linked. It refuses to
# link a project name the team does not actually have, because `vercel link --yes` would
# cheerfully *create* one, and a typo here should be an error rather than a new Vercel
# project.
#
# Tokens are Jamie's manual step and are never committed, never printed, and never
# passed on a command line where `ps` could read them — the team's token is exported as
# VERCEL_TOKEN into the CLI's own environment, and handed to curl over stdin. Create one
# team-scoped token per team in the Vercel dashboard and export:
#
#   VERCEL_TOKEN_KODOMINIO   VERCEL_TOKEN_SUSTENTUS   VERCEL_TOKEN_REMI21
#
# (the exact variable names live in the registry's `teams` block). A team whose token is
# missing fails loudly, for every one of its entries — there is no ambient-session
# fallback, because "it worked on Jamie's laptop and silently did nothing in a cloud
# session" is the failure this whole epic exists to remove.
#
# Local machine only, and it writes nothing into git: `projects/` is gitignored here, and
# every file `link` creates lands in the repo it links. That last part is checked rather
# than assumed, because the estate does not actually ignore these files everywhere —
# 17 of the 40 registry paths do not ignore `.vercel/`, and one repo does not ignore
# `.env.local`. `vercel link` writes both: the link file, which holds only ids, and a
# `.env.local` carrying a short-lived VERCEL_OIDC_TOKEN. So an entry whose `.env.local`
# is not ignored is REFUSED — a token sitting in a tracked-visible file is one `git add
# -A` from being committed, and no secrets in git, ever — while an unignored `.vercel/`
# is only a warning. Neither is repaired here: the .gitignore of a client repo belongs to
# that repo, and this script reports.
#
# Usage: _system/scripts/vercel-env.sh link [--dry-run] [--quiet] [root]
# Exit:  0 every entry linked, already linked, or absent from disk ·
#        1 one or more entries failed (missing token, unreachable team, unknown project,
#          a failed link) — this one is an action, not a report, so failure stays red ·
#        2 bad invocation, or a missing dependency

set -uo pipefail

CMD=""
DRY=0
QUIET=0
APPS_ROOT=""
for arg in "$@"; do
  case "$arg" in
    link) CMD="link" ;;
    --dry-run) DRY=1 ;;
    --quiet) QUIET=1 ;;
    -h|--help) awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "${BASH_SOURCE[0]}"; exit 0 ;;
    -*) echo "Unknown flag: $arg" >&2; exit 2 ;;
    *) if [[ -z "$CMD" ]]; then echo "Unknown subcommand: $arg" >&2; exit 2; else APPS_ROOT="$arg"; fi ;;
  esac
done

if [[ -z "$CMD" ]]; then
  echo "Usage: $(basename "${BASH_SOURCE[0]}") link [--dry-run] [--quiet] [root]" >&2
  exit 2
fi

command -v vercel >/dev/null 2>&1 || { echo "vercel (Vercel CLI) is required" >&2; exit 2; }
command -v jq     >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }
command -v curl   >/dev/null 2>&1 || { echo "curl is required" >&2; exit 2; }
command -v git    >/dev/null 2>&1 || { echo "git is required" >&2; exit 2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="$SCRIPT_DIR/vercel-env-registry.json"
[[ -n "$APPS_ROOT" ]] || APPS_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECTS="$APPS_ROOT/projects"

[[ -f "$REGISTRY" ]] || { echo "Registry missing: $REGISTRY" >&2; exit 2; }
jq -e . "$REGISTRY" >/dev/null 2>&1 || { echo "Registry is not valid JSON: $REGISTRY" >&2; exit 2; }
# A worktree has no projects/ — the estate lives only in the main checkout. Say so once,
# rather than reporting forty absent directories.
[[ -d "$PROJECTS" ]] || { echo "No projects/ under $APPS_ROOT — pass the estate root as an argument" >&2; exit 2; }

bold=$'\033[1m'; dim=$'\033[2m'; red=$'\033[31m'; green=$'\033[32m'; yellow=$'\033[33m'; off=$'\033[0m'
[[ -t 1 ]] || { bold=; dim=; red=; green=; yellow=; off=; }

say() { (( QUIET )) || printf '%b\n' "$*"; }

# Would <repo>/<rel> be kept out of git? A path outside a git repo cannot be committed,
# so that counts as ignored.
git_ignores() {
  local repo="$1" rel="$2"
  git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  git -C "$repo" check-ignore -q "$rel"
}

# ---------------------------------------------------------------------------- teams --

declare -A TEAM_TOKEN=()    # slug -> token (never printed)
declare -A TEAM_PROJECTS=() # slug -> " a b c " of project names, for membership tests
declare -A TEAM_BLOCKED=()  # slug -> why every entry of this team must fail

# One API call per team, which does double duty: it proves the token works, and it yields
# the names `link` is allowed to link to. /v9/projects pages with `pagination.next`.
fetch_team_projects() {
  local team="$1" token="$2" url body names next
  url="https://api.vercel.com/v9/projects?slug=$team&limit=100"
  names=""
  while [[ -n "$url" ]]; do
    # --config on stdin keeps the bearer token out of argv, and printf is a builtin so it
    # never reaches the process table or a temp file either.
    body=$(printf 'url = "%s"\nheader = "Authorization: Bearer %s"\n' "$url" "$token" \
             | curl -sS --config - --max-time 30) || return 1
    jq -e '.projects' >/dev/null 2>&1 <<<"$body" || {
      # Vercel answers an auth or scope problem with {"error":{"message":...}}.
      jq -r '.error.message // "unrecognised response from the Vercel API"' <<<"$body"
      return 1
    }
    names+="$(jq -r '.projects[].name' <<<"$body" | tr '\n' ' ') "
    next=$(jq -r '.pagination.next // empty' <<<"$body")
    if [[ -n "$next" ]]; then
      url="https://api.vercel.com/v9/projects?slug=$team&limit=100&until=$next"
    else
      url=""
    fi
  done
  printf ' %s ' "$names"
}

mapfile -t teams < <(jq -r '.entries[].team' "$REGISTRY" | sort -u)

for team in "${teams[@]}"; do
  var=$(jq -r --arg t "$team" '.teams[$t].token_env // empty' "$REGISTRY")
  if [[ -z "$var" ]]; then
    TEAM_BLOCKED[$team]="registry names no token_env for team '$team'"
    continue
  fi
  token="${!var:-}"
  if [[ -z "$token" ]]; then
    TEAM_BLOCKED[$team]="\$$var is not set — create a team-scoped token for '$team' in the Vercel dashboard and export it"
    continue
  fi
  if ! projects=$(fetch_team_projects "$team" "$token"); then
    TEAM_BLOCKED[$team]="could not list projects for '$team': ${projects:-request failed} (\$$var may be wrong, expired, or scoped to another team)"
    continue
  fi
  TEAM_TOKEN[$team]="$token"
  TEAM_PROJECTS[$team]="$projects"
done

# ---------------------------------------------------------------------------- link ---

n_ok=0; n_linked=0; n_relinked=0; n_absent=0; n_fail=0
fail_rows=""; warn_rows=""

say "${bold}vercel-env link${off} — ${dim}$PROJECTS$( ((DRY)) && printf ' · dry run' )${off}"

# A team-wide problem is one problem, so it is said once and its entries are counted
# rather than repeated forty times. Nothing is skipped quietly: the count is right here,
# and every one of those entries lands in the failure total and the exit code.
for team in "${teams[@]}"; do
  [[ -n "${TEAM_BLOCKED[$team]:-}" ]] || continue
  n=$(jq -r --arg t "$team" '[.entries[] | select(.team == $t)] | length' "$REGISTRY")
  if (( DRY )); then
    # A dry run is a preview, and a preview is still worth having before the tokens
    # exist — it is the only way to see what a first real run will do. What it cannot
    # do without a token is confirm the project names, so it says so rather than
    # implying it checked.
    say "  ${yellow}warn${off}     ${bold}team $team${off} — ${yellow}${TEAM_BLOCKED[$team]}${off}"
    say "           ${dim}$n entries previewed without confirming their project names${off}"
  else
    say "  ${red}FAIL${off}     ${bold}team $team${off} — ${red}${TEAM_BLOCKED[$team]}${off}"
    say "           ${dim}$n entries not linked${off}"
  fi
done

while IFS=$'\t' read -r path team project; do
  [[ -n "$path" ]] || continue
  dir="$PROJECTS/$path"
  label=$(printf '%-38s' "$path")

  if [[ ! -d "$dir" ]]; then
    n_absent=$((n_absent + 1))
    say "  ${dim}absent${off}   $label ${dim}not on disk — repo not cloned here${off}"
    continue
  fi

  blocked="${TEAM_BLOCKED[$team]:-}"
  if [[ -n "$blocked" ]] && (( ! DRY )); then
    n_fail=$((n_fail + 1))   # already reported once, above, for the whole team
    continue
  fi

  # Which repo owns this path, and where inside it we are working. The first segment of
  # a registry path is always the repo directory (see the registry's _readme).
  repo_dir="$PROJECTS/${path%%/*}"
  rel="${path#"${path%%/*}"}"; rel="${rel#/}"
  prefix=""; [[ -n "$rel" ]] && prefix="$rel/"

  # `vercel link` writes a .env.local holding a short-lived VERCEL_OIDC_TOKEN alongside
  # the link file. If that file is not ignored, linking would drop a credential into a
  # tracked-visible working tree — refuse, and name the one-line fix.
  if ! git_ignores "$repo_dir" "${prefix}.env.local"; then
    n_fail=$((n_fail + 1))
    fail_rows+="$path|${prefix}.env.local is not gitignored in ${path%%/*}, and \`vercel link\` writes a VERCEL_OIDC_TOKEN there — add it to that repo's .gitignore, then re-run"$'\n'
    say "  ${red}REFUSE${off}   $label ${red}${prefix}.env.local is not gitignored — would leave a token in the working tree${off}"
    continue
  fi
  # The link file itself carries only ids, so an unignored one is untidy, not unsafe.
  if ! git_ignores "$repo_dir" "${prefix}.vercel"; then
    warn_rows+="$path|${prefix}.vercel is not gitignored in ${path%%/*} (ids only, but it does not belong in the tree)"$'\n'
  fi

  current=""
  [[ -f "$dir/.vercel/project.json" ]] && \
    current=$(jq -r '.projectName // empty' "$dir/.vercel/project.json" 2>/dev/null)

  if [[ "$current" == "$project" ]]; then
    n_ok=$((n_ok + 1))
    say "  ${green}ok${off}       $label ${dim}$team/$project${off}"
    continue
  fi

  # `vercel link --yes` creates a project that does not exist. A registry typo must not
  # mint a Vercel project, so the name has to be one the team already has.
  if [[ -z "$blocked" ]] && [[ "${TEAM_PROJECTS[$team]}" != *" $project "* ]]; then
    n_fail=$((n_fail + 1))
    fail_rows+="$path|team '$team' has no project named '$project' — refusing to link, because that would create it"$'\n'
    say "  ${red}FAIL${off}     $label ${red}no project '$project' in $team — refusing to create it${off}"
    continue
  fi

  action="link"; [[ -n "$current" ]] && action="relink"
  if (( DRY )); then
    note=""; [[ -n "$blocked" ]] && note=" ${yellow}(name unverified)${off}"
    say "  ${yellow}would${off}    $label ${dim}$action -> $team/$project${off}$note"
    [[ "$action" == "relink" ]] && n_relinked=$((n_relinked + 1)) || n_linked=$((n_linked + 1))
    continue
  fi

  if out=$( cd "$dir" && VERCEL_TOKEN="${TEAM_TOKEN[$team]}" \
              vercel link --yes --project "$project" --scope "$team" 2>&1 ); then
    if [[ "$action" == "relink" ]]; then
      n_relinked=$((n_relinked + 1))
      say "  ${green}relink${off}   $label ${dim}$current -> $team/$project${off}"
    else
      n_linked=$((n_linked + 1))
      say "  ${green}linked${off}   $label ${dim}$team/$project${off}"
    fi
  else
    n_fail=$((n_fail + 1))
    reason=$(printf '%s' "$out" | grep -iE '^\s*(error|warn)' | head -1)
    fail_rows+="$path|vercel link failed: ${reason:-see output}"$'\n'
    say "  ${red}FAIL${off}     $label ${red}${reason:-vercel link failed}${off}"
  fi
done < <(jq -r '.entries[] | [.path, .team, .project] | @tsv' "$REGISTRY")

if [[ -n "${warn_rows//[$'\n']/}" ]] && (( ! QUIET )); then
  echo
  echo "${bold}Warnings${off} ${dim}— linked, but the link file is not ignored by its repo${off}"
  while IFS='|' read -r wpath why; do
    [[ -n "$wpath" ]] || continue
    printf '  %swarn%s %s\n       %s\n' "$yellow" "$off" "$wpath" "$why"
  done <<<"$warn_rows"
fi

if [[ -n "${fail_rows//[$'\n']/}" ]] && (( ! QUIET )); then
  echo
  echo "${bold}Failures${off}"
  while IFS='|' read -r path why; do
    [[ -n "$path" ]] || continue
    printf '  %s%s%s\n    %s\n' "$red" "$path" "$off" "$why"
  done <<<"$fail_rows"
fi

say ""
verb="linked"; reverb="relinked"
(( DRY )) && { verb="to link"; reverb="to relink"; }
echo "RESULT: $n_ok already linked · $n_linked $verb · $n_relinked $reverb · $n_absent absent · $n_fail failed"
(( n_fail == 0 )) || exit 1
exit 0

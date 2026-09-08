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
# reconcile. `link` — the prerequisite for every other flow — `init` and `pull` exist so
# far; the rest of the epic fills in `push-notes` and `audit` beside them.
#
# `link` writes the `.vercel/project.json` that `vercel env pull` needs, into every
# directory the registry names — and then reads it back, because the CLI has been seen to
# report success and write nothing at all. A link that did not land is a failure here even
# though `vercel` exited happy — and the one condition known to cause it, a repo-level
# `.vercel/repo.json` above the directory, is named before the attempt rather than after.
# It is idempotent: a directory already pointing at the
# right project is left alone, and one pointing at a stale project name (a Vercel rename
# — messy-play carried `v0-messy-play-website` for months) is re-linked. It refuses to
# link a project name the team does not actually have, because `vercel link --yes` would
# cheerfully *create* one, and a typo here should be an error rather than a new Vercel
# project.
#
# `init` seeds the other end of the notes flow: the committed `.env.example` that every
# later flow reads. Vercel is the authority on which variables an app actually has, so
# init asks it — names and target environments only, never values, and it never asks for
# a decrypted one — and appends every key the app's `.env.example` does not already
# mention. It never overwrites, reorders or deletes an existing line, and it never writes
# a value: seed what is missing and leave the rest alone, the discipline icm-check
# already runs on. So a second run does nothing at all, and the prose stays Jamie's to
# write — init leaves a `# TODO: note` placeholder where the sentence goes, and `audit`
# will count the ones still outstanding.
#
# The convention that file carries is additive — a plain keys-only `.env.example` is
# still valid, it just documents nothing:
#
#   # Postgres connection string, from the Neon branch this app deploys against.
#   DATABASE_URL=
#
#   # Only the production deploy talks to the live Stripe account.  [production]
#   STRIPE_SECRET_KEY=
#
#   * the `#` line — or lines — DIRECTLY above a `KEY=` line, with no blank line between,
#     are that key's note. Joined with a single space they become the Vercel comment,
#     which Vercel caps at 500 characters.
#   * a comment block with a blank line under it belongs to no key: it is a section
#     heading, which is also how a file's banner stays a banner.
#   * an optional `[targets]` suffix on the block's last comment line scopes the key to
#     some of `production`, `preview`, `development`; absent, it means all three. A key
#     that needs a scope but no prose gets a bare `# [production]`.
#   * values never appear. init writes `KEY=` and nothing after the `=`.
#
# One thing init reports and does not fix: whether `.env.example` is ignored. A bare
# `.env*` swallows the very file this epic makes the manifest, and create-next-app puts
# exactly that in every repo it scaffolds — under the comment "env files (can opt-in for
# committing if needed)", which is precisely what opting in looks like. Seven repos still
# had it bare when init first ran and now carry `!.env.example` under it, the same line
# the rest of the estate already had; anything scaffolded next will need it again. A
# seeded file git cannot see is not a manifest, so init says so per repo and writes the
# file anyway: the .gitignore of a client repo belongs to that repo, and this script
# reports.
#
# `pull` runs the values flow, and it writes the one file in this system a human reads
# every day. For each registry entry it asks the CLI for the development environment —
# `vercel env pull`, the same command anyone would run by hand — and then rewrites what
# lands, interleaving each key's note from that app's `.env.example` as `#` lines
# directly above it. Nothing else is touched: the keys, their order and their values are
# Vercel's, values are never parsed or reformatted on the way through, and a key the
# manifest does not mention is written bare rather than guessed at. The result is the
# manifest's own words, moved to where the value is.
#
# The whole file is regenerated on every run, so it is not a place to keep anything:
# local-only overrides belong in `.env.development.local`, which Next.js reads and this
# script never touches. Two absences are normal rather than broken — a variable Vercel
# marks sensitive is write-only and never comes down at all, and a production-only
# variable is not part of a development pull — and the generated header says so, because
# the first instinct on a missing key is to assume the pull failed.
#
# `pull` fills a file with live credentials, so it refuses before writing rather than
# after: an entry whose `.env.local` its repo does not ignore is skipped and reported,
# and so is one that was never linked, since `vercel env pull` in an unlinked directory
# has nothing to read. It also puts back the app's `.gitignore` afterwards, because the
# CLI appends `.env*` to it unprompted — the same trick `vercel link` plays (stub 1),
# and `.env*` hides the `.env.example` this system runs on. That is an edit the script
# never asked for rather than drift it found, so it is reverted and reported, not left
# for someone to notice in `git status` a week later. It is one-way like the rest — no code path in it writes to Vercel
# or edits `.env.example` — and it reports what it could not document rather than
# inventing prose: keys still carrying init's `# TODO: note`, and keys Vercel has that
# the manifest has never heard of, are counted per repo and in the total. Both are
# `audit`'s findings to chase, not pull's to fix.
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
# Usage: _system/scripts/vercel-env.sh <link|init|pull> [--dry-run] [--quiet] [root]
# Exit:  0 every entry done, already done, or absent from disk ·
#        1 one or more entries failed (missing token, unreachable team, unknown project,
#          a failed link or pull, a refused write) — these are actions, not reports, so
#          failure stays red ·
#        2 bad invocation, or a missing dependency

set -uo pipefail

CMD=""
DRY=0
QUIET=0
APPS_ROOT=""
for arg in "$@"; do
  case "$arg" in
    link|init|pull) CMD="$arg" ;;
    --dry-run) DRY=1 ;;
    --quiet) QUIET=1 ;;
    -h|--help) awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "${BASH_SOURCE[0]}"; exit 0 ;;
    -*) echo "Unknown flag: $arg" >&2; exit 2 ;;
    *) if [[ -z "$CMD" ]]; then echo "Unknown subcommand: $arg" >&2; exit 2; else APPS_ROOT="$arg"; fi ;;
  esac
done

if [[ -z "$CMD" ]]; then
  echo "Usage: $(basename "${BASH_SOURCE[0]}") <link|init|pull> [--dry-run] [--quiet] [root]" >&2
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

# A `.vercel/repo.json` anywhere from here up to the repo root puts the CLI into
# repo-link mode, where `vercel link --project` quietly writes no project link at all.
# Echo the first one found, so the failure can name it.
repo_link_mode() {
  local d="$1" top="$2"
  while [[ "$d" == "$top"* ]]; do
    [[ -f "$d/.vercel/repo.json" ]] && { printf '%s' "$d/.vercel/repo.json"; return 0; }
    [[ "$d" == "$top" ]] && break
    d="$(dirname "$d")"
  done
  return 1
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

# Every variable a project has, as `KEY<TAB>targets` — names and target environments
# only. The endpoint returns one row per target set, so the same key can appear several
# times; group_by folds them into one row with the union of their targets. Values are
# never asked for (no `decrypt`) and never read out of the response: this subcommand
# documents which variables exist, and Vercel stays the only place their contents live.
fetch_project_env() {
  local team="$1" project="$2" token="$3" url body next rows=""
  url="https://api.vercel.com/v10/projects/$project/env?slug=$team&limit=100"
  while [[ -n "$url" ]]; do
    body=$(printf 'url = "%s"\nheader = "Authorization: Bearer %s"\n' "$url" "$token" \
             | curl -sS --config - --max-time 30) || return 1
    jq -e '.envs' >/dev/null 2>&1 <<<"$body" || {
      jq -r '.error.message // "unrecognised response from the Vercel API"' <<<"$body"
      return 1
    }
    rows+="$(jq -c '.envs[] | {key, target}' <<<"$body")"$'\n'
    next=$(jq -r '.pagination.next // empty' <<<"$body")
    if [[ -n "$next" ]]; then
      url="https://api.vercel.com/v10/projects/$project/env?slug=$team&limit=100&until=$next"
    else
      url=""
    fi
  done
  printf '%s' "$rows" | jq -rs 'group_by(.key)[]
    | [ .[0].key, ([.[].target // []] | flatten | unique | join(",")) ] | @tsv'
}

# The `[targets]` suffix for a key, or nothing at all. All three environments is the
# default the convention already means, so it is written as silence rather than as
# `[production,preview,development]` on every line. A custom environment cannot be
# expressed here and is simply left out of the suffix.
render_targets() {
  local csv="$1" want="" t
  for t in production preview development; do
    [[ ",$csv," == *",$t,"* ]] && want+="${want:+,}$t"
  done
  [[ -n "$want" && "$want" != "production,preview,development" ]] || return 0
  printf '  [%s]' "$want"
}

# A team-wide problem is one problem, so it is said once and its entries are counted
# rather than repeated forty times. Nothing is skipped quietly: the count is right here,
# and every one of those entries lands in the failure total and the exit code. A dry run
# can still preview what it cannot verify — where a preview is possible at all, which is
# why the caller says so rather than this deciding for itself.
report_blocked_teams() {
  local outcome="$1" preview="${2:-}" team n
  for team in "${teams[@]}"; do
    [[ -n "${TEAM_BLOCKED[$team]:-}" ]] || continue
    n=$(jq -r --arg t "$team" '[.entries[] | select(.team == $t)] | length' "$REGISTRY")
    if (( DRY )) && [[ -n "$preview" ]]; then
      say "  ${yellow}warn${off}     ${bold}team $team${off} — ${yellow}${TEAM_BLOCKED[$team]}${off}"
      say "           ${dim}$n entries $preview${off}"
    else
      say "  ${red}FAIL${off}     ${bold}team $team${off} — ${red}${TEAM_BLOCKED[$team]}${off}"
      say "           ${dim}$n entries $outcome${off}"
    fi
  done
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

# ---------------------------------------------------------------------------- init ---

# Only written into a file that did not exist. Appending this to a repo's own
# `.env.example` would be rewriting someone else's file to say what it already implies.
EXAMPLE_BANNER='# Environment variables for this app: names, notes and target scopes only — never
# values, which live in Vercel and are pulled from there.
#
# The comment lines directly above a key are that key'"'"'s note; an optional trailing
# [production,preview,development] scopes which Vercel environments it belongs to.'

if [[ "$CMD" == "init" ]]; then
  n_ok=0; n_seeded=0; n_created=0; n_absent=0; n_fail=0; n_keys=0
  fail_rows=""; warn_rows=""

  say "${bold}vercel-env init${off} — ${dim}$PROJECTS$( ((DRY)) && printf ' · dry run' )${off}"
  # No preview phrase: without the team's token there is no way to know which keys are
  # missing, so a dry run of a blocked team previews nothing and says failure either way.
  report_blocked_teams "not seeded"

  # Read before the loop, never piped into it — see the note in `link`. Nothing here
  # drains stdin the way `vercel` does, but the reason not to is the same.
  mapfile -t ENTRIES < <(jq -r '.entries[] | [.path, .team, .project] | @tsv' "$REGISTRY")

  for entry in "${ENTRIES[@]}"; do
    IFS=$'\t' read -r path team project <<<"$entry"
    [[ -n "$path" ]] || continue
    dir="$PROJECTS/$path"
    label=$(printf '%-38s' "$path")

    if [[ ! -d "$dir" ]]; then
      n_absent=$((n_absent + 1))
      say "  ${dim}absent${off}   $label ${dim}not on disk — repo not cloned here${off}"
      continue
    fi

    if [[ -n "${TEAM_BLOCKED[$team]:-}" ]]; then
      n_fail=$((n_fail + 1))   # already reported once, above, for the whole team
      continue
    fi

    if [[ "${TEAM_PROJECTS[$team]}" != *" $project "* ]]; then
      n_fail=$((n_fail + 1))
      fail_rows+="$path|team '$team' has no project named '$project' — the registry and Vercel disagree, and guessing which is right is not this script's job"$'\n'
      say "  ${red}FAIL${off}     $label ${red}no project '$project' in $team${off}"
      continue
    fi

    if ! meta=$(fetch_project_env "$team" "$project" "${TEAM_TOKEN[$team]}"); then
      n_fail=$((n_fail + 1))
      fail_rows+="$path|could not list env vars for $team/$project: ${meta:-request failed}"$'\n'
      say "  ${red}FAIL${off}     $label ${red}${meta:-could not list env vars}${off}"
      continue
    fi

    example="$dir/.env.example"

    # Which keys the file already mentions. `export FOO=` counts, an indented key counts,
    # and a commented-out one deliberately does not: a key behind a `#` is prose, and the
    # convention gives prose to the key underneath it.
    existing=" "
    [[ -f "$example" ]] && existing+="$(sed -nE 's/^[[:space:]]*(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=.*/\2/p' "$example" | tr '\n' ' ')"

    add=""; add_keys=""; n_add=0; n_vercel=0
    while IFS=$'\t' read -r key targets; do
      [[ -n "$key" ]] || continue
      n_vercel=$((n_vercel + 1))
      [[ "$existing" == *" $key "* ]] && continue
      # A blank line before every block is what keeps the block above it a note and not a
      # heading — and what stops the first appended note from adopting the last existing
      # key's line as its own.
      add+=$'\n'"# TODO: note$(render_targets "$targets")"$'\n'"$key="$'\n'
      add_keys+="$key "
      n_add=$((n_add + 1))
    done <<<"$meta"

    if (( n_add == 0 )); then
      # Two very different silences, and only one of them means the file is finished:
      # a project Vercel holds no variables for has nothing to document, and half the
      # estate's static sites are in exactly that state. Saying so is the difference
      # between a report and a shrug.
      n_ok=$((n_ok + 1))
      if (( n_vercel == 0 )); then
        say "  ${green}ok${off}       $label ${dim}no variables in Vercel — nothing to document${off}"
      else
        say "  ${green}ok${off}       $label ${dim}all $n_vercel Vercel keys already documented${off}"
      fi
      continue
    fi

    repo_dir="$PROJECTS/${path%%/*}"
    rel="${path#"${path%%/*}"}"; rel="${rel#/}"
    prefix=""; [[ -n "$rel" ]] && prefix="$rel/"
    if git_ignores "$repo_dir" "${prefix}.env.example"; then
      warn_rows+="$path|${prefix}.env.example is not committable in ${path%%/*} — seeded all the same, but it is no one's manifest until that repo's .gitignore carries \`!.env.example\`"$'\n'
    fi

    if (( DRY )); then
      n_keys=$((n_keys + n_add))
      if [[ -f "$example" ]]; then
        n_seeded=$((n_seeded + 1))
        say "  ${yellow}would${off}    $label ${dim}seed $n_add · ${add_keys% }${off}"
      else
        n_created=$((n_created + 1))
        say "  ${yellow}would${off}    $label ${dim}create with $n_add · ${add_keys% }${off}"
      fi
      continue
    fi

    if [[ -f "$example" ]]; then
      # Append, only ever append. A file whose last line has no newline is the one way
      # appending could still damage something, so it gets the newline it is missing.
      [[ -s "$example" && -n "$(tail -c 1 "$example")" ]] && printf '\n' >> "$example"
      printf '%s' "$add" >> "$example"
      n_seeded=$((n_seeded + 1))
      say "  ${green}seeded${off}   $label ${dim}$n_add · ${add_keys% }${off}"
    else
      { printf '%s\n' "$EXAMPLE_BANNER"; printf '%s' "$add"; } > "$example"
      n_created=$((n_created + 1))
      say "  ${green}created${off}  $label ${dim}$n_add · ${add_keys% }${off}"
    fi
    n_keys=$((n_keys + n_add))
  done

  if [[ -n "${warn_rows//[$'\n']/}" ]] && (( ! QUIET )); then
    echo
    echo "${bold}Warnings${off} ${dim}— seeded, but git will not carry the result${off}"
    while IFS='|' read -r wpath why; do
      [[ -n "$wpath" ]] || continue
      printf '  %swarn%s %s\n       %s\n' "$yellow" "$off" "$wpath" "$why"
    done <<<"$warn_rows"
  fi

  if [[ -n "${fail_rows//[$'\n']/}" ]] && (( ! QUIET )); then
    echo
    echo "${bold}Failures${off}"
    while IFS='|' read -r fpath why; do
      [[ -n "$fpath" ]] || continue
      printf '  %s%s%s\n    %s\n' "$red" "$fpath" "$off" "$why"
    done <<<"$fail_rows"
  fi

  say ""
  seeded="seeded"; created="created"
  (( DRY )) && { seeded="to seed"; created="to create"; }
  echo "RESULT: $n_ok up to date · $n_seeded $seeded · $n_created $created · $n_keys keys · $n_absent absent · $n_fail failed"
  (( n_fail == 0 )) || exit 1
  exit 0
fi

# ---------------------------------------------------------------------------- pull ---

# The CLI adds this to every file it writes, whether or not the project has a single
# variable of its own. It is not a project variable and the manifest will never mention
# it, so it gets its own note rather than being reported as undocumented forty times.
PULL_OIDC_NOTE='# Short-lived token the Vercel CLI writes for local OIDC auth against this project.
# Not a project variable, not part of the manifest, and replaced by the next pull.'

# The interleave, as one awk program over two files: the manifest first, the file the CLI
# just wrote second. It only ever inserts lines. A line it does not recognise as `KEY=`
# — the continuation of a multi-line value, say — is passed through exactly as it came,
# because guessing wrong about a value is worse than leaving it plain, and no value is
# ever parsed, split or rewritten on its way through.
ANNOTATE_AWK='
FILENAME == exfile {
  line = $0
  sub(/\r$/, "", line)
  if (line ~ /^[[:space:]]*#/) {
    sub(/^[[:space:]]+/, "", line)
    block = (block == "" ? line : block "\n" line)
    next
  }
  if (line ~ /^[[:space:]]*$/) { block = ""; next }
  if (match(line, /^[[:space:]]*(export[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=/)) {
    k = line
    sub(/^[[:space:]]*/, "", k)
    sub(/^export[[:space:]]+/, "", k)
    sub(/[[:space:]]*=.*$/, "", k)
    listed[k] = 1
    nlisted++
    if (block != "") note[k] = block
    block = ""
    next
  }
  block = ""
  next
}
{
  # Everything above the first key is dropped and rewritten. The CLI replaces the file
  # wholesale on every pull, so in practice that is only its own one-line header — but
  # this also swallows a header left by a previous pull, which is the one way a file
  # could arrive here already annotated. Nothing meaningful ever lives up there.
  if (!seenkey && $0 ~ /^[[:space:]]*(#|$)/) next
  if (match($0, /^[A-Za-z_][A-Za-z0-9_]*=/)) {
    seenkey = 1
    k = substr($0, 1, RLENGTH - 1)
    n = ""
    if (k in note) {
      keys++
      n = note[k]
      # A key init has seeded but nobody has explained yet, and one the manifest lists
      # with no note at all, are the same gap wearing different clothes.
      if (n ~ /^#[[:space:]]*TODO:[[:space:]]*note/) todo++; else noted++
    } else if (k in listed) {
      keys++
      todo++
    } else if (k == "VERCEL_OIDC_TOKEN") {
      n = oidc
    } else {
      keys++
      unlisted++
    }
    print ""
    if (n != "") print n
    print $0
    next
  }
  print $0
}
END { printf "\001COUNTS\t%d\t%d\t%d\t%d\t%d\n", keys+0, noted+0, todo+0, unlisted+0, nlisted+0 }
'

# What the generated file says about itself. Everything a reader needs in order not to
# misread it: where the values came from, where the notes came from, that editing it is
# pointless, and that a key they expected and cannot find is probably not a bug.
pull_header() {
  local team="$1" project="$2" exfile="$3" src="this app's .env.example"
  [[ "$exfile" == "/dev/null" ]] && src="a .env.example this app does not have yet"
  cat <<EOF
# Generated by _system/scripts/vercel-env.sh pull on $(date -u '+%Y-%m-%d %H:%M UTC') — do not edit.
#
# The values are Vercel's, pulled from $team/$project (development environment). The
# notes above each key come from $src, which is the manifest:
# a note that is wrong or missing gets fixed there, never here.
#
# The whole file is rewritten on every pull, so nothing survives in it. Local-only
# overrides belong in .env.development.local, which this script never touches.
#
# Two absences here are normal rather than broken: a variable Vercel marks sensitive is
# write-only and never comes down at all, and a production-only variable is not part of a
# development pull. \`# TODO: note\` means the manifest has not explained that key yet; a
# key with no note at all is one Vercel has and the manifest does not mention.
EOF
}

if [[ "$CMD" == "pull" ]]; then
  n_pulled=0; n_absent=0; n_fail=0
  t_keys=0; t_noted=0; t_todo=0; t_unlisted=0
  fail_rows=""; warn_rows=""

  say "${bold}vercel-env pull${off} — ${dim}$PROJECTS$( ((DRY)) && printf ' · dry run' )${off}"
  # A dry run of a blocked team can still show which entries would be refused outright,
  # since every refusal pull makes is a local one — but it cannot reach Vercel, so it is
  # previewing an intention rather than a result.
  report_blocked_teams "not pulled" "previewed without reaching Vercel"

  # Read before the loop, never piped into it: `vercel` is a node process and drains the
  # stdin it inherits, which once ate every entry after the first. See `link`.
  mapfile -t ENTRIES < <(jq -r '.entries[] | [.path, .team, .project] | @tsv' "$REGISTRY")

  for entry in "${ENTRIES[@]}"; do
    IFS=$'\t' read -r path team project <<<"$entry"
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

    repo_dir="$PROJECTS/${path%%/*}"
    rel="${path#"${path%%/*}"}"; rel="${rel#/}"
    prefix=""; [[ -n "$rel" ]] && prefix="$rel/"

    # Refuse before the write, not after it. This is the one file in the estate that ends
    # up holding every development credential an app has, and `git add -A` does not ask.
    if ! git_ignores "$repo_dir" "${prefix}.env.local"; then
      n_fail=$((n_fail + 1))
      fail_rows+="$path|${prefix}.env.local is not gitignored in ${path%%/*}, and pull fills it with live credentials — add it to that repo's .gitignore, then re-run"$'\n'
      say "  ${red}REFUSE${off}   $label ${red}${prefix}.env.local is not gitignored — would leave credentials in the working tree${off}"
      continue
    fi

    # `vercel env pull` reads .vercel/project.json and has nothing to pull without it.
    # An unlinked directory is `link`'s job, not a thing to fix quietly here.
    linked=""
    [[ -f "$dir/.vercel/project.json" ]] && \
      linked=$(jq -r '.projectName // empty' "$dir/.vercel/project.json" 2>/dev/null)
    if [[ "$linked" != "$project" ]]; then
      n_fail=$((n_fail + 1))
      if [[ -z "$linked" ]]; then
        why="not linked to any Vercel project — run \`vercel-env.sh link\` first"
      else
        why="linked to '$linked', not '$project' — run \`vercel-env.sh link\` to correct it"
      fi
      fail_rows+="$path|$why"$'\n'
      say "  ${red}FAIL${off}     $label ${red}${why}${off}"
      continue
    fi

    if [[ -z "$blocked" ]] && [[ "${TEAM_PROJECTS[$team]}" != *" $project "* ]]; then
      n_fail=$((n_fail + 1))
      fail_rows+="$path|team '$team' has no project named '$project' — the registry and Vercel disagree, and guessing which is right is not this script's job"$'\n'
      say "  ${red}FAIL${off}     $label ${red}no project '$project' in $team${off}"
      continue
    fi

    # No manifest is not a failure — 9 of the 40 entries have no variables to document —
    # so the pull happens either way and every key is simply written bare.
    exfile="$dir/.env.example"
    if [[ -f "$exfile" ]]; then
      # A manifest git cannot see is one a cloud session will never have, so the notes it
      # holds stop at this machine. Said here as well as in `init`, because this is the
      # flow whose output goes missing.
      if git_ignores "$repo_dir" "${prefix}.env.example"; then
        warn_rows+="$path|${prefix}.env.example is ignored by ${path%%/*}, so the notes interleaved below exist only on this disk — that repo needs \`!.env.example\` in its .gitignore"$'\n'
      fi
    else
      exfile="/dev/null"
    fi

    if (( DRY )); then
      n_pulled=$((n_pulled + 1))
      if [[ "$exfile" == "/dev/null" ]]; then
        manifest="no .env.example — every key bare"
      else
        manifest="annotated from .env.example"
      fi
      say "  ${yellow}would${off}    $label ${dim}pull $team/$project development -> ${prefix}.env.local · $manifest${off}"
      continue
    fi

    envfile="$dir/.env.local"

    # `vercel env pull` appends `.env*` to the .gitignore of the directory it runs in,
    # unprompted — the same trick `vercel link` plays (stub 1), and the same damage:
    # `.env*` swallows the `.env.example` this whole system treats as the manifest. It
    # did it to ten files across seven repos the first time this ran. So the file is
    # held before the call and put back after it: an edit the script never asked for,
    # to a file it has no business touching, is a side effect to clean up rather than
    # drift to report.
    gitignore="$dir/.gitignore"
    gi_existed=0; gi_before=""
    [[ -f "$gitignore" ]] && { gi_existed=1; gi_before=$(cat "$gitignore"); }

    if ! out=$( cd "$dir" && VERCEL_TOKEN="${TEAM_TOKEN[$team]}" \
                  vercel env pull .env.local --environment development --yes \
                    --scope "$team" </dev/null 2>&1 ); then
      n_fail=$((n_fail + 1))
      reason=$(printf '%s' "$out" | grep -iE '^\s*(error|warn)' | head -1 | sed 's/^[[:space:]]*//')
      fail_rows+="$path|vercel env pull failed: ${reason:-see output}"$'\n'
      say "  ${red}FAIL${off}     $label ${red}${reason:-vercel env pull failed}${off}"
      continue
    fi

    if (( gi_existed )); then
      gi_after=$(cat "$gitignore" 2>/dev/null)
      if [[ "$gi_after" != "$gi_before" ]]; then
        added=$(comm -13 <(sort <<<"$gi_before") <(sort <<<"$gi_after") | tr '\n' ' ')
        added="${added% }"
        printf '%s\n' "$gi_before" > "$gitignore"
        warn_rows+="$path|\`vercel env pull\` appended ${added:-lines} to ${prefix}.gitignore unprompted — reverted, because \`.env*\` hides the .env.example this system reads"$'\n'
      fi
    elif [[ -f "$gitignore" ]]; then
      rm -f "$gitignore"
      warn_rows+="$path|\`vercel env pull\` created a ${prefix}.gitignore that was not there before — removed"$'\n'
    fi

    if [[ ! -f "$envfile" ]]; then
      n_fail=$((n_fail + 1))
      fail_rows+="$path|\`vercel env pull\` reported success but wrote no .env.local"$'\n'
      say "  ${red}FAIL${off}     $label ${red}reported success but wrote no .env.local${off}"
      continue
    fi

    # The rewrite is held whole in a shell variable and never in a second file: a
    # half-written temp file full of credentials, even one deleted a moment later, is a
    # window this script does not need to open. `printf > "$envfile"` truncates in place,
    # so the permissions the CLI chose are the permissions it keeps.
    if ! body=$(awk -v exfile="$exfile" -v oidc="$PULL_OIDC_NOTE" "$ANNOTATE_AWK" "$exfile" "$envfile"); then
      n_fail=$((n_fail + 1))
      fail_rows+="$path|could not read back the pulled .env.local to annotate it — the file is Vercel's, unannotated"$'\n'
      say "  ${red}FAIL${off}     $label ${red}pulled, but the annotation pass failed${off}"
      continue
    fi

    counts="${body##*$'\n'}"
    if [[ "$counts" != $'\001COUNTS'* ]]; then
      n_fail=$((n_fail + 1))
      fail_rows+="$path|the annotation pass produced no summary line — refusing to overwrite the pulled file with output this script does not recognise"$'\n'
      say "  ${red}FAIL${off}     $label ${red}pulled, but the annotation pass produced nothing usable${off}"
      continue
    fi
    body="${body%$'\n'*}"
    IFS=$'\t' read -r _ k_keys k_noted k_todo k_unlisted k_listed <<<"$counts"

    if ! { printf '%s\n' "$(pull_header "$team" "$project" "$exfile")"; printf '%s\n' "$body"; } > "$envfile"; then
      n_fail=$((n_fail + 1))
      fail_rows+="$path|could not write the annotated .env.local"$'\n'
      say "  ${red}FAIL${off}     $label ${red}could not write the annotated .env.local${off}"
      continue
    fi

    n_pulled=$((n_pulled + 1))
    t_keys=$((t_keys + k_keys)); t_noted=$((t_noted + k_noted))
    t_todo=$((t_todo + k_todo)); t_unlisted=$((t_unlisted + k_unlisted))

    if [[ "$exfile" == "/dev/null" ]] && (( k_keys > 0 )); then
      warn_rows+="$path|$k_keys keys pulled with no notes at all — this app has no .env.example, so run \`init\` before the next pull"$'\n'
    fi

    if (( k_keys == 0 )); then
      # Three quite different silences, and only one of them is a project with nothing in
      # it. Half the estate's static sites genuinely hold no variables; a good many more
      # hold plenty, all of them scoped to production or marked sensitive, and neither
      # kind comes down in a development pull. Reporting all of that as "no variables"
      # would cry wolf about most of the estate — the manifest already knows the
      # difference and costs nothing to ask.
      if (( k_listed > 0 )); then
        say "  ${green}pulled${off}   $label ${dim}no development values — none of the manifest's $k_listed keys comes down in a development pull${off}"
      else
        say "  ${green}pulled${off}   $label ${dim}no variables in Vercel — only the CLI's OIDC token${off}"
      fi
    else
      detail="$k_keys keys · $k_noted noted"
      (( k_todo )) && detail+=" · $k_todo awaiting a note"
      (( k_unlisted )) && detail+=" · $k_unlisted not in the manifest"
      say "  ${green}pulled${off}   $label ${dim}$detail${off}"
    fi
  done

  if [[ -n "${warn_rows//[$'\n']/}" ]] && (( ! QUIET )); then
    echo
    echo "${bold}Warnings${off} ${dim}— pulled, with something worth knowing${off}"
    while IFS='|' read -r wpath why; do
      [[ -n "$wpath" ]] || continue
      printf '  %swarn%s %s\n       %s\n' "$yellow" "$off" "$wpath" "$why"
    done <<<"$warn_rows"
  fi

  if [[ -n "${fail_rows//[$'\n']/}" ]] && (( ! QUIET )); then
    echo
    echo "${bold}Failures${off}"
    while IFS='|' read -r fpath why; do
      [[ -n "$fpath" ]] || continue
      printf '  %s%s%s\n    %s\n' "$red" "$fpath" "$off" "$why"
    done <<<"$fail_rows"
  fi

  say ""
  pulled="pulled"
  (( DRY )) && pulled="to pull"
  if (( DRY )); then
    echo "RESULT: $n_pulled $pulled · $n_absent absent · $n_fail failed"
  else
    echo "RESULT: $n_pulled $pulled · $t_keys keys ($t_noted noted · $t_todo awaiting a note · $t_unlisted not in the manifest) · $n_absent absent · $n_fail failed"
  fi
  (( n_fail == 0 )) || exit 1
  exit 0
fi

# ---------------------------------------------------------------------------- link ---

n_ok=0; n_linked=0; n_relinked=0; n_absent=0; n_fail=0
fail_rows=""; warn_rows=""

say "${bold}vercel-env link${off} — ${dim}$PROJECTS$( ((DRY)) && printf ' · dry run' )${off}"

# A dry run is a preview, and a preview is still worth having before the tokens exist —
# it is the only way to see what a first real run will do. What it cannot do without a
# token is confirm the project names, so it says so rather than implying it checked.
report_blocked_teams "not linked" "previewed without confirming their project names"

# The registry is read into an array *before* the loop rather than piped into it. Piping
# it in would leave the loop body reading from the same stdin as the commands it runs —
# and `vercel` is a node process, which drains whatever stdin it inherits. That ate every
# remaining entry the moment the first real `vercel link` ran, so a run would stop dead
# after its first link and still report success. An array cannot be swallowed.
mapfile -t ENTRIES < <(jq -r '.entries[] | [.path, .team, .project] | @tsv' "$REGISTRY")

for entry in "${ENTRIES[@]}"; do
  IFS=$'\t' read -r path team project <<<"$entry"
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
  # Asked about `.vercel`, `git check-ignore` cannot match a `dir/`-style rule against a
  # path that does not exist yet — and before linking it never does, so every repo whose
  # rule is `.vercel/` looked unignored. Ask about a file *inside* it instead, which a
  # directory rule covers whether or not anything is there yet.
  if ! git_ignores "$repo_dir" "${prefix}.vercel/project.json"; then
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

  # Repo mode is the one state where `vercel link --project` reports success and writes
  # nothing, so name it before trying rather than after failing. It cost eight estate
  # directories a silent no-link: two stale repo.json files, one still describing paths
  # from before the 2026-08-26 repo split, the other listing projects that no longer
  # exist.
  if mode_file=$(repo_link_mode "$dir" "$repo_dir"); then
    n_fail=$((n_fail + 1))
    fail_rows+="$path|${mode_file#$PROJECTS/} puts the Vercel CLI in repo-link mode, where \`vercel link --project\` writes no project link. It is a regenerable local cache: delete it if it is stale, or link this repo with \`vercel link --repo\`"$'\n'
    say "  ${red}FAIL${off}     $label ${red}repo-link mode (${mode_file#$PROJECTS/}) — \`link --project\` cannot write here${off}"
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
              vercel link --yes --project "$project" --scope "$team" </dev/null 2>&1 ); then
    # Trust, then check. In eight estate directories the CLI reported success and left no
    # link behind, so a run said "linked" forty times and `vercel env pull` would still
    # have had nothing to read in a fifth of them. The only claim worth making is that
    # the file is on disk and names the project we asked for.
    landed=""
    [[ -f "$dir/.vercel/project.json" ]] && \
      landed=$(jq -r '.projectName // empty' "$dir/.vercel/project.json" 2>/dev/null)
    if [[ "$landed" != "$project" ]]; then
      n_fail=$((n_fail + 1))
      if [[ -z "$landed" ]]; then
        why="\`vercel link\` reported success but wrote no .vercel/project.json"
      else
        why="\`vercel link\` reported success but wrote a link to '$landed', not '$project'"
      fi
      reason=$(printf '%s' "$out" | grep -iE '"(message|reason)"|^\s*(error|warn)' | head -1 | sed 's/^[[:space:]]*//')
      fail_rows+="$path|$why${reason:+ — CLI said: $reason}"$'\n'
      say "  ${red}FAIL${off}     $label ${red}${why}${off}"
      continue
    fi
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
done

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

#!/usr/bin/env bash
# lib/project.sh — the one reader of the project-owned manifest, .icm/project.json. Sourced, not run.
#
# The template-owned scripts and contracts carry no repo identity (template/README.md → "No
# substitutions"; decision D20). Whatever is specific to one repo — its name, where its docs
# live, where shipped runs are archived, which CI checks must be present, where it deploys, how
# it reports — lives in `.icm/project.json`, which the repo owns and the sync never touches. This
# library is how a script reads it, with a default for every key so a repo that has not filled
# the manifest in still runs on the estate's own conventions (`.icm/runs/_done/`,
# `.icm/intake/_done/`, a GitHub Release on every merge).
#
# Keys (all optional except `name`, which `env-check.sh` reports on):
#   name            the repo's short name (its folder name under projects/)
#   complexity      how much of the pipeline this project leans on: "standard" (the default —
#                   absent reads as standard) or "micro" (a one-page site, a script repo: the
#                   knowledge-map check returns 0 at once; the support section prints
#                   `micro: no support line`). There is no `profile` key any more — every repo
#                   carries the one pipeline; an old `"profile"` value is ignored.
#   docs_path       root of the docs tree the stages read through _shared/knowledge-map.md
#   required_env    array of environment variable names the pipeline needs in this repo
#   required_checks array of check-run names ci-status.sh must see completed before GREEN
#                   (PIPELINE_REQUIRED_CHECKS in the environment overrides it)
#   personas        array of persona label keywords project-labels.sh may project (the repo's
#                   own vocabulary, matching its labels file); empty means no persona labels
#   runs_archive    where close-out.sh moves a shipped run      (default .icm/runs/_done)
#   intake_archive  where close-out.sh moves a finished epic    (default .icm/intake/_done)
#   smoke_check     object {name, workflow, preview_status} — a conditionally required preview
#                   walk (see ci-status.sh); absent means the repo has none
#   models          object {sonnet, opus, fable} → the model id this repo's harness wants for
#                   each alias select-model.sh prints; absent means the alias is all it prints
#   deploy          object — where the repo deploys (agency brief §4.2). `platform` ("vercel"),
#                   `team_slug`, `token_env` (the NAME of the variable holding the Vercel token;
#                   lib/vercel.sh falls back to plain VERCEL_TOKEN), `projects[]` each
#                   {name, path, status_context, class: product|quiet, production_url}.
#                   Absent, or an empty `projects` array, reads as "not declared" — never an
#                   error: deploy-status.sh, env.sh and rollback.sh say so and stop.
#   reporting       object — message kinds → channels (agency brief §4.0). `announce_from`
#                   ("session" default — Release step 9 calls report.sh; "ci" — the reference
#                   release workflow calls it and the session records `deferred to CI`);
#                   `announce`, `alert`, `economics`: arrays of channel names (the seeded default
#                   is announce ["github-release"], the rest empty — an empty `alert` means a red
#                   CI job is the alert); `channels`: per-channel config carrying only the NAMES
#                   of environment variables, never a value.
#   migrations      object {path, reversible}. `path` is where timestamped migrations live
#                   (check-migrations.sh; a string or an array — the old top-level
#                   `migrations_path` is still read); `reversible` false (the default) scopes
#                   Release stop class 3 and makes rollback.sh warn that the schema moved forward.
#   support         object {tier: none|basic|retainer, failsafe_page, monitoring.sentry_dsn_env}
#                   — the after-handover line the deal agreed. setup.sh's Support section checks
#                   the fail-safe page and the Sentry key exist when tier is basic or retainer;
#                   Release step 4 stops (class 3) when they do not.
#   health_endpoint the URL (or an array of URLs) that answers 200 when production is up —
#                   health-check.sh GETs it once after the merge (Release step 9a). A project
#                   may carry its own as deploy.projects[].health_endpoint instead, or as well.
#                   Absent or empty reads as "not declared": health-check.sh says SKIP.
#
# Contract for callers (source after die() is defined; needs jq):
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/project.sh"
#   project_field <jq-path> [<default>]   prints the scalar at <jq-path> (e.g. `.docs_path`),
#                                         or <default> when the file or the key is absent.
#   project_list  <jq-path>               prints one array element per line, nothing when absent.
#   project_json                          the manifest's path (may not exist).
#   project_has   <jq-path>               returns 0 when the key exists and is neither null nor
#                                         an empty string/array/object — the "declared?" test.
#   deploy_projects                       prints one JSON object per line from deploy.projects[]
#                                         (empty when not declared).
#   deploy_token_env · deploy_platform · deploy_team
#                                         the deploy block's scalars with their defaults.
#   reporting_channels <kind>             the channel names mapped to announce|alert|economics,
#                                         one per line; the seeded default for announce is
#                                         github-release when the block is absent entirely.
#   reporting_channel_field <channel> <key> [<default>]
#                                         one value from reporting.channels.<channel>.
#   migrations_paths                      one path per line: migrations.path (string or array),
#                                         else the legacy migrations_path, else nothing.
#   migrations_reversible                 prints true|false (default false).
#   support_tier · support_failsafe · support_sentry_env
#                                         the support block's scalars with their defaults.
#   health_endpoints                      one URL per line: the top-level health_endpoint (string
#                                         or array), then every deploy.projects[].health_endpoint,
#                                         in that order, de-duplicated; nothing when none declared.
#   pipeline_lanes                        the lane vocabulary, space-separated — the one list
#                                         new-run.sh, resolve-run.sh, project-labels.sh,
#                                         close-out.sh, validate-intake.sh and triage-report.sh
#                                         read (bug tweak chore hotfix handover). Not a manifest
#                                         key: the lanes are the template's, not the repo's.
#   is_lane <word>                        returns 0 when <word> is one of pipeline_lanes.

declare -F die >/dev/null 2>&1 || die() { echo "error: $*" >&2; exit 1; }

# The repo root is two levels above .icm/scripts/lib/ — the same derivation every script uses.
_project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
# A caller may point this at another repo's manifest before sourcing (setup.sh, run from the
# template's copy against a bare repo); otherwise it is this repo's own.
project_json="${project_json:-$_project_root/.icm/project.json}"

if [ -f "$project_json" ] && ! jq -e . "$project_json" >/dev/null 2>&1; then
  die ".icm/project.json is not valid JSON — fix it before running the pipeline scripts"
fi

project_field() {
  local path="$1" default="${2:-}" value=""
  if [ -f "$project_json" ]; then
    value="$(jq -r "$path // empty" "$project_json" 2>/dev/null || true)"
  fi
  printf '%s' "${value:-$default}"
}

project_list() {
  [ -f "$project_json" ] || return 0
  jq -r "($1 // [])[]?" "$project_json" 2>/dev/null || true
}

project_has() {
  [ -f "$project_json" ] || return 1
  jq -e "($1) as \$v | \$v != null and (\$v | if type == \"string\" or type == \"array\" or type == \"object\" then length > 0 else true end)" \
    "$project_json" >/dev/null 2>&1
}

# --- deploy ------------------------------------------------------------------------------------------

deploy_platform()  { project_field '.deploy.platform' 'vercel'; }
deploy_team()      { project_field '.deploy.team_slug' ''; }
deploy_token_env() { project_field '.deploy.token_env' 'VERCEL_TOKEN'; }
deploy_projects() {
  [ -f "$project_json" ] || return 0
  jq -c '(.deploy.projects // [])[]?' "$project_json" 2>/dev/null || true
}

# --- reporting ---------------------------------------------------------------------------------------

reporting_channels() { # announce|alert|economics
  local kind="$1"
  if [ -f "$project_json" ] && jq -e '.reporting' "$project_json" >/dev/null 2>&1; then
    jq -r "(.reporting[\"$kind\"] // [])[]?" "$project_json" 2>/dev/null || true
  else
    # No reporting block at all: the seeded default — a Release on every merge, nothing else.
    [ "$kind" = "announce" ] && echo "github-release"
  fi
}
reporting_channel_field() { # <channel> <key> [<default>]
  project_field ".reporting.channels[\"$1\"][\"$2\"]" "${3:-}"
}

# --- migrations --------------------------------------------------------------------------------------

migrations_paths() {
  [ -f "$project_json" ] || return 0
  jq -r '
    (.migrations.path // .migrations_path // empty)
    | if type == "array" then .[] else . end
    | select(. != "")' "$project_json" 2>/dev/null || true
}
migrations_reversible() {
  local v; v="$(project_field '.migrations.reversible' 'false')"
  case "$v" in true) echo true ;; *) echo false ;; esac
}

# --- support -----------------------------------------------------------------------------------------

support_tier()       { project_field '.support.tier' 'none'; }
support_failsafe()   { project_field '.support.failsafe_page' ''; }
support_sentry_env() { project_field '.support.monitoring.sentry_dsn_env' 'SENTRY_DSN'; }

# --- health ------------------------------------------------------------------------------------------

health_endpoints() {
  [ -f "$project_json" ] || return 0
  jq -r '
    [ (.health_endpoint // empty | if type == "array" then .[] else . end),
      ((.deploy.projects // [])[]? | .health_endpoint // empty) ]
    | map(select(type == "string" and . != ""))
    | reduce .[] as $u ([]; if index($u) then . else . + [$u] end)
    | .[]' "$project_json" 2>/dev/null || true
}

# --- lanes -------------------------------------------------------------------------------------------
# The one vocabulary list. bug/tweak/chore open draft; hotfix opens READY (an incident wants the
# full gate and the previews at once); handover is the deal's last lane (lanes/handover/CONTEXT.md).
pipeline_lanes() { printf '%s' "bug tweak chore hotfix handover"; }
is_lane() {
  local w
  for w in $(pipeline_lanes); do [ "$w" = "$1" ] && return 0; done
  return 1
}

# Every script that archives or looks up archived runs reads these two — repo-relative, no
# trailing slash. The defaults are the estate's own convention (contracts/TICKETS.md).
runs_archive_rel="$(project_field '.runs_archive' '.icm/runs/_done')"
intake_archive_rel="$(project_field '.intake_archive' '.icm/intake/_done')"
runs_archive_rel="${runs_archive_rel%/}"
intake_archive_rel="${intake_archive_rel%/}"

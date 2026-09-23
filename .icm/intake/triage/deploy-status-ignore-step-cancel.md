# Stub: deploy-status.sh reads an ignore-step CANCELED deployment as "not created" → PENDING

- lane: bug
- found-by: remi-ai pipeline sync · 2026-09-23
- priority: P3
- complexity: medium

## Problem

On remi-ai the merge `83e651d` — an `.icm/`-only change — produced a production deployment on
all six Vercel projects that the ignore step (`turbo-ignore`) created and immediately CANCELED.
`deploy-status.sh --sha 83e651d` reported every project as "no production deployment of
83e651d yet (not created, or filtered by an ignore step)", waited its full timeout and ended
`RESULT: PENDING` (exit 4). The cause: `vercel_deployments <name> --target production --sha
<sha>` (`GET /v6/deployments?…&sha=`) returns nothing for those deployments, while the same
call without `--sha` lists them with `meta.githubCommitSha` = the SHA and `state: CANCELED`.
So any Release whose merge touches no app — docs-only, `.icm`-only, a chore in a package no
project builds — waits the timeout and records PENDING instead of "skipped by the ignore step".
And where the SHA filter does match, CANCELED is classed with ERROR (exit 3, "see the hotfix
lane") — an ignore-step cancel is not an incident.

## Proposed change

When the SHA filter finds nothing, fall back to the project's newest few deployments and
match `meta.githubCommitSha` by hand. Treat a CANCELED deployment the ignore step canceled as
`SKIPPED (ignore step)` — production's word is then the previous READY deployment, which is
still what `rollback.sh --vercel` names — and reserve ERROR for a build that ran and failed or
was canceled by a person. One `- production:` line shape for the skip; a fixture case for
each branch.

## Prompt

In the icm-board repo (`~/Apps`), read `.icm/intake/triage/deploy-status-ignore-step-cancel.md`,
then `_system/template/icm-pipeline/scripts/deploy-status.sh` and `scripts/lib/vercel.sh`.
Reproduce against remi-ai on Jamie's machine: `VERCEL_TOKEN_REMI21` is exported in his `.zshrc`
(never print it); from `projects/remi-ai` run `.icm/scripts/deploy-status.sh --sha 83e651d
--no-wait`, then list `app`'s newest deployments through `lib/vercel.sh` and compare. Fix the
template-owned script in the template, prove it on the fixture and on remi-ai (read-only), and
ship it through a PR on a `claude/` branch; the fix reaches the repos by `icm-sync.sh`. Do not
edit `projects/remi-ai/.icm/scripts/deploy-status.sh` in place.

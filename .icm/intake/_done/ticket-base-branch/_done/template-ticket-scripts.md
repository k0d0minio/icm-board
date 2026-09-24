# Stub: The template's scripts and workflows read and guard the ticket base branch

- feature-slug: template-ticket-scripts
- epic: ticket-base-branch
- priority: P1
- size: M
- depends-on: ticket-base-contract
- sequence: 2 of 4
- sources: breakdown · `_system/template/icm-pipeline/scripts/client-status.sh:71` (queue read
  from `origin/main`) · `_system/template/claude/hooks/wrap-reminder.sh:41-44` (compares
  `origin/main`) · `_system/template/github-pipeline/workflows/release.yaml` (announces any PR
  merged into the default branch; a PR with no slug line goes out as `pr-<n>`) ·
  `_system/template/icm-pipeline/scripts/new-run.sh:180` (comment: "the intake cut lives on main")

## Problem

With the rule rewritten (stub 1), the template's code still assumes `main`: the client status
report misses stubs cut on `uat`, the wrap reminder compares against the wrong branch, and on a
repo announcing from CI a merged ticket PR would reach the client as a release.

## Proposed change

- `client-status.sh`: the queued/open section reads `origin/<pipeline_base_branch>`; "delivered"
  stays the archive on `main` and "on UAT" stays as it is.
- `wrap-reminder.sh` (template and icm-board's copy): compare against `origin/<base>` — the base
  read from `.icm/project.json` when present, `main` otherwise (the hook must work in repos with no
  `.icm/scripts/`); its message says "the board reads the ticket base branch".
- `release.yaml`: skip a PR labelled `type:tickets` (belt and braces with `announce: none`).
- `labels.yaml` / the label set `setup.sh` reports: add `type:tickets`; the label is the
  operator's act `setup.sh` names.
- `new-run.sh` and `promote-uat.sh`: comments and messages that call `main` the home of the intake
  cut; `promote-uat.sh sync` names the knowledge lane beside the hotfix.
- Define decides whether a small `ticket-pr.sh` (branch + label + body + path-guard check + immediate merge) earns its
  place. The hand procedure in `pr-conventions` stays the contract either way, because most client
  repos have no `.icm/scripts/`.
- Optional, for cost only: document an `.icm/`-only ignore step in `_shared/ci.md` as a recipe
  (per-repo `vercel.json`). The merge never waits for it.

## Acceptance criteria (rough)

- [ ] A fixture with `uat` declared: a stub on `origin/uat` only shows in `client-status.sh`'s queue
- [ ] `wrap-reminder.sh` on a branch cut from `origin/uat` reports nothing spurious
- [ ] `release.yaml` does not announce a merged `type:tickets` PR (proved on a fixture or dry run)
- [ ] `self-check.sh` and the template's validators green in CI

## Prompt

In icm-board (`~/Apps`), carry out stub 2 of the `ticket-base-branch` epic: read
`.icm/intake/ticket-base-branch/breakdown.md` and `template-ticket-scripts.md`, and the D38 entry
in `.icm/project.md` that stub 1 recorded. Change the template's scripts, hooks and workflows under
`_system/template/` (and icm-board's own `.claude/hooks/wrap-reminder.sh`) so they read and guard
each repo's ticket base branch (`lib/project.sh → pipeline_base_branch`) instead of assuming
`main`, as the stub lists. Prove each change on a scratch fixture repo, not on a client repo. Never
run build/lint/test locally; ship as a PR on a `claude/` branch and read CI.

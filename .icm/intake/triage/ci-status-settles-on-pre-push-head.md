# Stub: ci-status.sh can settle GREEN on the pre-push head instead of the pushed one

- lane: chore
- found-by: jamienisbet run `board-client-state`, Build step 12 · 2026-09-24 · template-change
  guard (D33) — full account in
  `projects/jamienisbet/.icm/intake/triage/template-change-ci-status-stale-head.md`
- priority: P2
- size: S

## Problem

`ci-status.sh` is a T-file (`_system/template/icm-pipeline/scripts/ci-status.sh`, synced into
every pipeline repo as `.icm/scripts/ci-status.sh`). Its settle loop re-reads the PR's head only
to catch a push landing *mid*-wait — nothing compares the PR's `head.sha` against the commit the
caller just pushed before the loop starts. In jamienisbet's run: `git push` of c30d339 (the
post-flip push) immediately followed by `ci-status.sh board-client-state` — the first PR read
still returned the previous head e90bae9 (GitHub hadn't moved the PR yet), whose checks had all
already settled, so the script printed `RESULT: GREEN` about the pre-push head. A second call a
minute later correctly settled on c30d339. A GREEN about the wrong head lets Build hand over (and
Release merge on) a verdict about code that isn't actually the branch.

## Proposed change

Per the jamienisbet stub's brief: when the script runs inside a checkout of the run's branch
(`run.md` → `- branch:` equals `git rev-parse --abbrev-ref HEAD`) and the local head is pushed
(`git rev-parse HEAD` == `git rev-parse @{upstream}`), treat that SHA as the expected head. If
the PR's `head.sha` differs, print `waiting for GitHub to register <sha7> on PR #<n>` and keep
polling (within the existing timeout) until it matches, before reading any signal. On timeout,
`RESULT: PENDING` naming the expected SHA. Outside a matching checkout (or unpushed local head),
behave as today. Add a fixture: PR head = old SHA with all checks green, local pushed head = new
SHA → verdict must not be GREEN until the PR head moves.

Read `_system/contracts/PIPELINE.md` → File-level ownership before touching the T-file.

## Prompt

In the icm-board repo (`~/Apps`), fix `_system/template/icm-pipeline/scripts/ci-status.sh` so its
settle loop never verdicts on a PR head that predates a push the caller just made. Read
`.icm/intake/triage/ci-status-settles-on-pre-push-head.md` for the full problem and the proposed
change, and `projects/jamienisbet/.icm/intake/triage/template-change-ci-status-stale-head.md` for
the original finding. Read `_system/contracts/PIPELINE.md` → File-level ownership first. Prove it
with a fixture (PR head = stale SHA, all checks green; local pushed head = new SHA → verdict must
not be GREEN until the PR head moves), or a read-only run against `projects/jamienisbet` on
Jamie's machine. Ship through a PR on a `claude/` branch. Do not edit
`projects/jamienisbet/.icm/scripts/ci-status.sh` in place — after merge, bring the fix back with
`_system/scripts/icm-sync.sh --apply projects/jamienisbet` (and the other pipeline repos as
`/icm-check` lists them), and retire
`projects/jamienisbet/.icm/intake/triage/template-change-ci-status-stale-head.md` to jamienisbet's
`_done/` in that sync commit. Move this stub to triage's `_done/` in the same commit.

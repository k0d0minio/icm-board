# Stub: neon-cleanup misses a run's Neon branch when the PR's branch is harness-named

- feature-slug: neon-cleanup-harness-branch-run
- lane: bug
- priority: P1
- found-by: the D41 read-back on agorasim, 2026-09-24 (stub 5 of `one-branch-two-targets`)
- sources: agorasim `db-env.sh status` → `run/quote-page-and-deposit-link` in production's
  project `nameless-sea-98952497` (created 2026-09-24 11:29Z) · k0d0minio/agorasim#122, head
  `claude/sleepy-turing-k3vdjt`, merged 12:18Z · its `neon-cleanup` run log: `RUN_BRANCH:
  run/sleepy-turing-k3vdjt` → "not in the project — nothing to delete" ·
  `_system/template/github-pipeline/workflows/neon-cleanup.yaml:75`

## What this is

`db-branch.sh <slug> up` names a run's Neon branch `run/<slug>`, after the run folder. The
reference `neon-cleanup.yaml` guesses that name from the PR's head ref instead:
`run/${HEAD_REF#claude/}`. That only matches when the branch is `claude/<slug>`. A harness-named
branch (`claude/sleepy-turing-k3vdjt` — every cloud session, OpenCode, Actions; `new-run.sh`
accepts them and records the branch in `run.md`) never matches, so the run's branch outlives its
PR. The 7-day expiry `db-branch.sh` sets is then the only cleanup.

On agorasim the orphan predates D41, so it sits in production's project, and `setup.sh` warns
about it there. Under D41 the same miss would land in the non-production project: less harmful,
but still an orphan.

## Proposed change

`neon-cleanup.yaml` finds the run's slug from the branch rather than guessing it: sparse-check-out
`.icm/runs/*/run.md` and `.icm/runs/_done/*/run.md` (or whatever `runs_archive` names) beside
`.icm/project.json`, and take the folder whose `- branch:` line equals `HEAD_REF` (the same read
as `resolve-run.sh`'s `branch_from_run_md`). Keep today's `run/${HEAD_REF#claude/}` as the
fallback when no `run.md` names the branch. It deletes `preview/<HEAD_REF>` as today, and deletes
nothing that isn't `preview/*` or `run/*`. Prove it on a fixture: a harness-named branch whose
`run.md` names slug `x` → `RUN_BRANCH=run/x`. Then the estate's Neon repos take the reference file
by hand (it is seeded, not synced).

agorasim's orphan should expire on its own by 2026-10-01 if `db-branch.sh` set the expiry
(not read back). Deleting it sooner is Jamie's call: `lib/neon.sh` refuses writes in production's
project on a D41 repo.

## Prompt

In icm-board, fix triage stub `neon-cleanup-harness-branch-run` (read
`.icm/intake/triage/neon-cleanup-harness-branch-run.md` for the evidence): the reference
`_system/template/github-pipeline/workflows/neon-cleanup.yaml` must resolve a run's slug from the
`run.md` whose `- branch:` equals the PR's head ref, keeping `run/${HEAD_REF#claude/}` as the
fallback. Prove it on scratch fixtures, with no live Neon write. Open one PR on a `claude/` branch
that moves this stub to `triage/_done/`, and list the repos that need the reference file by hand.

## Closed

2026-09-24: the reference `neon-cleanup.yaml` sparse-checks-out `.icm/project.json` and every
`run.md`, reads `.icm/runs/*/run.md` and `<runs_archive>/*/run.md`, and deletes `run/<folder>` for
each run whose `- branch:` equals the PR's head ref (the `branch_from_run_md` read); only when none
does it guess `run/${HEAD_REF#claude/}`. Proven on eleven scratch fixtures against a stubbed `curl`
(no network, no live Neon write): the old file targets `run/sleepy-turing-k3vdjt` on agorasim#122's
shape, the new one `run/quote-page-and-deposit-link`; archived runs, a custom `runs_archive`, a
trailing `# comment`, two runs on one branch, a prefix-only near-miss (falls back), the D41
non-production project and `previews: none` all as intended; the `claude/<slug>` fallback output
identical to before. Unproven: a live PR close. **Seeded, not synced — copy by hand into agorasim
and berceo** (the two repos carrying it). vinecliff is `isolation: neon` with `previews: none`, so
it never got the workflow; its run branches rely on the 7-day expiry. agorasim's orphan
`run/quote-page-and-deposit-link` in production's project is untouched (Jamie's call).

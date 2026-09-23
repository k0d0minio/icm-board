# Stub: db-branch.sh prove — read a throwing `down` as "declared irreversible" where the repo says so

- lane: tweak
- found-by: db-branch-prove-runner-semantics · 2026-09-23
- priority: P2
- complexity: standard
- sources: `.icm/intake/triage/_done/db-branch-prove-runner-semantics.md` (item 3); the D35 run-log row in `.icm/project.md`

## Problem

`prove`'s static check ("every own file exports a `down`") passes a `down` that throws. That is
sustentus's convention for irreversible migrations: 6 of its 92 throw "irreversible", and 5 more
are deliberate no-ops. With `migrations.reversible: true`, such a migration on a branch gives
`UNPROVEN` ("reverting this branch's own migrations failed"). That verdict is correct for the
runner, but it gives the repo no way to mark one migration as intentionally one-way. The only
alternative today is `reversible: false`, which stops `prove` exercising any `down` at all.

A no-op `down` on a data-only migration reads PROVEN, which is right: the proof compares shape,
not data. A no-op `down` on a migration that changes shape reads UNPROVEN, also right.

## Proposed change

Decide how a repo declares a single migration irreversible. That decision is Jamie's. Options:
- a marker the proof can read without running anything (an `export const irreversible = true`,
  or a header comment the template names);
- a list in `.icm/project.json` (`migrations.irreversible: ["<name>", …]`);
- a throw with a fixed message prefix, matched in the runner's output.

Then, in `_system/template/icm-pipeline/scripts/db-branch.sh` `prove`: exclude a declared-
irreversible own migration from the round trip. It is still proven up and idempotent, and it is
named in the output as "declared irreversible", never silently passed. A migration older than it
cannot come down past it either. Re-prove on the fixture in the PR that shipped the seed-order
fix (scratch runner = ts-migrate-mongoose 4.2.2's `run`/`sync`, ported).

## Prompt

In icm-board, read `.icm/intake/triage/db-branch-prove-declared-irreversible.md` and the D35 row
of `.icm/project.md`. Ask Jamie how a repo declares one migration irreversible, and record the
answer as a decision. Then teach `db-branch.sh prove` to read that declaration: prove the
migration's up and idempotency, skip its down, and name it in the output. Ship it as a template
PR on a `claude/` branch, proven on a fixture whose runner follows ts-migrate-mongoose's semantics.

# Stub: db-branch.sh prove — match ts-migrate-mongoose's semantics, seed after migrate

- lane: bug
- found-by: sync-mongodb-databases-sustentus · 2026-09-23
- priority: P2
- complexity: standard

## Problem

D35's `prove` was proven only against a fixture runner. Reading `ts-migrate-mongoose@4.2.2`
(`Migrator.run`) and sustentus's migrations shows three places where the template and the real
runner disagree:
1. `up <name>` applies every pending migration with `createdAt` ≤ the named one's, and
   `down <name>` reverts every applied one with `createdAt` ≥ it. With `migrations.out_of_order:
   true`, an own migration stamped older than the base's newest is applied into the "base
   shape", and `down <first own>` also reverts base migrations. `prove` splits base and own by
   file name alone.
2. `up` and `prove` run `seed_command` before `migrate_command`, but sustentus's own workflow
   migrates first and seeds second. Its seed compiles Mongoose models, whose autoIndex builds
   the head's indexes asynchronously on the empty database. So the base snapshot can already
   hold the indexes the branch's migration creates, and snapshots race the builds. The result
   can be a false UNPROVEN.
3. The static "every own file exports a `down`" check passes a `down` that throws, which is
   sustentus's convention for irreversible migrations: 6 of its 92 migrations throw. Only
   running the `down` finds them.

## Proposed change

In `_system/template/icm-pipeline/scripts/db-branch.sh`:
- run the seed after the migrate (in `up` and in `prove`), or make the order a declared setting;
- when the stamps are out of order, walk the own migrations one at a time
  (`down <name>` per file, newest first), or refuse with a clear line;
- let `prove` read a `down` that throws as "declared irreversible", not missing, when the repo
  says so. This needs a decision on how a repo declares it.

Then re-prove on the fixture with a runner whose `up`/`down` follow `createdAt`, and settle it
with sustentus's first live `prove` (`triage/sync-mongodb-databases-sustentus`, step 3).

## Prompt

In icm-board, read `.icm/intake/triage/db-branch-prove-runner-semantics.md` and the D35 row
of `.icm/project.md`. Then fix `db-branch.sh prove`'s seed order and its out-of-order handling
against ts-migrate-mongoose's `createdAt` semantics, as a template PR on a `claude/` branch.
Prove it on a fixture whose runner follows those semantics.

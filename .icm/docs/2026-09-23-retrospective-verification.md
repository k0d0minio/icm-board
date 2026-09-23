# Retrospective Verification — the continuous-learning collector (directive of 2026-09-23)

*Executed against `2026-09-23-retrospective-directive.md` (Jamie; §1 is all that arrived — the
paste ends inside its example block). Branch `claude/retrospective-learning-engine-a83672` in
icm-board; nothing merged, nothing synced, no repo under `projects/` read for writing or edited.
No local build, lint, typecheck, test or format ran. Proofs come from a throwaway fixture repo in
the session's scratchpad, built from the template's own files. Decision recorded: D27 in
`.icm/project.md`.*

## 1. Outcome in one paragraph

A run that went RED, fixed it and went GREEN now writes down what it fixed, and the next run reads
it. The stage records each error where it fixes it — `error.log` in its own output folder, with a
dated `## ` header, the failing lines, a `- resolved:` line, and a `- rule:` line only for a
constraint of the repo. `retrospective.sh`, a template-owned script, reads that file at Release
step 7(b) and at the end of every lane, before the close-out moves the run: it gives each entry a
signature (the error class, never the instance), counts it across the archive's `error.log`s,
promotes a flagged or recurring, resolved entry to a candidate, skips what `project-rules.md`
already carries, reports, and with `--apply` appends each candidate under `## Learned rules` in
the project-owned `_shared/project-rules.md` — the directive's marker plus one bullet with its
provenance. It never judges, never commits, never reads outside the repo. Build and every lane
list `project-rules.md → Learned rules` in their Inputs, which is what closes the loop.

## 2. What changed where

| Where | What |
|---|---|
| `_system/template/icm-pipeline/scripts/retrospective.sh` | new, `T`: the signature ladder (TS code · Rust code · Biome rule · ESLint rule id · errno · `ERR_*` · exception class · module-not-found · Prettier `[warn]` · short lint code · first-line fallback), the archive walk, `--min` (default 2), the diff read for areas, the report, `--apply` inside `## Learned rules` wherever the section sits (created at the end when absent) |
| `_system/template/icm-pipeline/MANIFEST` | `T scripts/retrospective.sh` |
| `stages/03_build/CONTEXT.md` | Inputs: Learned rules · step 4: "Errors are recorded where they are fixed" · step 9 RED: record, fix, `- resolved:` · Outputs: the `error.log` shape · Verify: every entry resolved or handed over |
| `stages/04_release/CONTEXT.md` | Inputs: `error.log` · step 7(b): the retrospective before the record, `--apply`, the slip rule, committed with the record · the record's `- learned:` line · Verify |
| `lanes/{bug,tweak,chore,hotfix}/CONTEXT.md` | Inputs: Learned rules · the RED path writes `lane/output/error.log` · the retrospective before `close-out.sh` · `notes.md` gains `- learned:` · Verify |
| `_shared/project-rules.md` (P stub) | the `## Learned rules` section, last |
| `runs/README.md` (P stub) | `error.log` named beside `notes.md` |
| `_system/contracts/PIPELINE.md` · `_system/template/README.md` · seeded `pipeline/SKILL.md` step 6 | the script in the tree, the scripts table and the spine paragraph; the router's "a run ends at the merge" names it |
| `.icm/project.md` | D27; the run-log row |

## 3. The proofs — the fixture

The fixture: a git repo with `main`, an `origin/main` ref, `.icm/project.json` and the template's
`project-rules.md` stub, `lib/project.sh`, `lib/changed-files.sh` and `retrospective.sh` copied in;
two archived runs on `main` (`user-profile`, a spine run whose `error.log` carries a `TS2532` with a
`- resolved:` line; `fix-nav`, a lane run with `@typescript-eslint/no-unused-vars`); a live run
`checkout-flow` on `claude/checkout-flow` with a four-entry `error.log` (`TS2532` with a two-line
`- rule:`; `no-unused-vars` resolved; `ECONNREFUSED` with no trailer; a Go `undefined:` line
resolved) and a diff touching `apps/web/` and `packages/db/`; and a `clean-run` with no log.

| # | Command | What it proved | Last line |
|---|---|---|---|
| 1 | `retrospective.sh checkout-flow` | 4 entries parsed; the title line above the first `## ` ignored; signatures `TS2532`, `@typescript-eslint/no-unused-vars`, `ECONNREFUSED`, and the fallback `undefined: helpers.format` (marked "from the first line"); counts 2×/2×/1×/1× with the archive slugs named; #1 a candidate by `- rule:`, #2 by recurrence, #3 listed UNRESOLVED, #4 below `--min 2`; the diff read as `2 file(s) — areas: apps/web, packages/db` | `RESULT: CANDIDATES 2` |
| 2 | `… --apply` | the `## Learned rules` section created at the end of the stub; two entries appended in the directive's shape, the two-line rule joined, the provenance carrying signature, count, run slugs and areas | `RESULT: APPENDED 2` |
| 3 | `… checkout-flow` again | both signatures now "already a rule"; nothing appended twice | `RESULT: NONE` |
| 4 | `… fix-nav` (archived lane run) | resolves from the archive; reads `lane/output/error.log`; its signature is now a rule | `RESULT: NONE` |
| 5 | `… clean-run` | no `error.log` under either path | `RESULT: SKIP` |
| 6 | `… checkout-flow --min 1` | the resolved Go fallback promoted on its own; the unresolved entry still not | `RESULT: CANDIDATES 1` |
| 7 | `… nope` | unknown slug dies, exit 1 | `error: no run folder for 'nope' …` |
| 8 | `… --base origin/nothere` | an unresolvable base is a note, never a stop: `areas omitted` | `RESULT: CANDIDATES 2` |
| 9 | a hand-written `project-rules.md` with `## Learned rules` **not** last, an older rule inside it, and no trailing newline; `--apply --min 1` | the newline repaired; three entries inserted **inside** the section, after the older rule, before `## Capability skills …`; the following section untouched | `RESULT: APPENDED 3` |
| 10 | re-run after 9 | the fallback signature deduplicates on its backticked text too | `RESULT: NONE` |
| 11 | `… user-profile` from `main` | an archived run read while no branch is checked out: `no branch diff … areas omitted`; the live sibling `checkout-flow` is never read — `archive: 1 error.log(s)`, `seen 1×` | `RESULT: NONE` |
| 12 | `--help` · `--min 0` | the header printed, exit 0 · `--min needs a whole number of 1 or more`, exit 1 | — |

The appended block from proof 2, as it landed:

```md
<!-- Retrospective Learned Rule [2026-09-23] -->
- Always handle nullable `session.user` fields in API route handlers — guard, never assert with `!`. (`TS2532`, seen 2× — checkout-flow, user-profile; apps/web, packages/db)

<!-- Retrospective Learned Rule [2026-09-23] -->
- dropped the unused import (`@typescript-eslint/no-unused-vars`, seen 2× — checkout-flow, fix-nav; apps/web, packages/db)
```

The second line is the point of the report step: a `- resolved:` line promoted by recurrence reads
as a fix note unless Build wrote it as a rule — which is why Build step 4 now says "written as a
sentence the next run can act on", and why Release reads the candidates before `--apply` and
deletes a slip by hand.

`bash -n` passes. Every `MANIFEST` path resolves in the template (45 T · 8 P).

## 4. What is not proven

- **No real run has written an `error.log` yet.** The shape is a contract; the first Build that
  goes RED under it is the first real input. The signature ladder was exercised on TypeScript,
  ESLint, a Node errno and a Go line; the Biome, Rust, Python-exception, `ERR_*`, module-not-found,
  Prettier and short-code patterns are written against the tools' documented output and untested
  on real logs.
- **Not synced anywhere.** Sustentus and remi-ai carry it at their next `icm-sync.sh --apply`;
  until then their `setup.sh` reports `scripts/retrospective.sh` missing from the baseline (the
  known cost of any new `T` file, D22). The `## Learned rules` section is in the **stub** only —
  a repo seeded earlier gets the section from the script's first `--apply`, at the end of its
  file, which is fine; moving it is the operator's edit.
- **The template scripts have no CI lint.** `self-check.yml` shellchecks `_system/scripts/*.sh`
  and `_system/hooks/*.sh`, not `_system/template/icm-pipeline/scripts/`; `shellcheck` is not on
  this machine either. The script was read, not linted.
- **§2 onward of the directive never arrived.** Whatever it asked for is not here.

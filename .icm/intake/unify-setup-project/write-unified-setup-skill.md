# Stub: Write the merged skill — /setup runs the whole adoption ritual, intent-first

- feature-slug: write-unified-setup-skill
- epic: unify-setup-project
- priority: P0
- size: L
- depends-on: sync-lens-and-scout-agents, port-lenses-and-register-contract
- sequence: 3 of 5
- sources: `.icm/project.md` D45 · `_system/template/claude-pipeline/skills/setup/SKILL.md`
  (current `/setup`) · `workspaces/deliver/stages/project/CONTEXT.md` (current `/project`
  ritual) · the lourenco-botelho evidence (config questions answered before intent existed)

## Problem

This is the actual merge. Today `/setup` (mechanical: run `setup.sh`, ask config gaps, write
project-owned files) and `/project` (judgment: register, posture, interrogate, lens fan-out,
reconcile, ticket cut) are two separate procedures in two separate homes, and nothing
enforces which runs first. That let lourenco-botelho's config answers get locked in before
intent existed.

## Proposed change

Rewrite `_system/template/claude-pipeline/skills/setup/SKILL.md` as the single entry point,
folding both procedures into one, in this order:

1. Guards (repo not on disk, not on GitHub, no `.icm/`, uncommitted changes) — as `/project`'s
   step 0 today.
2. Register + posture (first run vs. re-run; state the posture — launch / maintenance /
   expansion — out loud) — as `/project`'s step 1a/1b.
3. `setup.sh --report` — read it, but **do not ask its config questions yet**.
4. Scan (cheap, structural) — as `/project`'s step 2.
5. Interrogate — intent first (`/project`'s step 3), *then* the config questions
   `setup.sh --report`'s `[FAIL]`/`[WARN]` lines raised in step 3, now answered with intent as
   context. This ordering is the fix for the actual bug — a config answer is never given
   before intent exists.
6. Analyse — lens fan-out via the now-synced `project-lens` agents (`/project`'s step 4).
7. Reconcile — intent in, tickets out (`/project`'s step 5), done by the session itself, never
   an agent.
8. Write — both halves: the project-owned files (`project.json`, `project-rules.md`,
   `knowledge-map.md`, format/lint stubs) *and* the register (`.icm/project.md`) *and* the
   ticket cut (`intake/`), each keeping its existing commit convention (ticket-only straight
   to `main`; project-owned files + register on the repo's own `claude/` branch PR).
9. Re-run `setup.sh` until `RESULT: OK` or every remaining line is a named decision — as
   today, plus a closing summary matching `/project`'s current Outputs shape (posture, intent
   changed?, epics/counts, picks for `today.md`, what's unanswered).

Keep `/setup`'s existing guarantees: no default template source, `--fix` never overwrites,
runnable with zero icm-board in view, works in any harness.

## Acceptance

- [ ] One skill file, `_system/template/claude-pipeline/skills/setup/SKILL.md`, contains the
      full procedure — no step tells the operator to go run a second command
- [ ] A dry run against a repo with no `.icm/project.md` and no `.icm/scripts/setup.sh`
      produces both a project-owned-files PR and a ticket cut, in the right order, without
      ever asking a config question before intent is stated
- [ ] `setup.sh` itself is untouched — this stub only changes the skill layer that asks
      questions and orchestrates, not the deterministic checks

## Prompt

Read `.icm/intake/unify-setup-project/write-unified-setup-skill.md` and
`.icm/intake/unify-setup-project/breakdown.md`. Confirm `sync-lens-and-scout-agents` and
`port-lenses-and-register-contract` have landed first. Rewrite the `/setup` skill to the
merged, intent-first procedure described above, reading both current source procedures in
full before starting.

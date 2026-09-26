# Stub: Retire icm-board's /project, sync the merged skill across the estate

- feature-slug: retire-project-command-and-rollout
- scope: unify-setup-project
- priority: P2
- size: M
- depends-on: prove-on-one-repo
- sequence: 5 of 5
- sources: `.icm/project.md` D45 · `.claude/commands/project.md` ·
  `workspaces/deliver/stages/project/CONTEXT.md` · `AGENTS.md` routing table

## Problem

Once the merged skill is proven, icm-board's own `/project` command and its stage contract
are redundant for any repo that's been synced — but retiring them outright before every repo
is synced would strand repos still on the old split.

## Proposed change

- `icm-sync.sh --apply` the new skill (and the two newly-synced agents) across the estate,
  one repo at a time — same cadence as every other template rollout here (each repo gets its
  own PR).
- Once a repo is synced, its adoption/maintenance runs go through the in-repo command, not
  `/project`.
- Retire `.claude/commands/project.md` and `workspaces/deliver/stages/project/CONTEXT.md` only
  after every repo in the estate carries the merged skill — until then, keep `/project` as the
  fallback for repos not yet synced, and say so in `AGENTS.md`'s routing table.
- Update `AGENTS.md`'s routing table and this repo's own `CONTEXT.md` to point at the in-repo
  command as the primary path.

## Acceptance

- [ ] Every pipeline repo carries the merged skill (`icm-check.sh` reports no drift on it)
- [ ] `/project` and its stage contract are removed, or explicitly marked fallback-only with a
      reason, matching actual rollout state
- [ ] `AGENTS.md` routing table reflects the new primary path

## Prompt

Read `.icm/intake/unify-setup-project/retire-project-command-and-rollout.md` and
`.icm/intake/unify-setup-project/breakdown.md`. Confirm `prove-on-one-repo` landed. Sync the
merged skill across the estate one repo at a time; retire `/project` only once every repo
carries it, and update the routing docs to match reality at each step.

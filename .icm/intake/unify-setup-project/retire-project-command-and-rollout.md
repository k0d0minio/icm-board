# Stub: Retire icm-board's /project, sync the merged skill across the estate

- feature-slug: retire-project-command-and-rollout
- scope: unify-setup-project
- priority: P2
- size: M
- depends-on: prove-on-one-repo
- sequence: 5 of 5
- sources: `.icm/project.md` D45 · `prove-on-one-repo` Outcome (2026-09-28) · `.claude/commands/project.md` ·
  `workspaces/deliver/stages/project/CONTEXT.md` · `AGENTS.md` routing table

## Problem

Once the merged skill is proven, icm-board's own `/project` command and its stage contract
are redundant for any repo that's been synced — but retiring them outright before every repo
is synced would strand repos still on the old split.

## Proposed change

- Bring each repo current, one at a time, straight to `main` like every template fan-out:
  `icm-sync.sh --apply` for the `.icm/` T files (`_shared/lenses.md`, `_shared/register.md`),
  `icm-check.sh --fix --repo` for the two agents (created when missing), and a **hand copy**
  of `.claude/skills/setup/SKILL.md` — and of `ticket-craft` where it lags — because neither
  script ever overwrites a `.claude/` asset (D7). `prove-on-one-repo` did exactly this on
  lourenco-botelho (e9ff070).
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

## Progress — 2026-09-29

Rollout, straight to `main` (template 3451ff6; the `.icm/` T files by `icm-sync.sh --apply`,
`setup` + `ticket-craft` by hand): berceo 44b9ea9 · casey-hebbel d4aa151 · remi-ai cf330b9 ·
vinecliff 2d793bc · jamienisbet accc05e (its `.icm/` was already current). agorasim (9706df4)
and lourenco-botelho (e9ff070) were synced earlier. sustentus goes by PR
(sustentus/sustentus#1238): the same copies plus the two agents, which its Prettier had
rewritten — they join its `.prettierignore` so a sync stays byte-identical. serviflow is
hands-off (moved out of the estate, 2026-09-26) and is not a target.

Routing now points at the in-repo `/setup` (`AGENTS.md`, `CONTEXT.md`); `/project` and its
stage contract are marked fallback-only. Not retired yet, for two reasons:
- #1238 is unmerged, so sustentus's `main` does not carry the skill yet.
- `/project` still has a job the in-repo `/setup` cannot do for itself: adopting one of the
  ~25 repos with no `.icm/MANIFEST`. Seeding the pipeline needs icm-board's template.
  Retiring `/project` means either adopting all of them or moving that seed step elsewhere
  (e.g. `/icm-check` or `/client` stage 07). **Open question for Jamie.**

Unrelated drift that the rollout surfaced but did not touch: `route-request.sh` (+test) differs
from the template in every pipeline repo (#102 has not been fanned out), and `.icm/CONTEXT.md` /
`intake/README.md` baseline drift persists (D45 stub).

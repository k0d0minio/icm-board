# Stub: one command that initiates and maintains a repo — merge /setup and /project?

- lane: chore
- found-by: Jamie, lourenco-botelho adoption · 2026-09-25
- priority: P2
- complexity: high
- settled: 2026-09-25 — decided with Jamie; recorded as **D45** in `.icm/project.md`; cut as
  epic `unify-setup-project`

## Problem

Jamie's proposal (2026-09-25): `/setup` and `/project` should become one maintenance or sync
command, so a repo is properly initiated for the pipeline and then kept that way. Today the
split is D23: `/setup` lives in the repo and fills the project-owned config on a `claude/` PR;
`/project` lives here and handles intent, lenses and tickets, with `/setup` as its §1c
precondition. Adopting a repo now takes four steps across two homes (`icm-sync.sh --apply` +
`icm-check.sh --fix` here, `/setup` there, `/project` here). The lourenco-botelho run showed
where the seam hurts. `/project` overturned two answers `/setup` had recorded an hour earlier:
the `editor` persona (Studio retired, D5 there) and `production_url` (www only redirects).
Both became extra commits on the open setup PR (k0d0minio/lourenco-botelho#7). Neither command
noticed the stale baseline copies (`triage/baseline-copies-drift-unreported`).

## Proposed change

investigate. Weigh one command against D23's reasons: `/setup` must run in a cloud session
that has no icm-board, and the project-owned files are the repo's own. Candidate shapes:
- `/project` runs `/setup`'s question round in the repo when §1c reports gaps, and asks
  intent first so config answers follow it.
- One in-repo `/sync` that does template sync, `setup.sh --fix` and the setup questions, with
  `/project` left as intent and tickets only.
- Keep the split, but reorder `/project` so intent comes before `/setup`'s questions on a
  first adoption.

Decide with Jamie and record a decision (D-number); cut the change as an epic if he wants it.

## Outcome

Neither of the two reorder-only shapes fixed the actual bug (a config answer locked in
before intent exists), and the `/sync` shape didn't either while costing the most churn. Jamie
chose full fusion: one skill file, in the repo, synced to every repo, running intent-first —
`/project`'s whole ritual (register, posture, interrogate, lens fan-out, reconcile, ticket cut)
ported into the template and merged with `/setup`'s existing checks, replacing both entry
points with one. Recorded as **D45**. Cut as the epic
[`unify-setup-project`](../../unify-setup-project/breakdown.md) (five stubs: sync the lens/scout
agents, give the lens roster and register a template-owned home, write the merged skill, prove
it on one repo, then retire `/project` and roll out).

## Prompt

Read .icm/intake/triage/merge-setup-and-project.md, decision D23 in .icm/project.md,
workspaces/deliver/stages/project/CONTEXT.md, _system/template/claude-pipeline/skills/setup/SKILL.md
(or wherever the canonical /setup skill lives under _system/template/) and the lourenco-botelho
adoption evidence it cites. Lay out for Jamie the options for merging or reordering /setup and
/project so a repo is initiated and maintained by one entry point, with what each breaks
(cloud sessions without icm-board, project-owned file ownership, D22/D23). Recommend one. Do
not edit any command or contract until he chooses. Ticket-only commits go straight to main.

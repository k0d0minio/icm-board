# Stub: `courseday` and `pierpont` are in the estate but never adopted

- feature-slug: courseday-pierpont-unadopted
- lane: chore
- priority: P2
- sources: found during push-gate-propagation, 2026-09-03 · `icm-check.sh` reports
  them as the estate's only two GAP repos

## What this is

`projects/` now holds **26** repos. The survey that scoped the opencode-executor epic
on 2026-09-02 counted 24, and every stub in that epic is written against that number.
The two extra — `courseday` (k0d0minio/courseday) and `pierpont` (k0d0minio/pierpont)
— are real git repos with remotes, clean trees, and `main` checked out, but they have
never been adopted:

- no `.icm/` at all — no `CONTEXT.md`, `intake/`, `intake/triage/`, `intake/_done/`,
  `docs/`
- no `AGENTS.md`, so no Layer 0 and no `CLAUDE.md` importer
- no `opencode.jsonc`, so no rails and no push gate

They are the only two repos `icm-check` reports as GAP; the other 24 are conformant.

They were **out of scope for push-gate-propagation**, which was scoped to repos
*carrying* the rails file — there was nothing to narrow. They are also not baseline
violations in the conformance sense: `icm-check` only requires the root bundle once a
repo carries `AGENTS.md`, so an un-migrated repo is measured as it always was.

What they are is unadopted. Nothing knows what either repo is for, whether either is
live, or whether either should be dormant like the repos marked build-once-hand-off.

## Proposed change

Run `/project` against each. That writes the `.icm/project.md` register from an actual
interrogation of intent, which is the thing no template can seed. Adoption then decides
the rest: if a repo is live it gets the baseline and the rails (and with them the
narrowed push gate); if it is finished, mark it dormant rather than dressing it.

Worth checking first whether either is a client repo the admin dashboard created via
`createClientRepo` and nobody adopted, or a scratch clone that should not be under
`projects/` at all.

## Acceptance criteria (rough)

- [ ] Both repos interrogated; `.icm/project.md` written or the repo marked dormant
- [ ] Live repos carry the baseline, `AGENTS.md` + importer, and the rails file with
      the narrowed push gate
- [ ] `icm-check` reports 0 GAP repos, or the remaining gaps are deliberate and recorded

## Prompt

Run on Jamie's machine — `projects/*` is local-only. Read
`.icm/intake/triage/courseday-pierpont-unadopted.md` in the icm-board repo (`~/Apps`).
`projects/courseday` and `projects/pierpont` are git repos that were never adopted: no
`.icm/`, no `AGENTS.md`, no `opencode.jsonc`, and they are the only two repos
`icm-check.sh` reports as GAP. Work out what each one is first — ask Jamie rather than
guessing — then run `/project` against each and either adopt it properly (baseline,
Layer 0, rails with the `claude/*` push gate) or mark it dormant. One PR per repo on a
`claude/` branch; CI is the source of truth, no local checks.

# ICM-014 · Decide whether git becomes the write model for business state

| | |
|---|---|
| Status | ready |
| Type | decision |
| Priority | P2 |
| Size | S |

## Problem

[ICM-012](ICM-012-neon-at-the-gate.md) removes the staleness — Neon learns at the gate
instead of whenever the dashboard next gets opened. It deliberately does not answer the
larger question underneath it: **should the deal folder be authoritative for business
state, with Neon reduced to a read model the dashboard serves?**

The case for it is real. Nearly all the deciding happens in sessions and lands in git
already. Git gives history, review, blame and rollback over business state; a
`last_touched_at` column gives none of that. The dashboard could stay fully interactive by
writing through the GitHub API — becoming a nicer editor for the repo rather than a second
store — while public form submissions still land in Neon first, because a contact form
cannot commit to git.

The case against is the bill, which is not mostly code:

- `CLIENTS.md` states business state is *"never mirrored into git."* Direct
  contradiction — it would need amending.
- `WORKSPACES.md` states the folder mirrors the rung *"for legibility; the dashboard row
  **is** the status."* Inverted — it would need amending.
- `WORKSPACES.md` also states *"the scheduled workflows report and never write."* A
  git→Neon projector writes. That is a standing rule, and per `CLAUDE.md` a rule the repo
  exempts itself from is a rule it should delete — so this needs a recorded decision, not
  a quiet exception.
- Dashboard writes go from instant to a commit round-trip, and GitHub being down means
  the dashboard cannot write.

None of that is a reason to refuse. Three contract amendments and a recorded decision is a
normal price for a deliberate architecture change. It is a reason not to pay it by
accident, halfway, while shipping something else.

## Build

Not code. A decision, argued once and recorded in
[`.icm/project.md`](../project.md) alongside D3, with either:

- **Yes** — the amendments to `CLIENTS.md` and `WORKSPACES.md` drafted, the never-writes
  rule explicitly narrowed or deleted, and follow-on tickets cut for the projector and the
  dashboard's write path; or
- **No** — recorded as such, with the reason, so it stops being reopened. ICM-012 stands
  as the answer and this ticket goes to `_done/`.

Worth deciding *after* ICM-012 has run for a few weeks: the honest input is how often the
folders and Neon actually disagree once the gate writes both, which
[ICM-013](ICM-013-deal-folder-drift-check.md) will be measuring.

## Acceptance

- [ ] A decision recorded in `.icm/project.md`, dated, with its reasoning
- [ ] If yes: contract amendments drafted and follow-on tickets cut
- [ ] If no: the reason is written down and this ticket is moved to `_done/`

## Prompt

Decide whether the deal folder becomes authoritative for business state, with Neon as a
read model.

Read `.icm/intake/ICM-014-decide-git-as-write-model.md` for both sides of the argument,
then `_system/contracts/CLIENTS.md`, `_system/contracts/WORKSPACES.md` and the standing
rules in `CLAUDE.md` — the change contradicts three written rules and the point of this
ticket is that they get amended deliberately or not at all.

This is a decision ticket, not a build. Do not implement anything. Do not decide it alone
— put the argument to Jamie and record what he decides in `.icm/project.md`. Do not tick
a gate or a checkbox on his behalf.

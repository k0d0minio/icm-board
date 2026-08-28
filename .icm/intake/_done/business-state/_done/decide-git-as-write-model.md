> Dropped: Jamie, 2026-08-28 — dropped without a ruling; Neon stays authoritative by default (CLIENTS.md unchanged). Re-ask only if real drift data ever argues.

# Stub: Decide whether git becomes the write model for business state

- feature-slug: decide-git-as-write-model
- epic: business-state
- priority: P2
- size: S
- depends-on: deal-folder-drift-check
- sequence: 3 of 3
- sources: recut from ICM-014 (original purged, D14 — the Problem above carries both sides)

## Problem

`neon-at-the-gate` removes the staleness but deliberately does not answer the larger
question: should the deal folder be authoritative for business state, with Neon reduced
to a read model the dashboard serves? The case for is real (the deciding already happens
in git; history, review, rollback). The bill is three contract amendments
(`CLIENTS.md`, `WORKSPACES.md` twice) and a recorded decision — a price to pay
deliberately, not by accident while shipping something else.

## Proposed change

Not code. A decision, argued once with Jamie and recorded in `.icm/project.md`: **yes**
(amendments drafted, follow-on stubs cut) or **no** (reason written down so it stops
being reopened). Worth deciding after `deal-folder-drift-check` has measured how often
the folders and Neon actually disagree.

## Acceptance criteria (rough)

- [ ] A decision recorded in `.icm/project.md`, dated, with its reasoning
- [ ] If yes: contract amendments drafted and follow-on stubs cut
- [ ] If no: the reason written; this stub moves to `_done/`

## Out of scope (this feature)

- Implementing anything — this is a decision stub.

## Prompt

Decide whether the deal folder becomes authoritative for business state, with Neon as a
read model. Read .icm/intake/business-state/decide-git-as-write-model.md for both sides,
then _system/contracts/CLIENTS.md, _system/contracts/WORKSPACES.md and the standing
rules in CLAUDE.md. This is a decision stub, not a build. Do not decide it alone — put
the argument to Jamie and record what he decides in .icm/project.md. Do not tick a gate
or a checkbox on his behalf.

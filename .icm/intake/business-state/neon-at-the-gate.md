# Stub: Write Neon at the gate, from the session

- feature-slug: neon-at-the-gate
- epic: business-state
- priority: P1
- size: M
- depends-on: none
- sequence: 1 of 3
- blocked: JN-028 in jamienisbet (the token-authed mutations API) must merge and deploy first
- sources: recut from ICM-012 (original purged, D14) · decided 2026-08-27

## Problem

Every stage contract ends with Jamie recording something on the dashboard — value, rung,
repo — as a separate browser errand after the thinking is done, so the authoritative
store learns last or never. On 2026-08-27 alix-hahusseau was quoted €7,500 fixed-price,
committed and merged, and the Neon row still says the deal is unpriced. Decided: the
session writes Neon at the moment the gate is ticked; which store is authoritative does
not change.

## Proposed change

`_system/scripts/biz.sh` — a session-side client for the JN-028 API, matching the house
script shape: `biz clients` / `biz client <name>` reads; `biz set-rung` ·
`biz set-deal --value --billing --type` · `biz set-repo` · `biz work-started` ·
`biz touch` writes. Deal-folder names resolve to client ids; the bearer token comes from
the environment only and absence fails loudly. Then amend five stage contracts
(`sell/01_intake`, `sell/03_quote`, `start/05_onboarding`, `start/06_repo`,
`deliver/day`) so each gate that said "Jamie records X on the dashboard" says **Jamie
decides X; ticking the gate writes it** — still a human checkbox.

## Acceptance criteria (rough)

- [ ] `biz.sh` reads and writes through the API, never through `DATABASE_URL`
- [ ] Absent/invalid token fails with a clear message and no partial write
- [ ] Ambiguous or unknown deal-folder names fail rather than guess
- [ ] The five stage contracts name the write at their gate, each still ≤80 lines
- [ ] alix-hahusseau carries €7,500 / fixed-price in Neon, written this way
- [ ] Nothing advances a stage, changes a rung on its own, or sends anything

## Out of scope (this feature)

- Git as the write model — that is `decide-git-as-write-model`, deliberately separate.

## Prompt

Give sessions a way to write Neon at the moment a stage gate is ticked, so the
authoritative store stops learning last. Read
.icm/intake/business-state/neon-at-the-gate.md for full context, then
_system/contracts/CLIENTS.md and _system/contracts/WORKSPACES.md — both stay true and
constrain this. JN-028 in k0d0minio/jamienisbet must be merged and deployed first. The
line that must not be crossed: this records decisions, it never makes them. Open a PR on
a claude/ branch; do not run local checks — CI is the source of truth.

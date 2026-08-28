> Recut as business-state/neon-at-the-gate (2026-08-28 pipeline rework, decision D10 — path identity)

# ICM-012 · Write Neon at the gate, from the session

| | |
|---|---|
| Status | ready |
| Type | feature |
| Priority | P1 |
| Size | M |

## Problem

The work that moves a deal along happens here, in sessions. The recording of it happens
somewhere else, later, by hand — and so it mostly does not happen.

Every stage contract ends the same way. `sell/03_quote`'s gate says *"Records value/shape
on the dashboard deal card"*; `01_intake` ends at rung `talking`; `start/06_repo` sets the
repo. Each is a separate errand in a browser tab, after the thinking is already done and
written down. On 2026-08-27 `workspaces/deals/alix-hahusseau/` was quoted at €7,500
fixed-price, committed, and merged — and the Neon row still says the deal is unpriced.

Neon is authoritative for business state
([CLIENTS.md](../../../_system/contracts/CLIENTS.md)) and the deal folder mirrors the rung
*for legibility* ([WORKSPACES.md](../../../_system/contracts/WORKSPACES.md)). That contract
is right and stays. What is broken is only the *latency*: the authoritative store learns
last, or never.

Decided 2026-08-27: close the gap by having the session write Neon at the moment the gate
is ticked, rather than flipping which store is authoritative. The larger question — git as
the write model — is [ICM-014](ICM-014-decide-git-as-write-model.md), deliberately
separate.

## Build

Depends on `JN-028` in `k0d0minio/jamienisbet`, which exposes the mutations over HTTP.
This ticket is the calling side.

A small session-side client — `_system/scripts/biz.sh`, matching the six scripts already
there — that talks to the API with a bearer token from the environment:

- `biz clients` / `biz client <name>` — read, for reconciliation and `/day`
- `biz set-rung <name> <status>` · `biz set-deal <name> --value --billing --type` ·
  `biz set-repo` · `biz work-started` · `biz touch`

It resolves a deal-folder name to a client id by reading the folder, so the caller says
`alix-hahusseau`, not a UUID. Token comes from the environment only, never a file in the
repo; the script fails loudly with an instruction when it is absent, and never prompts for
it.

Then the stage contracts change — this is the part that matters, and it is small. Each
gate that today says "Jamie records X on the dashboard" instead says: **Jamie decides X;
ticking the gate writes it.** The wording stays a human checkbox. Nothing advances a
stage, nothing decides a rung, nothing sends. The session records a decision that has
already been made and gated — it does not make one.

Stages to amend: `sell/01_intake` (rung), `sell/03_quote` (value + shape),
`start/05_onboarding` (work started), `start/06_repo` (repo), and `deliver/day` (touch).

## Acceptance

- [ ] `biz.sh` reads and writes through the API, never through `DATABASE_URL`
- [ ] Absent or invalid token fails with a clear message and no partial write
- [ ] A deal-folder name resolves to the right client row, and an ambiguous or unknown
      name fails rather than guessing
- [ ] The five stage contracts name the write at their gate, still as a human checkbox,
      each still ≤80 lines
- [ ] `alix-hahusseau` carries €7,500 / fixed-price in Neon, written this way
- [ ] Nothing in the script advances a stage, changes a rung on its own, or sends
      anything — `self-check.sh` still passes

## Prompt

Give sessions a way to write Neon at the moment a stage gate is ticked, so the
authoritative store stops learning last.

Read `.icm/intake/ICM-012-neon-at-the-gate.md` first, then
`_system/contracts/CLIENTS.md` and `_system/contracts/WORKSPACES.md` — both stay true
under this change and constrain it. `k0d0minio/jamienisbet` ticket `JN-028` must be
merged and deployed first; this is only the calling side.

The line that must not be crossed: this records decisions, it never makes them. No script
advances a stage, moves a rung on its own, or performs an outbound action — see the
standing rules in `CLAUDE.md`. Match the style of the six existing scripts in
`_system/scripts/`, all of which are read-only reporters today.

Open a PR on a `claude/` branch. Do not run local checks — CI is the source of truth.

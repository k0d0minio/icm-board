# Breakdown: Business state writes at the gate

- epic-slug: business-state
- sources: recut 2026-08-28 from ICM-012 · ICM-013 · ICM-014 (originals purged in
  the D14 clean slate) — the chain was already explicit in their cross-references

## What I understood

The work that moves a deal happens in sessions; the recording happens later, by hand, or
never — Neon (the authoritative store) learns last. First the session gets a way to
write Neon at the moment a human ticks a gate (recording decisions, never making them).
Then a drift check keeps the deal-folder mirror honest. Only after both have run for a
while is the standing question decided: does git become the write model, with Neon as a
read model — a decision that amends three written contracts or is recorded as "no".

## Build order

1. neon-at-the-gate — session-side `biz.sh` writes Neon when a gate is ticked — depends-on: none
2. deal-folder-drift-check — read-only DEAL.md ↔ Neon drift report, wired into /day — depends-on: neon-at-the-gate
3. decide-git-as-write-model — the recorded decision, argued once — depends-on: deal-folder-drift-check

## Out of scope (whole epic)

- Any script that advances a stage, moves a rung on its own, or performs an outbound
  action — the standing rules outrank this epic.
- The dashboard's write path (that is jamienisbet's JN-028, the API this epic calls).

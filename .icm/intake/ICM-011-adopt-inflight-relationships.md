# ICM-011 · Adopt every in-flight relationship into the deal pipeline

| | |
|---|---|
| Status | ready |
| Type | process |
| Priority | P1 |
| Size | M |
| Depends on | the second-brain PR (workspaces + /client adoption path) |
| Sources | Jamie, 2026-08-26: "I don't want to orphan them at all" · `workspaces/deals/README.md` § Adopted deals |

## Problem

The estate predates the sell/start workspaces: ~22 repos and a ladder of Neon rows at
every rung, none with a deal folder. Delivered work is fine (its doorway is `/project`;
no folder wanted), but any relationship currently **mid-sale or mid-start** — being
scoped, quoted, waiting on an answer, onboarding — has no home in the pipeline until it
is adopted at its true stage. Until this sweep runs once, the pipeline and reality
disagree about which deals exist.

## Acceptance

- [ ] Every `biz.clients` row at `new` or `talking`, and every `client` whose
      ConvertFlow gaps are not yet clear, either has an adopted deal folder at its
      true stage (per `workspaces/deals/README.md` § Adopted deals) or a recorded
      Jamie decision that none is needed (stale → `lost`/archive is a valid outcome)
- [ ] Real artifacts folded in with provenance lines; **no reconstructed stages, no
      invented history**
- [ ] Delivered clients confirmed folder-less — their gap is only a missing
      `/project` run where the conformance report already warns of one
- [ ] `DEAL.md` mirrors agree with the dashboard rung for every adopted deal

## Prompt

Run the one-time adoption sweep from the Apps root on Jamie's machine. Read
.icm/intake/ICM-011-adopt-inflight-relationships.md for context. With the admin
dashboard open (Neon is authoritative), walk the open ladder rungs with Jamie row by
row: for each in-flight relationship, run /client <name> — its adoption path creates
the deal folder at the true stage and folds in real artifacts with provenance; for
each stale row, archive per CLIENTS.md. Never reconstruct pre-system stages. Batch
the questions; leave commits for Jamie's review per the house branch rules.

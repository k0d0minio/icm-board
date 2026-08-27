# ICM-011 · Adopt every in-flight relationship into the deal pipeline

| | |
|---|---|
| Status | in-progress |
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

## Outcome — swept 2026-08-26

Run with Jamie against the live dashboard. Full record, including every decision and the
Neon actions still outstanding:
[`.icm/docs/2026-08-26-icm-011-adoption-sweep.md`](../../docs/2026-08-26-icm-011-adoption-sweep.md).

**9 deal folders adopted** — 6 for the rungs that were open at the start (`rui-matias`,
`alix-hahusseau`, `dragon`, `billy-carlson`, `alex-valexo` at `01_intake`; `casey-hebbel`
at `03_quote`), plus 3 orphans that had no Neon row at all: `karen` (Barzinho, lost),
`jerome` (Le Pavillon Vert, lost), `magali` (CollabImmo — the follow-on sale on a
delivered client).

**Folder-less by decision** — the 8 `client` rows, `messy-play` (a personal project, not
a relationship), and the build-once-hand-off sites.

**Not reconstructed** — no `01-intake.md` was invented anywhere. Only real artifacts were
folded in: Casey Hebbel's 20 questionnaire answers, and barzinho's five negotiation
documents, each carrying a provenance line.

Answers [`_system/AUDIT.md`](../../../_system/AUDIT.md) open question #7 — *"barzinho: is the
deal still live?"* No: quiet since 2026-07-08, marked lost.

Jamie performed the Neon actions the same day — three rows created, Max Rettich's terms
entered, and Sustentus closed as not-applicable (its delivery repo is in a different
GitHub org, a known limitation). The ladder was re-read afterwards: **every adopted
`DEAL.md` now mirrors a real rung.** Two changes came back with that re-read — Alex
Valexo moved to `lost`, and the two new rows supplied the contact names **Jerome** and
**Magali**, so those folders were renamed off their company slugs.

**The acceptance boxes above are left unticked deliberately** — they are Jamie's to tick.
The work behind all four is done and verified; the record says so in prose instead.

# start/07_kickoff — hand over to the delivery machine

One stage, one job: the deal becomes a running project. Ends the start workspace;
everything after is [`deliver/`](../../../deliver/CONTEXT.md) and the client repo's own
`.icm/`.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`references/kickoff-checklist.md`](../../references/kickoff-checklist.md) | The gaps + handover, in order |
| 3 | [`CLIENTS.md`](../../../../_system/contracts/CLIENTS.md) | The flags this stage clears |
| 4 | The whole deal folder, 01–06 | What was promised — /project must inherit it, not rediscover it |

## Process

1. **Copy the durable documents into the client repo:** proposal and discovery notes →
   `.icm/docs/` (provenance-stamped: "from icm-board deal <slug>, dates"). The deal
   folder keeps the originals.
2. **Run `/project <repo>` — first run.** The register is written from the deal's real
   documents per its adopt-never-fabricate rule; the scope in `03-quote.md` becomes the
   Features table's opening truth; open `[BLOCKER]`s that survived become Open
   questions or decision tickets.
3. First tickets are cut by `/project`, not here — this stage only guarantees the run
   happened and the deal's promises made it across.
4. Write `07-kickoff.md`: date, register commit, tickets cut, flags cleared, anything
   the sell/start run got wrong (→ edit-source: amend the reference file that caused it).

## Gate — Jamie

- Marks **Work started** on the profile (`work_started_at`) when the doing actually
  begins — deliberately distinct from the deal being agreed.
- Confirms ConvertFlow shows no remaining conversion gaps (repo · deal terms · Stripe).

## Outputs

| Artifact | Lands in |
|---|---|
| `07-kickoff.md` | the deal folder |
| Proposal + discovery notes (copies) | client repo `.icm/docs/` |
| Register + first tickets | client repo, via `/project` |

## Audit

- Every scope line in `03-quote.md` is visible in the client repo — as a feature row or
  a ticket, not left behind in the deal folder.
- ConvertFlow gaps are clear; the profile wears no warning badge.
- The lessons row in `07-kickoff.md` is honest — "nothing to amend" is a valid entry,
  a blank one is not.

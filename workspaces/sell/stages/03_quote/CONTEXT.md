# sell/03_quote — reach a number from the rate card

One stage, one job: scope + shape + number, decided *before* any prose is written.
The proposal (04) presents this; it never renegotiates it.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`_system/knowledge/pricing.md`](../../../../_system/knowledge/pricing.md) | Bands, tiers, the floor, in-kind rules |
| 3 | [`_system/knowledge/services.md`](../../../../_system/knowledge/services.md) | What the scoped work is an instance of |
| 3 | [`_system/knowledge/terms.md`](../../../../_system/knowledge/terms.md) | Standard terms; red lines |
| 3 | [`_system/knowledge/stack.md`](../../../../_system/knowledge/stack.md) | The invisible scope every build includes |
| 4 | `02-discovery-notes.md` **as Jamie left it** | The scope source |
| 4 | Past deals in [`../../../deals/`](../../../deals/) | Precedent for comparable numbers |

## Process

1. Refuse to run past an open `[BLOCKER]` in the discovery notes — send it back instead.
2. Write `03-quote.md`:
   - **Scope** — deliverables in the client's words, each traceable to a line in the
     discovery notes; then **Not included**, explicitly (the scope-bleed fence).
   - **Shape** — fixed-price · retainer · in-kind, per pricing.md's table.
   - **Number** — from the band. Any deviation is named with its reason. In-kind deals
     state the EUR equivalent.
   - **Terms deltas** — only where this deal departs from terms.md, each named.
   - **Options** (when honest): smallest-honest-version vs the full ask, each priced.
3. Update `DEAL.md` (value, shape) — and mirror into the dashboard's deal card is
   Jamie's step, below.

## Gate — Jamie

- Approves scope, number, and any deviation — this is the money decision of the deal.
- Records value/shape on the dashboard deal card (feeds *in play* / */ month* totals).

## Outputs

| Artifact | Lands in |
|---|---|
| `03-quote.md` | the deal folder |

## Audit

- Every scope line traces to the discovery notes; nothing appears from nowhere.
- The number matches the band or names its deviation — silence is a fail.
- Below-floor → the documented smallest-honest-version or a decline, never a quiet yes.

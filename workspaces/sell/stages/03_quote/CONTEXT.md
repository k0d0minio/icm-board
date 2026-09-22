# sell/03_quote — scope · tiers · shapes · numbers

One stage, one job: decide what is built, in which tiers, under which shape, for how much
— *before* any prose is written. The proposal (04) presents this; it never renegotiates it.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`_system/knowledge/pricing.md`](../../../../_system/knowledge/pricing.md) | The anchor, the floor, the four shapes, the diagnostic bands, the tiers |
| 3 | [`_system/knowledge/services.md`](../../../../_system/knowledge/services.md) | What the scoped work is an instance of; what every build with state ships with |
| 3 | [`_system/knowledge/terms.md`](../../../../_system/knowledge/terms.md) | Standard terms, support after handover, the paper, red lines |
| 3 | [`_system/knowledge/stack.md`](../../../../_system/knowledge/stack.md) | The invisible scope; the ceilings |
| 4 | `02-look.md` **as Jamie sent it** | The scope source |
| 4 | Precedent in [`../../../deals/`](../../../deals/) | Comparable numbers — every `03-quote.md` and `private/pricing.md` |

## Process

1. Refuse to run past an open `[BLOCKER]` in the look — send it back instead.
2. Write `03-quote.md`:
   - **Scope, as outcomes** — deliverables in the client's words, each traceable to a line
     in the look; then **Not included**, explicitly (the scope-bleed fence).
   - **The tier table** — Foundation · Full Build (· Partnership, only when the look
     qualified them for it): what each contains, its number. Where the deal is spec-shaped
     and contradictory, **the Foundation tier is the diagnostic**. Each number at or above
     the floor.
   - **Shape** — one-off · one-off + support · retainer · partnership; for a build with
     state, **the support line** (monthly figure, or "none — landing page").
   - **Terms deltas** — only where this deal departs from `terms.md`, each named.
   - **`[LAWYER]`** on anything that resembles drafting: equity, commission, revenue
     share, unusual liability. Carried verbatim into 04 and 05.
3. Write `private/pricing.md`: how each number was reached — hours × the anchor, the
   precedent read, every deviation with its reason. **Never leaves this repo.**
4. Update the engagement row in `DEAL.md` (shape). The value is the quote's, not the
   folder's; it reaches Neon at signature (05).

## Gate — Jamie

- Approves scope, tiers, shape and numbers — the money decision of the deal.

## Outputs

| Artefact | Lands in |
|---|---|
| `03-quote.md` | `workspaces/deals/<client>/<engagement>/` |
| `private/pricing.md` | the same engagement's `private/` |

## Audit

- Every scope line traces to the look; nothing appears from nowhere.
- Every tier number is at or above the floor and matches the card or names its deviation.
- A build with state carries the fail-safe page and Sentry in scope, and a support line
  (or "none" with the reason). No number in the quote is below the one in `private/`.

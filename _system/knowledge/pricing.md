# Pricing — the rate card, and how a number is reached

*Layer-3 reference for sell `03_quote`. Three engagement shapes, per Jamie's 2026-08-26
ruling: fixed-price, retainer, in-kind. **No day or hourly rate** — time-and-materials is
deliberately not offered. Amounts are EUR unless a deal says otherwise. Filled from
[`../setup/questionnaire.md`](../setup/questionnaire.md) § Pricing (ICM-009).*

## The three shapes

| Shape | Feeds the dashboard as | The number comes from |
|---|---|---|
| **Fixed-price** | `value_minor`, *in play* | scoped work, priced from this file's bands |
| **Retainer** | `billing_type` monthly, */ month* total | the retainer tiers below |
| **In-kind** | `deal_type` in-kind, *in kind* — never income | honest EUR equivalent, stated in the deal folder |

Whatever the shape, Stripe is the source of truth for what was invoiced and paid —
[contracts/CLIENTS.md](../contracts/CLIENTS.md). This file only decides what to ask for.

## Fixed-price bands

— not yet established. The intended structure: a floor (the minimum any project is worth
taking at), and per-service bands (small / typical / large with what each includes),
so a quote is "band + named deviations", never a from-scratch invention.

## Retainer tiers

— not yet established. Intended structure: 2–3 named tiers, each with a monthly amount,
what it covers, response expectation, and what falls outside it (→ quoted as fixed-price).

## In-kind deals

- Always valued in EUR in the deal folder — "what would this invoice as" — so *in kind*
  totals stay honest and a barter is never accidentally treated as free.
- Equity or revenue-share terms are `[LAWYER]`-tagged in the proposal, per
  [terms.md](terms.md).

## Rules for reaching a number

- **Quote from the bands, deviate by name.** A quote that ignores the card is a signal to
  amend the card, not a habit to keep.
- **Scope drives price; price never back-fills scope.** If the number must come down, a
  named piece of scope comes out with it.
- **The floor is the floor.** Below it, the answer is the smallest honest version of the
  service, or no.
- **Discounts are decisions.** Any deviation below band is written in the deal folder
  with its reason — future quotes read past deals as precedent.

# Pricing — the rate card, and how a number is reached

*Layer-3 reference for sell `03_quote`. Three engagement shapes, per Jamie's 2026-08-26
ruling: fixed-price, retainer, in-kind. **No day or hourly rate** — time-and-materials is
deliberately not offered. Amounts are EUR unless a deal says otherwise. Filled
2026-08-26 from [`../setup/questionnaire.md`](../setup/questionnaire.md) § Pricing (ICM-009).*

## The three shapes

| Shape | Feeds the dashboard as | The number comes from |
|---|---|---|
| **Fixed-price** | `value_minor`, *in play* | scoped work, priced from the bands and method below |
| **Retainer** | `billing_type` monthly, */ month* total | the agreed monthly scope — see Retainers |
| **In-kind** | `deal_type` in-kind, *in kind* — never income | honest EUR equivalent, stated in the deal folder |

Whatever the shape, Stripe is the source of truth for what was invoiced and paid —
[contracts/CLIENTS.md](../contracts/CLIENTS.md). This file only decides what to ask for.

## The floor

**€500.** Below it, the answer is the smallest honest version of the service at or above
the floor, or a decline (qualification D2) — never a quiet yes.

## Fixed-price: websites

A typical client website goes out at **€1.000–€2.500**. Below that band is a genuinely
small build (floor still applies); above it means real integrations or unusual scope —
name what pushes it over. Quote from the band, deviate by name.

## Fixed-price: web apps and AI consulting

**Deliberately not banded** — these deals vary too much for a range to be honest.
The method instead:

1. Scope from the discovery notes — deliverables the client can read.
2. Price the engagement as a whole against comparable **past deals in
   [`workspaces/deals/`](../../workspaces/deals/)** — precedent, not invention.
3. Never run past an open `[BLOCKER]`; a deal that can't be scoped can't be priced.

## Retainers

**No fixed tiers.** Real retainers run **€200–€4.000/month**, and the number depends
entirely on the work agreed. A retainer is priced like a small quote: the monthly scope
written down (what is covered, what falls outside → quoted separately), then the number
against it. Re-scoped deliberately when the work changes — never silently grown.

## In-kind deals

- Always valued in EUR in the deal folder — "what would this invoice as" — so *in kind*
  totals stay honest and a barter is never accidentally treated as free.
- Equity or revenue-share terms are `[LAWYER]`-tagged in the proposal, per
  [terms.md](terms.md).

## Rules for reaching a number

- **Quote from the card, deviate by name.** A quote that ignores this file is a signal
  to amend the file, not a habit to keep.
- **Scope drives price; price never back-fills scope.** If the number must come down, a
  named piece of scope comes out with it. A lead pushing the number below the scoped
  work is the red-line pattern in [terms.md](terms.md) — the worst deals started there.
- **The floor is the floor.**
- **Discounts are decisions.** Any deviation below band is written in the deal folder
  with its reason — future quotes read past deals as precedent.

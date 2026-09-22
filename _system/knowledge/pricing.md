# Pricing — the rate card, and how a number is reached

*Layer-3 reference for sell `03_quote` (and `02_look`, for what the look may say about
money: nothing). Four engagement shapes, an internal anchor, one floor, a paid diagnostic
and three tiers — per Jamie's rulings of 2026-08-26 (ICM-009) and 2026-09-22 (the rework
brief). Amounts are EUR unless a deal says otherwise. **None of the numbers on this page is
a public surface** ([positioning.md](positioning.md) § What never appears publicly).*

## The anchor

**€120 per hour is the internal anchor.** It is used for two things and nothing else: to
turn a scope into a number (hours honestly estimated × the anchor, then the scope-and-
precedent check below), and for the rare client who asks what the rate would be. It is
**never a billing basis** — time-and-materials is not sold — and **never appears on any
public surface**. It is revised with demand, deliberately, here.

The Berceo deviation of 2026-08-27 (`workspaces/deals/alix-hahusseau/berceo-platform/03-quote.md`
named the rate at the client to make a reduction legible) is now policy: an anchor may be
shown to a client *in a quote*, on a call or in a proposal, as the thing the fixed price is
measured against — the engagement itself stays fixed-price.

## The floor

**€500, everywhere** — including the referral site's landing page, which is priced *from*
the floor. There is no loss-leader below it. Below the floor the answer is the smallest
honest version of the service at or above it, or a decline (qualification D2) — never a
quiet yes.

## The four shapes

| Shape | Feeds the dashboard as | The number comes from |
|---|---|---|
| **One-off** | `value_minor`, *in play* | scoped work, priced from the tiers, bands and method below |
| **One-off + support** | `value_minor` + `support_minor` (*/ month*) | the one-off as above, plus the retainer that carries hosting, support and maintenance — **support is never a line of its own**, see Support |
| **Retainer** | `billing_type` monthly, */ month* | the agreed monthly scope — see Retainers |
| **Partnership** | `deal_type` in-kind / equity, *in kind* — never income | the EUR value both sides agree it represents, in the deal's `private/terms-sheet.md` |

Whatever the shape, Stripe is the source of truth for what was invoiced and paid —
[contracts/CLIENTS.md](../contracts/CLIENTS.md). This file only decides what to ask for.

## Support — the recurring line

- **Micro (a landing page): no ongoing cost whatsoever.** Hosting rides on Jamie's Vercel
  team at no charge; there is no support line and none is offered.
- **Anything larger than a landing page runs on a retainer, and support and maintenance
  are folded into the retainer's monthly figure** (Jamie, 2026-09-22). There is no
  separate support price per complexity; the complexity shows up in the retainer's scope
  and number (§ Retainers). What the retainer's support part buys is *basic support*:
  crash fixes on call, which requires the fail-safe page and Sentry to exist
  ([terms.md](terms.md) § Support after handover, [services.md](services.md) § Hosting
  & basic support). `support_minor` on the dashboard is the retainer's monthly figure,
  or zero.
- **Retainer and partnership** are unchanged in band (below) until re-scoped.

## Fixed-price: the tiers

Every quote offers **Foundation** and **Full Build**; **Partnership** is added only when the
look qualified the business for it.

- **Foundation** — the smallest honest version that already does the job: one page, one
  flow, one integration; the thing that ships first. Where the work is spec-shaped and the
  spec is contradictory, **the Foundation tier *is* the diagnostic** — the resolved scope
  plus a fixed quote for the rest is the deliverable.
- **Full Build** — the whole answered scope, as the look and the diagnostic described it.
- **Partnership** — the same build under a different shape: commission, revenue share or
  equity in place of part of the price. A qualified shape, not a discount; its terms live
  in `private/terms-sheet.md` and are `[LAWYER]`-tagged ([terms.md](terms.md)).

Tiers are scope. The ladder — look, then Foundation, then Full Build, then support or a
retainer — is the *What happens next* narrative of the proposal, not a price list.

**There is no proof-of-concept rule.** A "POC" is a Foundation tier with a named outcome,
priced as one; nothing is built for free to prove it could be.

## Fixed-price: websites

A typical client website goes out at **€1,000–€2,500**. Below that band is a genuinely
small build (the floor still applies); above it means real integrations or unusual scope —
name what pushes it over. Quote from the band, deviate by name.

## Fixed-price: web apps and AI consulting

**Deliberately not banded** — these deals vary too much for a range to be honest. The
method:

1. Scope from the look and the diagnostic — deliverables the client can read.
2. Hours honestly, times the anchor, then against comparable **past deals in
   [`workspaces/deals/`](../../workspaces/deals/)** — precedent, not invention. Where the
   two disagree, say why in `private/pricing.md`.
3. Never run past an open `[BLOCKER]`; a deal that can't be scoped can't be priced.

## The paid diagnostic

The detailed report on implementing and improving the business's current processes and
workflows — [services.md](services.md) § The diagnostic. Priced by register, credited
**100 % against the build** when that build is signed within the window:

| Register | Band | Credit window |
|---|---|---|
| Local operating business | **€100–€900** | build signed within **30 days** |
| SME | **€2,500–€5,000** | **30 days** |
| Enterprise | **€7,500–€15,000** | **90 days** |

The free look comes first in the first two registers and decides whether a diagnostic is
even the right next step; the enterprise register starts at the diagnostic or a workshop
([positioning.md](positioning.md) § Three registers).

## Retainers

**No fixed tiers.** Real retainers run **€200–€4,000/month**, and the number depends
entirely on the work agreed. A retainer is priced like a small quote: the monthly scope
written down (what is covered, what falls outside → quoted separately), then the number
against it. Re-scoped deliberately when the work changes — never silently grown.

## Partnerships and in-kind

- Always valued in EUR in the deal's `private/` — "what would this invoice as" — so *in
  kind* totals stay honest and a barter is never accidentally treated as free.
- Equity, commission or revenue-share terms are `[LAWYER]`-tagged in the proposal, named
  in the agreement only by reference to the separate term sheet, and never restated as a
  percentage on any client-facing or repo surface ([terms.md](terms.md) § Partnerships).

## Rules for reaching a number

- **Quote from the card, deviate by name.** A quote that ignores this file is a signal to
  amend the file, not a habit to keep.
- **Scope drives price; price never back-fills scope.** If the number must come down, a
  named piece of scope comes out with it. A lead pushing the number below the scoped work
  is the red-line pattern in [terms.md](terms.md) — the worst deals started there.
- **The floor is the floor.**
- **Discounts are decisions.** Any deviation below band is written in the deal's
  `private/pricing.md` with its reason — future quotes read past deals as precedent.
- **In-kind is valued in EUR**, always, in the deal folder.

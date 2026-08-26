# Kickoff checklist — the gaps and the handover, in order

*Layer-3 reference for [`07_kickoff`](../stages/07_kickoff/CONTEXT.md) — and the written
form of CLIENTS.md's "walk ConvertFlow until the conversion gaps clear". Rows land in the
deal's `07-kickoff.md`.*

## The conversion gaps (dashboard truth)

| Gap | Cleared by | Who |
|---|---|---|
| Delivery repo (`github_repo`) | **Connect / create repo** on the profile — done in stage 06 | Jamie |
| Deal terms on the card (`value_minor` + `billing_type` + `deal_type`) | The deal card, from `03-quote.md`'s shape and number | Jamie |
| Stripe customer (`stripe_customer_id`) | Billing flow or **Link Stripe customer** — done in stage 05 | Jamie |

The profile wears a warning badge per open gap; kickoff is not done while it wears one.

## The handover

1. Proposal + discovery notes copied to client repo `.icm/docs/`, provenance-stamped.
2. `/project <repo>` first run: register written from the deal's documents; scope from
   `03-quote.md` seeds the Features table; surviving `[BLOCKER]`s become Open questions
   or decision tickets.
3. Prefix confirmed (stage 06) and the first tickets exist with it.
4. **Work started** flagged on the profile when the doing begins — not before.

## The look-back (edit the source)

One honest pass over the whole deal, 01–07: what did a stage get wrong that a Layer-3
edit would fix for every future deal?

- A question asked twice ad hoc → give it an ID in
  [`discovery-questions.md`](../../sell/references/discovery-questions.md).
- A quote surprise → amend [`pricing.md`](../../../_system/knowledge/pricing.md)'s bands
  or [`services.md`](../../../_system/knowledge/services.md)'s not-in-scope.
- A proposal edit Jamie makes every time → change
  [`proposal-template.md`](../../sell/references/proposal-template.md), not the habit.
- A stalled onboarding row → sharpen
  [`onboarding-checklist.md`](onboarding-checklist.md)'s ask.

Findings that touch this repo's own machinery become `ICM-*` tickets; findings about the
client's build are already `/project`'s output.

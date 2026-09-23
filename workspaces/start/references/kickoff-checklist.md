# Kickoff checklist — the gaps and the handover, in order

*Layer-3 reference for [`07_kickoff`](../stages/07_kickoff/CONTEXT.md) — and the written
form of CLIENTS.md's "walk ConvertFlow until the conversion gaps clear". Rows land in the
engagement's `07-kickoff.md`. Needs the client repo on disk.*

## The conversion gaps (dashboard truth)

| Gap | Cleared by | Who |
|---|---|---|
| Delivery repo (`github_repo`) | **Connect / create repo** on the profile — at signature by default (sell `05`'s gate); adopted here if it already exists | Jamie |
| Deal terms on the card (`value_minor` + `billing_type` + `deal_type` + `support_minor`) | The deal card, prefilled from `05-agreement.md` | Jamie |
| Stripe customer (`stripe_customer_id`) | Billing flow or **Link Stripe customer** — done in stage 06 | Jamie |
| Deal folder (`workspaces/deals/<repo name>/`) | Named after `github_repo` (D28) — nothing to set | Jamie |

The profile wears a warning badge per open gap; kickoff is not done while it wears one.

## The handover

1. `icm-check.sh --fix` then `icm-sync.sh --apply projects/<repo>` from the Apps root
   (formatter guard first, by hand); then **`/setup` in the repo** — `project.json`
   (complexity, deploy, reporting, the `support` block from the agreement's line),
   `project-rules.md`; its PR is Jamie's to merge. There is no prefix to choose or
   register — identity is the `epic/slug` path.
2. The snapshots into client repo `.icm/docs/`: `proposal-<date>.md`, `scope-<date>.md`
   (the quote's scope section only), each provenance-stamped and immutable. Nothing from
   `private/`, no number.
3. `/project <repo>` first run: register written from the deal's documents; the scope
   snapshot seeds the Features table; surviving `[BLOCKER]`s become Open questions or
   decision tickets; the first tickets exist.
4. **Work started** flagged on the profile when the doing begins — not before.

## The look-back (edit the source)

One honest pass over the whole engagement, 01–07: what did a stage get wrong that a
Layer-3 edit would fix for every future deal?

- A question asked twice ad hoc → give it an ID in
  [`discovery-questions.md`](../../sell/references/discovery-questions.md).
- A quote surprise → amend [`pricing.md`](../../../_system/knowledge/pricing.md)'s bands
  or [`services.md`](../../../_system/knowledge/services.md)'s not-in-scope.
- A proposal edit Jamie makes every time → change
  [`proposal-template.md`](../../sell/references/proposal-template.md), not the habit.
- A stalled onboarding row → sharpen
  [`onboarding-checklist.md`](onboarding-checklist.md)'s ask.
- A form question nobody could answer → reword it in
  [`forms/`](../../sell/references/forms/) (a new `key:` if the meaning changed).

Findings that touch this repo's own machinery become stubs in `.icm/intake/` here;
findings about the client's build are already `/project`'s output.

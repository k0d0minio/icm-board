# start/06_onboarding — collect what delivery needs

One stage, one job: after the signature, gather answers, access and the money mechanics
so the build never stalls mid-flight on a missing login or an unsent invoice. Runs from
any session with icm-board in view.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`references/onboarding-checklist.md`](../../references/onboarding-checklist.md) | The full collection list |
| 3 | [`_system/knowledge/terms.md`](../../../../_system/knowledge/terms.md) | What "confirmed terms" means — the signed agreement |
| 3 | [`sell/references/forms/onboarding.md`](../../../sell/references/forms/onboarding.md) · [`content-and-brand.md`](../../../sell/references/forms/content-and-brand.md) | The two questionnaires, sent from the dashboard's Forms card |
| 4 | `05-agreement.md` + `03-quote.md` | What was actually agreed |
| 4 | `answers/onboarding.md` · `answers/content-and-brand.md` | The client's answers — snapshots the dashboard writes when a form completes |

## Process

1. Open `06-onboarding.md` from the checklist: one row per item — **needed · asked ·
   received** — so the gaps are visible at a glance. Rows that do not apply are struck,
   not deleted.
2. Draft the onboarding message for Jamie to send: welcome, the checklist's asks in the
   client's words, the two forms he will send from the Forms card, and what happens when
   they are in.
3. Record access as **existing**, never as values: "Vercel invite accepted", "registrar
   access via the password manager" — a credential in this folder is a P0.
4. Track the money mechanics: deposit invoice raised (Stripe) · paid ·
   `stripe_customer_id` linked on the dashboard. **Terms confirmed = the signed
   agreement** (`05-agreement.md`, `- signed:` set) — nothing else is asked for.

## Gate — Jamie

- Sends the two forms from the dashboard's Forms card, and the welcome message.
- Raises the deposit invoice in Stripe; links the Stripe customer on the profile.
- Confirms the deal card carries the agreed value, the shape and the support line (the
  dashboard prefills them from `05-agreement.md`; he saves).

## Outputs

| Artefact | Lands in |
|---|---|
| `06-onboarding.md` (checklist state + what was received) | `workspaces/deals/<client>/<engagement>/` |
| `answers/onboarding.md` · `answers/content-and-brand.md` | the same folder — written by the dashboard, never edited here |

## Audit

- Every checklist row is needed/asked/received — no row silently absent.
- No value of any credential appears anywhere in the folder.
- The timeline promise in the proposal only starts when "materials received" and
  "deposit paid" are green — say so if someone asks for dates early.

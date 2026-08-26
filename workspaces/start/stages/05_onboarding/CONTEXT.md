# start/05_onboarding — collect what delivery needs

One stage, one job: after the yes, gather answers, access and money-mechanics so the
build never stalls mid-flight on a missing login or an unsent invoice.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`references/onboarding-checklist.md`](../../references/onboarding-checklist.md) | The full collection list |
| 3 | [`_system/knowledge/terms.md`](../../../../_system/knowledge/terms.md) | What "confirmed terms" means |
| 4 | `04-proposal.md` + `03-quote.md` | What was actually agreed |
| 4 | The client's questionnaire answers | House questionnaires live in `jamienisbet`'s `.icm/onboarding/` (JN-021), sent from the dashboard's Forms card |

## Process

1. Open `05-onboarding.md` from the checklist: one row per item — needed · asked ·
   received — so the gaps are visible at a glance.
2. Draft the onboarding message for Jamie to send: welcome, the checklist's asks in
   client-friendly words, and what happens when they're in.
3. Record access as *existing*, never as values: "Vercel invite accepted", "domain
   registrar access via password manager" — a credential in this folder is a P0.
4. Track the money mechanics: deposit invoice raised (Stripe) · paid · `stripe_customer_id`
   linked on the dashboard.

## Gate — Jamie

- Sends the questionnaire from the dashboard's Forms card and the welcome message.
- Raises the deposit invoice in Stripe; links the Stripe customer on the profile.
- Confirms any terms deltas from the quote are reflected in the deal card.

## Outputs

| Artifact | Lands in |
|---|---|
| `05-onboarding.md` (checklist state + received answers) | the deal folder |

## Audit

- Every checklist row is needed/asked/received — no row silently absent.
- No value of any credential appears anywhere in the folder.
- The timeline promise in the proposal only starts when this stage's "materials
  received" and "deposit paid" rows are green — say so if someone asks for dates early.

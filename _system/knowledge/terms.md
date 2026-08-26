# Terms — the standard engagement, and the red lines

*Layer-3 reference for sell `03_quote`/`04_proposal` and start `05_onboarding`. What every
deal gets unless the deal folder records a named exception. Filled 2026-08-26 from
[`../setup/questionnaire.md`](../setup/questionnaire.md) § Terms (ICM-009). Anything
resembling legal drafting is `[LAWYER]`-tagged — this file is house practice, not counsel,
and the business operates from Portugal under EU rules.*

## Standard terms

- **Payment schedule** — fixed-price: **50% deposit to start, 50% at handover**. It
  varies in practice, so this is the written default and any other split is a named
  deviation in the quote. Retainers bill monthly.
- **Payment method** — Stripe invoice by default; anything else is an exception noted in
  the deal folder. Stripe stays the money source of truth, always.
- **Revisions** — a fixed price includes **two revision rounds** on the built thing.
  After that, change requests are re-quoted. Anything inside the written scope that is
  simply wrong gets fixed regardless — revisions are about preference, not defects.
- **Ownership & hosting** — genuinely varies per deal today, so the quote must name
  which of the two house patterns applies (silence is a fail in `03_quote`'s audit):
  - **Client-owned**: code, content, domain and hosting in accounts in their name;
    Jamie keeps access only while a retainer runs.
  - **Jamie-hosted**: the code and content are theirs, but Vercel/domain live in
    Jamie's accounts and hosting rides on a retainer — they pay him, he pays the
    providers.
- **Timeline honesty** — estimates are dated from *deposit paid and materials
  received* (the onboarding checklist's green rows), never from the proposal.
- **Support after handover** — *not yet established* as a standing window. Until it is:
  defects get fixed, and ongoing work is the retainer conversation, per
  [pricing.md](pricing.md) § Retainers.

## Red lines

Deals the business does not sign, whatever the number:

- **The price got talked down but the scope didn't.** The regretted deals started
  exactly here. If the number drops, a named piece of scope drops with it
  ([pricing.md](pricing.md)); a lead haggling before the work is even scoped is a
  decline signal at intake
  ([target-profile](../../workspaces/sell/references/target-profile.md) § worst signals).
- **Uncapped scope for a capped price.**
- Work that requires holding a client's credentials loosely — access is granted properly
  or the work waits ([WORKSPACES.md](../contracts/WORKSPACES.md) § no secrets).

## In-kind and equity

Per [pricing.md](pricing.md): valued in EUR in the deal folder, `[LAWYER]`-tagged in the
proposal when equity or revenue share is involved. A handshake barter still gets its
terms written down in the deal folder — memory is not a contract.

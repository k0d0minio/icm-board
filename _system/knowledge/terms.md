# Terms — the standard engagement, and the red lines

*Layer-3 reference for sell `03_quote`/`04_proposal`/`05_agreement` and start
`06_onboarding`. What every deal gets unless the deal folder records a named exception.
Filled 2026-08-26 from [`../setup/questionnaire.md`](../setup/questionnaire.md) § Terms
(ICM-009); support, paper, partnerships and languages settled 2026-09-22 (the rework
brief). Anything resembling legal drafting is `[LAWYER]`-tagged — this file is house
practice, not counsel, and the business operates from Portugal under EU rules.*

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
- **Support after handover** — **basic support** is defined: crash fixes on call — when
  the app is down or a flow is broken, Jamie fixes it; nothing else. It requires the
  fail-safe *technical difficulties* page and Sentry in the build, and it is priced as the
  recurring line of *one-off + support* ([pricing.md](pricing.md) § Support). **The
  Jamie-hosted pattern is its home**: hosting and support ride together on his accounts.
  **The client-owned pattern has no support line** — ongoing work there is a retainer, or
  nothing. **Landing pages: no ongoing cost** and no support line at all. In-scope defects
  are fixed regardless of tier, as before.
- **Paper** — the agreement is a **DOCX signed through Google eSignature**. It is rendered
  from the deal's `05-agreement.md` ([`render-deal.sh`](../scripts/render-deal.sh)), placed
  in **Google Drive in a folder named after the client** (the parent folder *— to set*, Q24;
  the Drive root until then), sent for signature by Jamie, and the signed copy stays in
  that folder; `DEAL.md` logs the link and the date. "A reply saying *agreed*" remains
  enough paper **for a free look and for a house-deal re-quote** — never for an agreement.
- **Languages** — English by default; French or Portuguese where the client leads in it,
  recorded on `DEAL.md` (`- language:`) and carried into the proposal and the agreement
  (the templates exist in all three).

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

## Partnerships — in-kind, commission, revenue share, equity

Per [pricing.md](pricing.md): valued in EUR in the deal folder, `[LAWYER]`-tagged in the
proposal when equity or revenue share is involved. A handshake barter still gets its
terms written down — memory is not a contract. Where they are written matters:

- **The term sheet lives only in the deal's `private/terms-sheet.md`** — the percentages,
  the vesting, the triggers, the commission table.
- **The agreement references it by name and date** ("per the separate agreement of
  <date>") and **never restates a percentage**; the proposal names the shape and the
  `[LAWYER]` tag, not the number.
- **No client repo ever carries it** — not in `.icm/docs/`, not in a README, not in a
  snapshot. REMI (2026-08) is the standing example: the equity is Jamie's and the
  founders' business, written in icm-board's `private/` and nowhere a repository reader
  can see.

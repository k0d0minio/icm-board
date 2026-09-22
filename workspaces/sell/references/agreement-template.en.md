# Agreement template — English

*Layer-3 reference for [`05_agreement`](../stages/05_agreement/CONTEXT.md). Plain house
practice, per [`terms.md`](../../../_system/knowledge/terms.md); `[LAWYER]` marks every
slot that resembles drafting — this is not counsel, and nothing legal is invented beyond
what `terms.md` already states. Rendered to DOCX by `render-deal.sh`, placed in the
client's Drive folder, signed through Google eSignature. The identity block comes from
`DEAL.md` and the render; no address or rate lives here.*

```markdown
# Agreement — <project name>

- language: en
- tier: foundation | full-build | partnership
- shape: one-off | one-off + support | retainer | partnership
- agreed: <EUR>
- recurring: <EUR/month | none>
- signed: pending | <YYYY-MM-DD>
- drive: <link>
- proposal: 04-proposal.md (<date>)

## 1. Parties

<Client company or name>, <the person who signs and their role> — "you".
Jamie Nisbet, software engineer and AI consultant, Mafra, Portugal — "I".

## 2. What is being built

The work described under *What you'll get* in the proposal of <date>, at the **<tier>**
tier, and nothing that proposal lists under *Not included*. The proposal is part of this
agreement; where the two differ, this agreement wins.

## 3. Price and schedule

**€<agreed>**, fixed. 50 % on signature, invoiced then; 50 % at handover.
<Or the quote's delta, stated plainly.> Invoices through Stripe, due on receipt.
<Where a diagnostic was paid: "The €<n> paid for the diagnostic of <date> is credited
against the first invoice.">

## 4. What is yours, and where it lives

<Client-owned: "The code, the content, the domain and the hosting accounts are in your
name from the start; I have access while the work runs and for the support period
below.">
<Jamie-hosted: "The code and the content are yours. The hosting, database, email and
domain accounts are mine and are rebilled monthly at cost, capped at €<n>/month while we
are in development; you can move them to your own accounts at any time and I will help.">

## 5. Hosting and support after handover

<none: "A landing page has no ongoing cost and no support line; in-scope defects are fixed
regardless.">
<basic: "**€<recurring>/month** for hosting and basic support — when the application is
down or a flow is broken, I fix it. It requires the fail-safe page and the error tracker,
both included in the build. It does not include new features or content changes. Either
of us can end it with one month's notice.">

## 6. Revisions

Two rounds of revisions on the built thing are included. After that, changes are quoted.
Anything inside the written scope that is simply wrong is fixed regardless.

## 7. Timeline

Estimates count from the day the deposit is paid and the materials in the onboarding
checklist are received — not from signature. <The estimate: "<n> weeks to handover.">

## 8. Ending it

Either of us can end this agreement in writing. Work done and invoiced stays paid; work
done and not yet invoiced is invoiced pro rata; you keep what has been delivered.

## 9. Separate terms [LAWYER]

<partnership only: "The commission / revenue share / equity terms are set out in the
separate agreement of <date> and are not restated here." — never a percentage on this
page.>
<any [LAWYER] tag from the quote, verbatim, marked "to be papered properly".>

## 10. Signatures

<Client name, role, date>                     Jamie Nisbet, date
(signed electronically via Google eSignature)
```

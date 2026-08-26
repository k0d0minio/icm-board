# Proposal template — the shape of the document

*Layer-3 reference for [`04_proposal`](../stages/04_proposal/CONTEXT.md). The markdown
skeleton a proposal is written into; rendered to PDF, same basename. Short is the
feature: two pages of A4, three at the outside. Voice per
[`voice.md`](../../../_system/knowledge/voice.md); every fact from `03-quote.md`.*

```markdown
# <Project name> — proposal
<Jamie Nisbet · date · for <client name>>

## What you told me
Their situation and ask, in their words from discovery — two short paragraphs at most.
This section is why the proposal feels listened-to; it earns the rest.

## What you'll get
The scope, as outcomes: what will exist and what it will do for them. Bullets, each
one traceable to the quote. Then, in its own short list:

**Not included** — the fence, stated kindly. What would be a separate conversation.

## What it costs
The number, plainly, with its shape:
- Fixed price: the amount · the payment schedule (per terms).
- Retainer: the monthly amount · what it covers · how it pauses or ends.
- In-kind: what is exchanged · the EUR value both sides agree it represents.
Options, when offered, as a two-row table — smallest honest version vs the full ask.

## How it works
Standard terms, restated humanly in five or six lines: deposit, revisions, ownership
at handover, hosting/accounts, timeline (dated from deposit + materials), support
after. Deviations for this deal are stated, not hidden. `[LAWYER]` items appear
verbatim, marked as "to be papered properly".

## What happens next
One step: how to say yes (reply + deposit invoice follows), and until when the number
holds (default: 30 days).
```

## Render rules

- Markdown is canonical; the PDF is a build artifact — regenerate, never hand-edit.
- House header: name · Mafra, Portugal · email — no logo theatrics until the brand
  says otherwise.
- File naming: `04-proposal.md` / `04-proposal.pdf` in the deal folder; a revision
  overwrites in place and `DEAL.md` logs the re-send (git history keeps the versions).

# Proposal template — the shape of the document

*Layer-3 reference for [`04_proposal`](../stages/04_proposal/CONTEXT.md). The markdown
skeleton a proposal is written into; rendered to DOCX by `render-deal.sh`, same basename,
under `out/`. Short is the feature: two pages of A4, three at the outside. Voice per
[`voice.md`](../../../_system/knowledge/voice.md) in the lead's register
([`positioning.md`](../../../_system/knowledge/positioning.md)); every fact from
`03-quote.md`. **No name, address or rate lives in this file**: identity comes from
`DEAL.md` and from the render's reference document (`_system/knowledge/house.docx`, Q24);
the anchor never appears.*

```markdown
# <Project name> — proposal

- language: en | fr | pt
- tiers: foundation, full-build[, partnership]
- quote: 03-quote.md
- date: <YYYY-MM-DD>

## What you told me
Their situation and ask, in their words from the look — two short paragraphs at most.
This section is why the proposal feels listened-to; it earns the rest.

## What you'll get
The scope, as outcomes: what will exist and what it will do for them. Bullets, each one
traceable to a scope line in the quote — `validate-deal.sh` checks that they are. Then,
in its own short list:

**Not included** — the fence, stated kindly. What would be a separate conversation.

## What it costs
The three-column table, one column per tier offered, the numbers verbatim from the quote:

| | Foundation | Full Build | Partnership |
|---|---|---|---|
| What's in it | <one line> | <one line> | <the same build, a different shape — "see below"> |
| Price | €N | €N | €N + <the shape, no percentage> |
| Monthly | none — a landing page has no ongoing cost | €M/month support (crash fixes on call) | as Full Build |
| Payment | 50 % to start, 50 % at handover | 50 % / 50 % | per the separate agreement |

Below the table, in prose: what the recurring line is and is not; the diagnostic's credit
where one was paid ("the €N you paid for the diagnostic comes off this").

## How it works
Standard terms, restated humanly in five or six lines: deposit, two revision rounds,
ownership at handover (which pattern), hosting and the support line, timeline (dated from
deposit + materials), how a change of mind is handled. Deviations for this deal are
stated, not hidden. `[LAWYER]` items appear verbatim, marked "to be papered properly".

## What happens next
The ladder, as a narrative, not a price list: "You pick a tier and say yes; the agreement
follows for signature and a deposit invoice with it; we start on <condition>. The
Foundation ships <when>; if it earns its keep, the Full Build is the next conversation,
and support keeps it running after that." The number holds until <date> (default: 30 days).
```

## Render rules

- Markdown is canonical; the DOCX is a build artefact — regenerate, never hand-edit.
- `render-deal.sh <client>/<engagement> 04-proposal` → `out/04-proposal.docx`, using the
  house reference document when it exists; the render never uploads and never commits.
- The DOCX goes to Google Drive under the client's folder (D25); the link into `DEAL.md`.
- A revision overwrites in place; `DEAL.md` logs the re-send; git keeps the versions.

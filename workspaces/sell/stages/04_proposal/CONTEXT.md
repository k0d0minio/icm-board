# sell/04_proposal — the document the lead receives

One stage, one job: present the approved quote as something a client says yes to.
Markdown is canonical; the PDF is a build artifact — regenerate it, never edit it.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`references/proposal-template.md`](../../references/proposal-template.md) | The shape |
| 3 | [`_system/knowledge/voice.md`](../../../../_system/knowledge/voice.md) | How it sounds |
| 3 | [`_system/knowledge/terms.md`](../../../../_system/knowledge/terms.md) | The standard terms it restates |
| 4 | `03-quote.md` **as approved** | Scope, shape, number — verbatim, not re-derived |
| 4 | `02-discovery-notes.md` | Their words, for the opening |

## Process

1. Write `04-proposal.md` per the template: their problem in their words · what they
   get · what it costs · what happens next. Everything traces to the quote; the
   proposal invents nothing.
2. Carry `[LAWYER]` tags through visibly (equity, revenue share, unusual liability) —
   never silently smooth them into prose.
3. Render `04-proposal.pdf` from the markdown (locally: pandoc or house tooling; in a
   cloud session: the pdf skill). Same folder, same basename.
4. On revisions: the negotiation's changes go into `03-quote.md` first, then re-render —
   the quote stays the source of truth for what was agreed.

## Gate — Jamie

- Reads the PDF as the client will; edits the markdown, re-renders.
- **Sends it himself**, and logs the send date in `DEAL.md`.
- On the answer: **won** → dashboard rung `client`, continue at
  [`start/05_onboarding`](../../../start/stages/05_onboarding/CONTEXT.md) ·
  **lost** → rung `lost`, archive, `DEAL.md` records why in one honest line.

## Outputs

| Artifact | Lands in |
|---|---|
| `04-proposal.md` + `04-proposal.pdf` | the deal folder |

## Audit

- Scope, number and terms match `03-quote.md` exactly — a mismatch is a stage-2-style
  drift bug and blocks the render.
- A stranger could read the proposal alone and know what is bought, for how much, and
  what happens next.
- No `[LAWYER]` item was silently dropped.

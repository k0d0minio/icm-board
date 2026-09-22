# sell/04_proposal — the document

One stage, one job: present the approved quote as something a client says yes to.
Markdown is canonical; the DOCX is a build artefact — regenerate it, never edit it (D9,
DOCX only since 2026-09-22).

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`references/proposal-template.md`](../../references/proposal-template.md) | The shape |
| 3 | [`_system/knowledge/voice.md`](../../../../_system/knowledge/voice.md) · [`positioning.md`](../../../../_system/knowledge/positioning.md) | How it sounds, in the lead's register |
| 4 | `03-quote.md` **as approved** | Scope, tiers, shape, numbers — verbatim, not re-derived |
| 4 | `02-look.md` | Their words, for the opening |
| 4 | `DEAL.md` | Company, language — the identity the render needs; nothing else |

## Process

1. Write `04-proposal.md` per the template: the header dash-fields (`- language:`,
   `- tiers:`), then *what you told me* · *what you'll get* · *what it costs* (the
   three-column price table) · *how it works* · *what happens next* (the ladder: this
   tier, then the next, then support or a retainer). Everything traces to the quote; the
   proposal invents nothing and carries every `[LAWYER]` tag visibly.
2. Render: `_system/scripts/render-deal.sh <client>/<engagement> 04-proposal` →
   `out/04-proposal.docx` (gitignored; pandoc, with the house reference document when
   present). `SKIP` means pandoc is absent — the markdown is still the deliverable to edit.
3. **Place the DOCX in Google Drive** (D25): the Drive connector, a folder named after the
   client under the parent `terms.md` names (the Drive root until Q24 is answered), created
   when absent; the link logged in `DEAL.md`'s `## Log`. This is a write to Jamie's own
   storage, not an outbound action; **sending remains his**.
4. On revisions: the negotiation's changes go into `03-quote.md` first, then re-render —
   the quote stays the source of truth for what was agreed. `validate-deal.sh` holds the
   two together.

## Gate — Jamie

- Reads the DOCX as the client will; edits the markdown; re-renders and re-places.
- **Sends it himself**, and logs the send date in `DEAL.md`.

## Outputs

| Artefact | Lands in |
|---|---|
| `04-proposal.md` | `workspaces/deals/<client>/<engagement>/` |
| `out/04-proposal.docx` | `workspaces/deals/<client>/out/` — never committed |
| The DOCX | Google Drive → `<client>/`, link in `DEAL.md` |

## Audit

- `_system/scripts/validate-deal.sh <client>/<engagement>` → `RESULT: OK`: scope bullets
  and numbers match the quote per tier; `[LAWYER]` tags survive; the language agrees; no
  client-facing file references `private/`.
- A stranger could read the proposal alone and know what is bought, for how much, and what
  happens next. No name, address or rate appears that `DEAL.md` and the render did not supply.

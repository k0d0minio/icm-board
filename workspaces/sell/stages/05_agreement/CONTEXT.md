# sell/05_agreement — the paper

One stage, one job: the document both sides sign. House practice in plain words, `[LAWYER]`
where it resembles drafting; nothing legal is invented beyond what `terms.md` already
states. Signed through Google eSignature; the signed copy stays in Drive.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`references/agreement-template.<lang>.md`](../../references/agreement-template.en.md) | The shape, in the deal's language (`en` · `fr` · `pt`) |
| 3 | [`_system/knowledge/terms.md`](../../../../_system/knowledge/terms.md) | The standard terms it restates; the paper rule; partnerships |
| 4 | `04-proposal.md` and the chosen tier | Scope by reference; the number |
| 4 | `03-quote.md` | Terms deltas, the support line, every `[LAWYER]` tag |
| 4 | `private/terms-sheet.md` | **By reference only** — named by date in the agreement, never restated |

## Process

1. Write `05-agreement.md` with the dash-field header — `- tier:` (the one they chose),
   `- shape:`, `- agreed: <EUR>`, `- recurring: <EUR/month or none>`, `- signed: pending`,
   `- drive: <link>` — then the template's sections: parties · scope by reference to the
   proposal of `<date>` · price and schedule (50 % / 50 % per `terms.md`, or the quote's
   delta) · ownership pattern · hosting and support line · revisions · timeline clock ·
   termination · the `[LAWYER]` clause slots (a partnership "per the separate agreement of
   `<date>`") · the signature block.
2. Render and place as in 04: `render-deal.sh <client>/<engagement> 05-agreement` →
   `out/05-agreement.docx` → Drive, the client's folder; `- drive:` set.
3. `_system/scripts/validate-deal.sh <client>/<engagement>` → `RESULT: OK` before the gate.

## Gate — Jamie

- **Sends for eSignature himself.** On signature: sets `- signed: <date>`, logs it in
  `DEAL.md`; **enters the agreed value and shape on the Neon row** (the deal card — the
  dashboard prefills them from this file); raises the deposit draft in Stripe; moves the
  rung to `active`.
- **Creates the client repo now, by default** — the dashboard's *Connect / create repo*
  (`createClientRepo`), never by hand; ConvertFlow's missing-repo gap on the active row is
  the nudge. Earlier only on his say, and then the same button.

## Outputs

| Artefact | Lands in |
|---|---|
| `05-agreement.md` | `workspaces/deals/<client>/<engagement>/` |
| `out/05-agreement.docx` · the signed copy | `out/` (never committed) · Google Drive → `<client>/` |
| The engagement row's `shape`; a log line | `DEAL.md` |

The signed engagement continues at [`start/06_onboarding`](../../../start/stages/06_onboarding/CONTEXT.md).

## Audit

- `- tier:` names a tier the quote offered; `- agreed:` equals that tier's number, or a
  `- deviation:` line says why; `- recurring:` matches the quote's support line.
- No percentage of anything appears; the term sheet is referenced by date only.
- `- language:` agrees across quote, proposal and agreement; no path under `private/` is
  referenced.

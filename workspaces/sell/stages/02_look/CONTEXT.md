# sell/02_look — the free look, after the first call

One stage, one job: turn the first call into one page the lead can act on — what I saw,
where each part of the work belongs, three things I'd do first, how I'd start. It is free,
it comes **after** the call, never before, and it contains no number. It replaced
`02_discovery` on 2026-09-22; the diagnostic's full arc lives on in
[`discovery-interview.md`](../../references/discovery-interview.md) for the paid stage.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`references/call-crib.md`](../../references/call-crib.md) | What the call settled — the four beats |
| 3 | [`references/look-template.md`](../../references/look-template.md) | The four sections, the word cap, the sort vocabulary |
| 3 | [`_system/knowledge/services.md`](../../../../_system/knowledge/services.md) · [`stack.md`](../../../../_system/knowledge/stack.md) | What we sell; what the default stack can't do |
| 4 | Their public presence | The site, the socials, the listing — read as a customer would |
| 4 | `answers/intake-diagnostic.md` | What they told the form, if they filled it |
| 4 | `raw/` transcripts | The call recording's transcript, a walkthrough they sent — text only; media is never committed |
| 4 | Read-only access, **only where they offered it** | A back-office login they invited you to — via the password manager; the folder records that it exists, never a value |

## Process

1. Re-read `01-intake.md` and everything they sent; never ask them what a document already
   answers. Jamie holds the call with the crib; his raw notes or the transcript land in
   `raw/` (transcript tracked, recording ignored — `process-raw.sh` in a repo, or by hand).
2. Write `02-look.md` per the template, **≤ 400 words**, in their words and their register:
   **what I saw** · **where the work belongs** (each part sorted: could run itself · keep a
   person on it · worth an assistant · don't build this) · **three things I'd do first** ·
   **how I'd start** (the free look's own next step: a Foundation quote, a diagnostic, or
   nothing yet — said plainly).
3. Where the look shows a spec-shaped or contradictory system, say so in *how I'd start*:
   the honest next step is the paid diagnostic ([services.md](../../../../_system/knowledge/services.md)),
   and `03_quote` will make the Foundation tier the diagnostic.
4. Anything `[BLOCKER]`-grade that one answer would settle is a question at the end of the
   page, not a guess inside it.

## Gate — Jamie

- Edits the page — heavy editing here is normal; it is the direction-setting stage — and
  **sends it himself**.

## Outputs

| Artefact | Lands in |
|---|---|
| `02-look.md` | `workspaces/deals/<client>/<engagement>/` |
| `raw/<call>.txt` (transcript, when there is one) | the same folder |

## Audit

- Under 400 words; four sections, in order; no number anywhere on the page.
- Every part of the work is sorted with one of the four words — nothing left unsorted.
- Nothing in the look contradicts `01-intake.md` without saying it supersedes it.

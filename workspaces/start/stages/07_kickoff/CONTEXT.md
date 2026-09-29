# start/07_kickoff — hand over to the delivery machine

One stage, one job: the signed engagement becomes a running project. Ends the start
workspace; everything after is [`deliver/`](../../../deliver/CONTEXT.md) and the client
repo's own `.icm/`. **Needs the client repo on disk** — `projects/<repo>`; a session
without it STOPs at step 1 and says so.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`references/kickoff-checklist.md`](../../references/kickoff-checklist.md) | The gaps + the handover, in order |
| 3 | [`CLIENTS.md`](../../../../_system/contracts/CLIENTS.md) · [`PIPELINE.md`](../../../../_system/contracts/PIPELINE.md) | The flags this stage clears; what `/setup` fills |
| 3 | [`_system/knowledge/stack.md`](../../../../_system/knowledge/stack.md) | What the repo defaults to; where the deal deviates |
| 4 | The whole engagement folder, 01–06 | What was promised — the repo's `/setup` must inherit it, not rediscover it |
| 4 | `DEAL.md` → `- repo:` · `projects/<repo>` | The repo, on disk |

## Process

1. **The repo.** Created via the dashboard at signature (`createClientRepo` — sell `05`'s
   gate), or adopted if it already exists (a returning client) — **never by hand**. Resolve
   `projects/<repo>`; not on disk → STOP with the clone command and stop. Not on GitHub →
   STOP: the dashboard creates it; say so.
2. **Adopt it: `/icm-check adopt <repo>`** — [conformance § Adopt](../../../deliver/stages/conformance/CONTEXT.md)
   steps 1–4: the formatter guard by hand, the baseline, `icm-sync.sh --apply`, verify.
   Hold the commit until step 3's snapshots are in, so both land together.
3. **The snapshots into `.icm/docs/`**, each opening with the provenance line
   *"snapshot from icm-board deal `<client>/<engagement>`, taken <date>; the deal folder is
   canonical; do not edit"*: `proposal-<date>.md` (the proposal as sent) and
   `scope-<date>.md` (**the quote's scope section only — never its numbers, never anything
   under `private/`**). Immutable copies; the engagement folder keeps the originals. On
   Jamie's word the adoption and the snapshots land as one commit straight to the repo's
   `main` (§ Adopt step 5) — a cloud session sees nothing unpushed.
4. **Run `/setup` in the repo — first run** (locally or in a cloud session). Intent first:
   the register is written from the snapshots per its adopt-never-fabricate rule, the scope
   snapshot seeds the Features table, open `[BLOCKER]`s that survived become Open questions
   or decision tickets; then config — `project.json` (complexity, deploy, reporting,
   `support` from the agreement's line), `project-rules.md`; then the first cut. Tickets are
   cut by `/setup`, not here; its register and config ride its own PR.
5. Write `07-kickoff.md`: date, register commit, tickets cut, flags cleared, the support
   line as declared in the repo, and anything the sell/start run got wrong (→ edit the
   reference file that caused it).

## Gate — Jamie

- Marks **Work started** on the profile (`work_started_at`) when the doing begins —
  distinct from the signature.
- Confirms `github_repo` on the row names this folder (D28: the folder is the repo's
  name); confirms ConvertFlow shows no remaining gap (repo · deal terms · Stripe).
- Merges `/setup`'s PR in the client repo.

## Outputs

| Artefact | Lands in |
|---|---|
| `07-kickoff.md` | `workspaces/deals/<client>/<engagement>/` |
| `proposal-<date>.md` · `scope-<date>.md` (snapshots) | client repo `.icm/docs/` |
| Register + first tickets | client repo, via its `/setup` |

## Audit

- Every scope line in the quote is visible in the client repo — as a feature row or a
  ticket, not left behind in the deal folder; no number and nothing from `private/` went.
- `setup.sh --report` in the repo ends `RESULT: OK`, or its gaps are named in `07-kickoff.md`.
- ConvertFlow gaps are clear; the profile wears no badge; `github_repo` names this folder.
- The lessons row is honest — "nothing to amend" is a valid entry, a blank one is not.

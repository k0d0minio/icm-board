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
| 4 | The whole engagement folder, 01–06 | What was promised — `/project` must inherit it, not rediscover it |
| 4 | `DEAL.md` → `- repo:` · `projects/<repo>` | The repo, on disk |

## Process

1. **The repo.** Created via the dashboard at signature (`createClientRepo` — sell `05`'s
   gate), or adopted if it already exists (a returning client) — **never by hand**. Resolve
   `projects/<repo>`; not on disk → STOP with the clone command and stop. Not on GitHub →
   STOP: the dashboard creates it; say so.
2. **The baseline, then the template.** From the Apps root: `_system/scripts/icm-check.sh
   --fix` seeds what is missing (the formatter guard first, by hand, where the repo has a
   formatter — D17/D19), then `_system/scripts/icm-sync.sh --apply projects/<repo>` brings
   the template-owned files up and writes `.icm/template-version`. Once `.icm/scripts/setup.sh`
   is in the repo, **`/setup` there** fills the project-owned files — `project.json`
   (complexity, deploy, reporting, `support` from the agreement's line), `project-rules.md` —
   and stops on its own PR.
3. **The snapshots into `.icm/docs/`**, each opening with the provenance line
   *"snapshot from icm-board deal `<client>/<engagement>`, taken <date>; the deal folder is
   canonical; do not edit"*: `proposal-<date>.md` (the proposal as sent) and
   `scope-<date>.md` (**the quote's scope section only — never its numbers, never anything
   under `private/`**). Immutable copies; the engagement folder keeps the originals.
4. **Run `/project <repo>` — first run.** The register is written from the deal's real
   documents per its adopt-never-fabricate rule; the scope snapshot seeds the Features
   table; open `[BLOCKER]`s that survived become Open questions or decision tickets. First
   tickets are cut by `/project`, not here.
5. Write `07-kickoff.md`: date, register commit, tickets cut, flags cleared, the support
   line as declared in the repo, and anything the sell/start run got wrong (→ edit the
   reference file that caused it).

## Gate — Jamie

- Marks **Work started** on the profile (`work_started_at`) when the doing begins —
  distinct from the signature.
- Sets `deal_slug` on the row if it is not set; confirms ConvertFlow shows no remaining
  gap (repo · deal terms · Stripe).
- Merges `/setup`'s PR in the client repo.

## Outputs

| Artefact | Lands in |
|---|---|
| `07-kickoff.md` | `workspaces/deals/<client>/<engagement>/` |
| `proposal-<date>.md` · `scope-<date>.md` (snapshots) | client repo `.icm/docs/` |
| Register + first tickets | client repo, via `/project` |

## Audit

- Every scope line in the quote is visible in the client repo — as a feature row or a
  ticket, not left behind in the deal folder; no number and nothing from `private/` went.
- `setup.sh --report` in the repo ends `RESULT: OK`, or its gaps are named in `07-kickoff.md`.
- ConvertFlow gaps are clear; the profile wears no badge; `deal_slug` names this folder.
- The lessons row is honest — "nothing to amend" is a valid entry, a blank one is not.

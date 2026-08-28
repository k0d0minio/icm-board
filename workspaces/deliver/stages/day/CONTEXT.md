# deliver/day — keep the board honest, then decide what's next

Entered by `/day [wrap]`. Work from the Apps root. Sustentus is exempt from
reconciliation (its `.icm/` plans itself) but its stubs and runs **do** appear on the
board and may be picked for `today.md`.

**Two modes, one ritual.** Bare `/day` plans — reconcile, then write tomorrow's
`today.md`. `/day wrap` closes out — reconcile, then bank what happened and cut what's
left. Both share steps 1, 2 and 5, so running either after the other is harmless.

**This ritual touches only `.icm/` ticket state** — stubs, epics, `today.md`. Deciding
*what a project is for* is [`project`](../project/CONTEXT.md)'s job; this one moves work
that already exists and cuts the leftovers of work that already happened.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`TICKETS.md`](../../../../_system/contracts/TICKETS.md) | Positional status, the ≤10 `today.md` cap, `_done/` and archive rules |
| 4 | `_system/scripts/tickets-board.sh` output | The estate board |
| 4 | `_system/scripts/ticket-hygiene.sh` output | Drift candidates — verified, never bulk-applied |
| 4 | `.icm/today.md` (this repo) | Yesterday's plan — cleared or carried deliberately |
| 4 | Each repo's `.icm/intake/` + `runs/` + git log | The reality the board must match |

## Process

**1. Survey.** Run `tickets-board.sh` and show the board. Run `ticket-hygiene.sh` and
show what it found. The scripts report; **you verify and fix with judgment** — never
bulk-apply their findings.

**2. Reconcile — the board must be true before it's useful.**
- *Merged but still open:* `possibly-done` names the commit it found, counting only
  commits that changed something outside `.icm/`. Read the subject: work that genuinely
  merged → `git mv` the stub to its epic's `_done/`. A docs or register commit that
  merely names the slug is noise. Ambiguous → batch and ask.
- *Completed epics:* an epic whose every stub is in `_done/` (and, in pipeline repos,
  whose runs all merged) is archived whole — `git mv intake/<epic>/ intake/_done/<epic>/`.
- *Stale `today.md`:* entries pointing at done, archived or missing stubs are removed; a
  plan that survived its day unexecuted is re-argued, not silently carried.
- *Unmet `blocked:` lines:* a stub whose recorded blockage has visibly lifted gets the
  line removed (ask when unsure).
- *Legacy-unmigrated:* flat `PREFIX-NNN` tickets the hygiene report lists are migration
  work — note the repo for a `/project` re-cut; never mass-convert here.
- *Active repo, empty intake:* real work happening off-ticket — repos carrying
  `.icm/dormant` are parked and never reported. Read the log; offer to cut stubs from
  recent history. `ticket-scout` proposes per repo — batch, never create unasked.

**3. Plan — bare `/day`.** Ask what tomorrow (or this week) is for, grounded in board
candidates in this order: P0 stubs · in-flight runs that stalled · blocked/waiting that
may have unblocked · each active epic's **next** stub (lowest unmet sequence) ·
longest-waiting P1 triage stubs · active repos with nothing ticketed.
- *Day:* write [`.icm/today.md`](../../../../.icm/today.md) **wholesale** — replacing it
  is clearing yesterday's flags. Format, one line per pick, **at most 10 across the
  whole estate**:

  ```md
  # Today — <YYYY-MM-DD>

  - <repo> · <epic-slug>/<feature-slug> — <title>
  - <repo> · triage/<slug> — <title>
  ```

  If Jamie wants more than 10, push back once (a diluted list is no list), then obey.
- *Week:* walk priorities and build orders — what is genuinely P0/P1 now, what demotes,
  what dies. Dead stubs to their epic's `_done/` with `> Dropped: <reason, date>`, per
  Jamie's call.
If a repo's priorities look wrong at the *project* level, that's `/project <repo>`, not
this ritual. Say so and move on.

**4. Close out — `/day wrap`.**
- *Bank what finished:* stubs whose work merged this session → `_done/`; epics that
  completed → archived whole.
- *Cut what's left:* anything discovered, started, half-done or promised becomes a stub —
  in the epic it belongs to, a new single-stub epic, or `triage/` with its lane. In
  `intake`-profile repos give it a standalone `## Prompt`. **Never a loose `TODO.md`.**
  Cutting is part of stopping.
- *Trim `today.md`:* remove entries that finished; what remains is tomorrow's honest
  starting point until the next plan replaces it.
- *Note the drift:* work no stub described gets said plainly in the summary — that's how
  off-ticket work gets caught next time.

**5. Ship — pushing is publishing.** The board reads each repo's `main`; an unpushed
stub does not exist. Per changed repo: commit **only** `.icm/` paths on `main` (message
`Plan: <one line>` or `Wrap: <one line>`) and push — stage paths explicitly, **never
`git add -A`**; anything else dirty is left strictly alone. A rejected push gets one
`pull --rebase` and retry; otherwise report and move on. Never force-push.

## Gate — Jamie

- Answers the ambiguity batches (2) — merged-or-not, blockage lifted-or-not.
- Sets the day's/week's intent (3); his call overrides the candidate order, and the
  `today.md` he leaves is the truth the morning reads.
- Sees the per-repo ticket diff before anything is committed (5).

## Outputs

| Artifact | Lands in |
|---|---|
| Stub moves, cuts, epic archives | each repo's `.icm/intake/`, pushed to `main` |
| `.icm/today.md` | this repo, pushed to `main` — the worklist on the phone |

## Audit

- After the run, `tickets-board.sh --today` shows ≤10 entries, every one resolving to a
  real open stub, all deliberately chosen today.
- No stub file deleted, no slug reused within an epic, no non-`.icm` path touched.
- Every claim of "merged" traces to a real work commit, not a sweep.

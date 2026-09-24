# deliver/day — keep the board honest, then decide what's next

Entered by `/day [wrap]`. Work from the Apps root. Sustentus is reconciled like any repo
(D44): its stubs and runs appear on the board, may be picked for `today.md`, and are
hygiene-checked.

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
| 4 | Each repo's `.icm/intake/` + `runs/` + git log **at `origin/main`** (D39 §8) | The reality the board must match |

## Process

**1. Survey.** Run `pull-all.sh` first — both scripts read each client repo at
`origin/main` (the one home of its ticket state, D39 §8), so the refs are only as fresh as
the last fetch. Run `tickets-board.sh` and show the board. Run `ticket-hygiene.sh` and show
what it found. The scripts report; **you verify and fix with judgment** — never bulk-apply
their findings. Verify a client repo the same way: `git -C projects/<repo> show
origin/main:<path>` and `git log origin/main`, never its checkout.

**Where a client repo is edited.** Every stub move and cut in steps 2 and 4 is made in a
worktree of that repo cut from `origin/main` — the one step 5 pushes from — never in the
shared `projects/<repo>` checkout: one tree serves every session and the sweeper, and
whatever branch or state it was left in is not `main`'s.

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
- *Disjointness (D26):* when two of today's picks in the same repo name overlapping
  `touches:` guesses (a stub's `Notes for Define`, or a live run's `spec.md`), say so in
  one line beside the list — the pair is sequenced, not run in parallel; `new-run.sh`
  will warn again when the second is cut. Say it, never reorder silently.
- *Week:* walk priorities and build orders — what is genuinely P0/P1 now, what demotes,
  what dies. Dead stubs to their epic's `_done/` with `> Dropped: <reason, date>`, per
  Jamie's call.
If a repo's priorities look wrong at the *project* level, that's `/project <repo>`, not
this ritual. Say so and move on.

**4. Close out — `/day wrap`.**
- *Bank what finished:* stubs whose work merged this session → `_done/`; epics that
  completed → archived whole.
- *Cut what's left:* anything discovered, started, half-done or promised becomes a stub —
  in the epic it belongs to, a new single-stub epic, or `triage/` with its lane. In a
  repo without the `/pipeline` router give it a standalone `## Prompt` — the board sends
  the verb where the router exists and the body where it does not (D26). **Never a loose
  `TODO.md`.**
  Cutting is part of stopping.
- *Trim `today.md`:* remove entries that finished; what remains is tomorrow's honest
  starting point until the next plan replaces it.
- *Note the drift:* work no stub described gets said plainly in the summary — that's how
  off-ticket work gets caught next time.

**5. Ship — pushing is publishing.** The board reads each repo's `main` (D39 §8), so a stub
exists once it is pushed there. Per changed client repo: **one direct commit to `main`**, no
PR — the shape is the repo's `pr-conventions` skill → Ticket commits (message `Plan: <one
line>` or `Wrap: <one line>`, paths `.icm/intake/**` only, verified before the push). Commit
**in the worktree** of step 1 (`git -C projects/<repo> worktree add <scratch> origin/main`)
and `git push origin HEAD:main`, never by switching the shared `projects/<repo>` checkout; a
checkout that had to move goes back to `main` before this step ends. Stage paths
explicitly, **never `git add -A`**; anything else dirty is left strictly alone. A rejected
push gets one `pull --rebase` and retry; still refused → report and move on. Never
force-push.
- **This repo the same:** its own stub moves and `.icm/today.md` commit straight to `main`
  (`Plan:` / `Wrap:`) and push.

## Gate — Jamie

- Answers the ambiguity batches (2) — merged-or-not, blockage lifted-or-not.
- Sets the day's/week's intent (3); his call overrides the candidate order, and the
  `today.md` he leaves is the truth the morning reads.
- Sees the per-repo ticket diff before anything is committed (5).

## Outputs

| Artifact | Lands in |
|---|---|
| Stub moves, cuts, epic archives | each repo's `.icm/intake/`, one direct commit pushed to its `main` (this repo's included) |
| `.icm/today.md` | this repo, pushed to `main` — the worklist on the phone |

## Audit

- After the run, `tickets-board.sh --today` shows ≤10 entries, every one resolving to a
  real open stub, all deliberately chosen today.
- No stub file deleted, no slug reused within an epic, no non-`.icm` path touched.
- Every claim of "merged" traces to a real work commit, not a sweep.

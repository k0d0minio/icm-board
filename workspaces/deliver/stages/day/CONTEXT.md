# deliver/day — keep the board honest, then decide what's next

Entered by `/day [wrap]`. Work from the Apps root. Sustentus is exempt (its `.icm/`
plans itself).

**Two modes, one ritual.** Bare `/day` plans — reconcile, then flip tomorrow's picks.
`/day wrap` closes out — reconcile, then bank what happened and cut what's left. Both
share steps 1, 2 and 5, so running either after the other is harmless.

**This ritual touches only `.icm/intake/` ticket files.** Deciding *what a project is
for* is [`project`](../project/CONTEXT.md)'s job; this one moves tickets that already
exist and cuts the leftovers of work that already happened.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`TICKETS.md`](../../../../_system/contracts/TICKETS.md) | Status vocabulary, the ≤10 `today` cap, `_done/` rules |
| 4 | `_system/scripts/tickets-board.sh` output | The estate board |
| 4 | `_system/scripts/ticket-hygiene.sh` output | Drift candidates — verified, never bulk-applied |
| 4 | Each repo's `.icm/intake/` + git log | The reality the board must match |

## Process

**1. Survey.** Run `tickets-board.sh` and show the board. Run `ticket-hygiene.sh` and
show what it found. The scripts report; **you verify and fix with judgment** — never
bulk-apply their findings.

**2. Reconcile — the board must be true before it's useful.**
- *Merged but still open:* for each open ticket whose ID appears in merged commits,
  find the actual work commit — the commit that created the ticket doesn't count, nor
  does an estate-sweep commit. Genuinely merged → `git mv` to `_done/`. Ambiguous →
  batch the questions and ask.
- *`today` dilution:* more than 3 flagged estate-wide means none are. List them, ask
  which ≤10 survive; the rest to `ready`. Stale flags from a past day default to `ready`
  without asking.
- *Prefix drift:* an intake README using a prefix missing from
  [`TICKETS.md`](../../../../_system/contracts/TICKETS.md) gets reconciled — the spec
  follows reality once tickets exist; before the first ticket, reality follows Jamie.
- *Active repo, empty intake:* real work happening off-ticket — repos carrying an empty
  `.icm/dormant` are parked and never reported. Distinguish client work
  from sweep/config commits by reading the log; offer to cut tickets from recent
  history. `ticket-scout` proposes per repo — batch, never create unasked.

**3. Plan — bare `/day`.** Ask what tomorrow (or this week) is for, grounded in board
candidates in this order: P0s · stalled in-progress · blocked that may have unblocked ·
P1s longest waiting · active repos with nothing ticketed.
- *Day:* clear every leftover `today` first (to `ready` unless Jamie says otherwise),
  then flip tomorrow's picks — **at most 3 across the whole estate.** If Jamie wants
  more, push back once (a diluted flag is no flag), then obey.
- *Week:* walk the Priority rows — what is genuinely P0/P1 now, what demotes, what
  dies. Dead tickets to `_done/` with `> Dropped: <reason, date>`, or deleted, per
  Jamie's call.
If a repo's priorities look wrong at the *project* level, that's `/project <repo>`, not
this ritual. Say so and move on.

**4. Close out — `/day wrap`.**
- *Bank what finished:* tickets whose work merged this session → `_done/`.
- *Cut what's left:* anything discovered, started, half-done or promised becomes a
  ticket with a standalone `## Prompt`. **Never a loose `TODO.md`.** Cutting tickets is
  part of stopping.
- *Clear the flags:* unfinished `today` back to `ready`; a flag that survives its night
  is noise.
- *Note the drift:* work no ticket described gets said plainly in the summary — that's
  how off-ticket work gets caught next time.

**5. Ship — pushing is publishing.** The board reads each repo's `main`; an unpushed
ticket does not exist. Per changed repo: commit **only** `.icm/` paths on `main`
(message `Plan: <one line>` or `Wrap: <one line>`) and push — stage paths explicitly,
**never `git add -A`**; anything else dirty is left strictly alone. A rejected push gets
one `pull --rebase` and retry; otherwise report and move on. Never force-push.

## Gate — Jamie

- Answers the ambiguity batches (2) — merged-or-not, which ≤10 survive.
- Sets the day's/week's intent (3); his call overrides the candidate order.
- Sees the per-repo ticket diff before anything is committed (5).

## Outputs

| Artifact | Lands in |
|---|---|
| Ticket moves, flips, cuts | each repo's `.icm/intake/`, pushed to `main` |
| The Today list | printed last — that's the worklist on the phone |

## Audit

- After the run, `tickets-board.sh --today` shows ≤10, all deliberately chosen today.
- No ticket file deleted, no number reused, no non-`.icm` path touched.
- Every claim of "merged" traces to a real work commit, not a sweep.

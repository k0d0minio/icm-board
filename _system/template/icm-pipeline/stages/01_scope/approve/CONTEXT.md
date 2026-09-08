# Stage 01a — Scope approved (substage contract)

Invoked via `/pipeline approve <slug>`. Your job is **one thing**: take the story as the author
wrote it plus the answers they gave to the questions Scope raised, and **settle** them into one
agreed scope at `.icm/runs/<slug>/01_scope/output/scope.md`, then cut the intake batch from it. No
spec, no code.

This is a substage of Scope, not a stage of its own: it has no gate after it and produces no PR of
its own. Scope commits the story and stops at the gate; the author answers in their own time,
through the owner; this substage is what turns "they have answered" into "the scope is settled and
in the repo". Define reads `scope.md` and never re-reads the story to reinterpret it.

## Why the settle exists

An answered question sheet is not a scope. Answers arrive as one-liners against `Q-n` rows — "yes",
"no, 30 days not 14", "only for vendors" — and each one silently rewrites part of the story it sits
against. Left unreconciled, the story still says 14 days while the answer says 30, so every reader
after Scope has to re-do the same reconciliation and can reach a different answer each time. The
cut inherits the ambiguity; the spec repeats it.

So the reconciliation happens **once**, here, in the stage that owns the scope. What lands in the
repo reads as a single coherent document with nothing left open — the story as written, then an
addendum that says what was agreed on top of it.

## The canonical scope moves here

There is exactly one canonical scope at every moment, and this substage is where it first exists:

| From               | Until                   | Canonical  |
| ------------------ | ----------------------- | ---------- |
| this substage runs | Define writes `spec.md` | `scope.md` |
| Define onward      | Release                 | `spec.md`  |

Before this substage there is no canonical scope — only the author's story (verbatim, in
`_source/story.md`) and the open questions. After it, `_source/story.md` is the **record of what was
asked for**, never edited again, and `scope.md` is what everything downstream reads. Correcting
`scope.md` is a plain edit here (re-run the cut if the change is cut-affecting). If the author needs
another round on the substance, that's `/pipeline scope <slug>` — a revision, then
`/pipeline approve <slug>` again, which replaces `scope.md` wholesale.

## Approval is assumed

The owner invoking this substage **is** the record that the author agreed the settled story. The
author is never in the session: they answered on their own time, and the owner moving the run
forward is how that reaches you. Do not re-ask for approval, do not wait for a relayed ✅, and do
not re-open the interrogation.

If the owner says in the same breath that the scope is *not* agreed, that's a
`/pipeline scope <slug>` revision — stop and say so.

## Inputs (read only these)

- `.icm/runs/<slug>/01_scope/_source/story.md` — the story, verbatim. **The body of the scope.**
- `.icm/runs/<slug>/01_scope/output/questions.md` — the question sheet Scope raised, plus whatever
  was settled in session and the assumptions taken.
- **The answers** — as the owner relays them (in the argument, in the conversation, or already
  written into the `Answer` column of `questions.md`). A `Q-n` with no answer anywhere is answered
  by its own **Recommendation if nothing comes back** — that is what the recommendation column is
  for, and taking it is an agreement, not a guess.
- `.icm/runs/<slug>/run.md` — `author:`.
- For the cut (step 6 only): `.icm/intake/README.md` — the decomposition contract.

Inherit Scope's rule: **do not read source code at all** (`stages/01_scope/CONTEXT.md` → "Scope is
business and product logic only"). The settle is a reconciliation of what the author wrote and
answered, not a feasibility pass. Nothing about the current system belongs in `scope.md`.

The Inputs above are the context budget.

## Process

1. **Resolve the run.**
   - `.icm/runs/<slug>/01_scope/_source/story.md` and `01_scope/output/questions.md` must both
     exist. Missing → Scope never ran for this slug (or the slug is wrong): send the owner to
     `/pipeline scope "<story>"` and **STOP**.
   - **Never write a `scope.md` from the conversation, from an intake stub, or from your own
     reasoning.** A fabricated scope is indistinguishable from an agreed one three stages later.

2. **Collect the answers.** Read the question sheet in full before settling anything, then pair
   every `Q-n` with its answer:
   - an **explicit answer** from the author (relayed by the owner, or in the `Answer` column);
   - **silence** → the row's stated recommendation stands. Record it as answered by default, not as
     unanswered.
   - a **counter-proposal** — an answer that changes something the question didn't ask about. That
     is new material: settle it in, and record it under **New material**.

   Anything settled in session already has its answer on the sheet; carry those across too.

3. **Settle.** Produce one coherent document (shape under Outputs) — the story text followed by the
   addendum. The rules, in order of precedence:
   - **The story is the body, unedited.** `scope.md` reproduces `_source/story.md` as written. You
     are not rewriting the author's words; you are stating, below them, what was agreed on top.
   - **The answers win over the story.** Where an answer contradicts the story — a different
     threshold, a narrower persona, a rule struck — the answer is the later thought and the
     addendum says so explicitly, naming the line it overrides. Never quietly edit the story to
     match; the diff between the two is the value of keeping the story verbatim.
   - **Every `Q-n` ends answered**, in the `## Questions & answers` table — by an explicit answer,
     by its recommendation standing, or by being withdrawn (say why). A `Q-n` left open in
     `scope.md` is a bug: it means a later stage reads an open question as settled scope.
   - **Assumptions are stated, not implied.** Everything the scope relies on that the story didn't
     say goes in `## Assumptions`, in business terms.
   - **Ids never renumber.** `Q-n` is the trace from questions → scope → stub → spec. A withdrawn
     question keeps its number; new material raised by an answer gets the next free number.
   - **Never invent.** If settling an answer requires a fact nobody gave, that's step 4, not a
     judgement call.

4. **Anything ambiguous → STOP and ask.** An answer you cannot settle **unambiguously** is not
   yours to resolve:
   - it contradicts another answer, and neither is clearly later;
   - it reads as a slip (names the wrong role, the wrong number) and taking it literally would
     invert a rule;
   - it asks for something whose substance isn't in the story, so settling it means writing new
     scope;
   - it asks for something outside this scope's subject entirely.

   Ask the owner, with the answer quoted and both readings spelled out. They can usually settle it.
   If they can't, it goes back to the author as a `/pipeline scope <slug>` revision: **stop and say
   so, with the answer quoted.** Do not settle a guess and do not settle "the most likely reading" —
   a wrong settle is invisible from here on, and a flagged one costs a message.

5. **Write `.icm/runs/<slug>/01_scope/output/scope.md`** — the shape under Outputs: the pointer
   header, the story verbatim, then `## Assumptions` · `## Questions & answers` · `## Out of scope`.

   The **`## Questions & answers` table is the audit trail** — it is what replaces reading the story
   and the sheet side by side. Every `Q-n` from `questions.md` appears in it exactly once, including
   the ones that changed nothing. Count the rows on the sheet and count the rows in the table; they
   match or you missed one.

6. **Cut the intake batch — from `scope.md`.** Read `.icm/intake/README.md` and follow it, cutting
   the settled scope into `.icm/intake/<slug>/breakdown.md` + one stub per future feature PR,
   strictly sequenced. Cutting here rather than in Scope is the point of this substage: the author
   may have struck a rule, added a persona or moved something out of scope, and a stub cut before
   they answered quietly specs work they removed. **Every scope gets an intake folder, however
   small** — a single-PR scope gets one stub whose `feature-slug` is the scope slug itself.
   Validate it: `.icm/scripts/validate-intake.sh <slug>` → `RESULT: OK`.

7. **Update `run.md` and push everything to `main`.** Append `scope-agreed:` and `stubs:` to
   `run.md`. Commit `scope.md`, the intake folder and `run.md` straight to `main` — markdown-only
   artifacts, and landing them immediately keeps the front device-independent. Commit message:
   `docs: <slug> — scope approved (settled + intake cut)`. Touch nothing outside
   `.icm/runs/<slug>/**` and `.icm/intake/<slug>/**`. If branch protection rejects the direct push,
   fall back to a tiny docs-only PR merged green (`_shared/github.md`) — never leave the front's
   artifacts local-only.

8. **Stop.** Report: the `scope.md` path, the answer counts (explicit / recommendation stood /
   withdrawn), any new material an answer introduced, the intake folder with its stub count and
   order, and that `/pipeline new` walks the batch into Define. Hand back anything you raised in
   step 4 that is still open.

**Already approved?** If `scope.md` exists and covers the same `Q-n` set, say so in one line and
stop — do not re-settle. Re-settle only when the story or the questions have changed since (a
`/pipeline scope` revision round) or the owner asks, and when you do, replace the file wholesale
rather than editing it in place, and re-run the cut.

## Outputs

- `.icm/runs/<slug>/01_scope/output/scope.md` — the settled scope: story + addendum. **The canonical
  scope** from now until Define writes `spec.md`.

  ```md
  # Scope: <title>

  - slug: <slug>
  - story: 01_scope/_source/story.md
  - author: <who wrote it>
  - agreed: <YYYY-MM-DD>
  - stubs: intake/<slug>/ (<n>)
  - canonical: until Define writes spec.md

  ## The story

  <the text of _source/story.md, reproduced verbatim>

  ## Assumptions

  - <what the scope relies on that the story didn't say — business terms>

  ## Questions & answers

  | ID  | Question | Answered            | What was agreed             |
  | --- | -------- | ------------------- | --------------------------- |
  | Q-1 | <…>      | author / default / withdrawn | <the rule, and the story line it overrides if it does> |

  ## Out of scope

  - <what this scope deliberately does not cover, in business terms>
  ```

- `.icm/intake/<slug>/` — `breakdown.md` + one stub per future feature PR.
- `.icm/runs/<slug>/run.md` — `scope-agreed:` and `stubs:` appended.

All three on `main` (or in one merged docs-only PR). No spec, no feature branch, no feature PR.

## Verify (before handing off)

- `scope.md` exists, opens with the pointer header, reproduces the story **verbatim**, and carries
  all three addendum sections in order.
- **The story in `scope.md` matches `_source/story.md` exactly** — the settle changes the addendum,
  never the body. Diff them.
- **Nothing is left open.** No unanswered `Q-n`, no "to be confirmed", no bracketed marker anywhere
  in the document.
- **Every question is accounted for.** The `## Questions & answers` row count equals the `Q-n` count
  on the sheet, each appears exactly once, and each says what was agreed — including the ones where
  the recommendation simply stood.
- **The answers won.** Spot-check every answer that contradicted the story: the addendum states the
  override and names the line it overrides.
- **Nothing was invented.** No rule, persona or requirement in `scope.md` that isn't in the story or
  in an answer. No statement about what the system does today.
- **Nothing ambiguous was settled silently** — every answer that needed a judgement call was raised
  with the owner (step 4) and its resolution is in the table, or the stage stopped.
- The intake folder exists with ≥1 stub, passes `.icm/scripts/validate-intake.sh <slug>` →
  `RESULT: OK`, and **was cut from `scope.md`** — no stub specs work the author struck out.
- `run.md` carries `story:`, `author:`, `scope-agreed:` and `stubs:`.
- All artifacts committed on `main` (or a merged docs-only PR) and pushed — resumable from any
  device.
- No spec, no code, no feature branch, no feature PR.

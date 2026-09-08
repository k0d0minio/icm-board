# Stage 01 — Scope (contract)

Invoked via `/pipeline scope "<story>"` (or `/pipeline scope <slug>` to revise). Your job is **one
thing**: take the **written request** the work arrived as, commit it to the repo **verbatim**, and
interrogate everything it leaves ambiguous until the business logic is settled or every open
question is on the record. No spec, no code, no feature PR.

**Work arrives as a story.** Someone outside this session wrote it — call them **the author** — and
the channel varies (a message, an email, notes from a call); this contract does not fix one. The
owner supplies the text in-session: that text is the input, and it is the thing the author will be
held to. You do not rewrite it, summarise it, or improve it — you commit it as it was written and
then ask about what it doesn't say.

**This stage is optional.** A repo with no business author behind its work does not need a front:
plain-English work goes straight to `/pipeline new` and Define picks the slug. Scope is for the
case where someone else's words are the requirement.

**This stage ends at the gate.** The author answers in their own time, through the owner. Turning
those answers into a settled scope, and cutting the intake batch from it, is the **Scope approved**
substage, `/pipeline approve <slug>` (`stages/01_scope/approve/CONTEXT.md`). Don't do its work
here: the answers are not in yet, and everything downstream is cut from the settled story, not from
your reading of the draft.

## Scope is business and product logic only — nothing else

**This is the rule that governs every other rule in this contract.** The author wrote the story to
say how things should work. They do not care what the system does today, what is already built, or
how any of it is implemented — and telling them makes the questions harder to answer and biases the
answer toward whatever happens to exist.

So everything you write here — every question, every assumption, the whole settled scope that
follows — describes **how it should work**, in the language the business uses, as if the system
were being designed from nothing. Write the target logic, not the delta from today.

Never put any of these in a question, an assumption, or the scope (or in the conversation you build
them from):

- File paths, line references, function/component/route/collection/field/table names, API
  endpoints, schemas, env vars, or any identifier that only exists in the codebase.
- Framework, library or vendor names — including "we already use X for this". If a capability
  matters, name it in business terms ("the customer is notified by email").
- Statements about the current implementation: "this already exists", "we'd extend the existing
  table", "there's currently no endpoint for this".
- Effort, sizing, sequencing or feasibility framing — "this is a small change", "phase 2",
  "technically difficult". The cut (in the approve substage) handles sequencing; Define handles
  feasibility.
- Screens described as UI mechanics (button placement, modals, tabs). Name the surface and what a
  person must be able to **decide or do** there — never the control they click.

**Translation, not omission.** When something genuinely constrains the business logic, state the
constraint in business terms — not "there's no vendor reference on the record" but "today a lead
cannot be attributed to a vendor; the logic below assumes it must be able to be."

If the honest answer to a question is "it depends what's already built", that's not a scope
sentence — that's a question for the owner or for the author.

**The author is not in the session.** They wrote the story and went back to their own work; the
owner is the channel to them. So the interrogation has two lanes: questions the **owner** can
answer are asked directly in-session; anything the owner can't settle — an unknown, an assumption,
a fork only the author can pick — goes on the question sheet for the owner to put to them. Never
silently assume an answer, and never block the stage waiting for one: write it down and move on.

## Inputs (read only these)

- **The story** — the text the owner supplies as the argument or in the conversation. This is the
  stage's subject; everything else frames it.
- The repo's own business/product docs, if it has any — `.icm/CONTEXT.md` says where they live.
  Read them for **vocabulary and direction** (the entities, journey steps and persona names the
  business uses) so the questions read as one product — never for what is implemented.
- If revising: the existing `.icm/runs/<slug>/01_scope/_source/story.md` and
  `01_scope/output/questions.md`.

**Do not read source code at all** — no application source, no conventions file, no schemas, no
config, and no other `.icm/runs/**`. Not to check a fact, not to "confirm a seam", not to see
whether something already exists. There is no targeted-grep exception in this stage: the current
state of the system is exactly what the scope must be free of, and every look at the code leaks
into what you write.

Missing knowledge is resolved the same way every other unknown is: ask the owner, or put it on the
question sheet. Never by reading the codebase.

The Inputs above are the context budget.

## Process

1. **Pick the slug** — short kebab-case (e.g. `csv-export`). It names everything from here on: the
   run folder, the intake epic, the branch and PR of every stub cut from it. One string traces the
   work end to end across every surface. Reuse the given slug if revising.

2. **Commit the story verbatim.** Write the author's text, unedited, to
   `.icm/runs/<slug>/01_scope/_source/story.md` under a two-line header:

   ```md
   <!-- The story as written by <author>, <YYYY-MM-DD>, via <channel>.
        Verbatim. Never edited — corrections and answers land in scope.md at approve. -->
   ```

   **Verbatim means verbatim.** Don't fix the grammar, don't reorder it into sections, don't split
   a paragraph into bullets, don't drop the aside that looks irrelevant. The whole point of this
   file is that a reader three stages later can see exactly what was asked for, separately from
   what we made of it. If the story arrived as several messages, concatenate them in order, each
   under its own dated sub-heading; if it arrived as call notes, say so in the header and commit
   the notes as they are.

3. **Interrogate it — two lanes.** A story says what someone wants; a scope says how things work
   when they have it. The gap between those is this step, and it is the whole stage.

   Go deep on the logic itself: who acts, what starts it, what happens in what order, what the
   rules and thresholds are, what state things are in and what moves them, who is told what and
   when, what money/time is involved, and what happens when it goes wrong. Get concrete — real
   amounts, real durations, real counts. Every number is either something the story states, or a
   proposed default the author can overrule.

   Where a rule is genuinely undetermined, **propose one and ask about it** — a proposal with a
   question beats a blank, because the author can answer a proposal in one word and has to draft
   from scratch to answer a blank. Never resolve a question by reasoning about what the system does
   today.

   The two lanes:
   - **In-session:** ask the owner sharp questions about anything the story plausibly settles, or
     that they know from the conversation behind it. Don't manufacture questions when the answer is
     already on the table.
   - **For the author, via the owner:** anything the owner can't settle — an unknown, an assumption
     you'd otherwise have to make, a fork only the author can pick — goes on the question sheet
     (step 4). Write each as a crisp, answerable question (yes/no or pick-one where possible),
     never open-ended musing, and state the recommendation we'd take if they don't mind — that's
     what they approve by not replying to it.

   **Out of scope** is worked out here and stays business-level ("we are not handling refunds this
   round"), never technical ("no API changes"). It prevents more rework than anything else.

   For a spike or investigation, the same two lanes land findings + a recommendation + the decision
   the author needs to make — findings about the business, not about the codebase.

4. **Write the question sheet** to `.icm/runs/<slug>/01_scope/output/questions.md`. This is the
   sheet the owner puts in front of the author, and the sheet the approve substage settles from:

   ```md
   # Questions: <slug>

   - story: 01_scope/_source/story.md
   - author: <who wrote it>
   - asked: <YYYY-MM-DD>

   ## For the author

   | ID  | Question                             | Recommendation if nothing comes back | Answer |
   | --- | ------------------------------------ | ------------------------------------ | ------ |
   | Q-1 | <crisp yes/no or pick-one, one line> | <what we'd do by default>            |        |

   ## Settled in session

   - <question> → <answer> · <owner, YYYY-MM-DD>

   ## Assumptions taken

   - <the assumption, in business terms — each one either has a Q-n above or is safe enough to state>

   ## Out of scope

   - <what this scope deliberately does not cover, in business terms>
   ```

   **`Q-n` ids are permanent** — they are the trace from story → questions → scope → stub → spec.
   Never renumber; a withdrawn question keeps its number and says so. The `Answer` column stays
   empty here; the author's answers land in `scope.md` at approve, which is where the record lives.

   No questions at all is a legitimate outcome for a fully-specified story — write
   `None — the story settled in session.` under **For the author** and say so at the gate.

5. **Write `.icm/runs/<slug>/run.md`** (shape below) and **commit everything straight to `main` and
   push** — `story.md`, `questions.md` and `run.md` are markdown-only artifacts, and landing them
   immediately keeps every device in sync (no single-device front). Commit message:
   `docs: <slug> — story committed, questions raised`. Touch nothing outside
   `.icm/runs/<slug>/**`. If branch protection rejects the direct push, fall back to a tiny
   docs-only PR merged green (`_shared/github.md`).

   **Do not write `scope.md`, and do not cut the intake batch.** Both are the approve substage's
   job, and both depend on answers you don't have yet — the author may strike a rule, add a persona
   or move something out of scope, and anything cut now quietly carries work they removed.
   `.icm/intake/<slug>/` stays empty until they have answered.

6. **Gate — HARD, and it happens away from the session.** Hand over the story path, the `Q-n` list,
   and **stop**. The author is never in this conversation: the owner puts the questions to them,
   they answer in their own time, and then the owner runs `/pipeline approve <slug>`, which settles
   the answers into `scope.md` and cuts the batch — **running it is what closes this gate.** There
   is nothing to relay and nobody to wait on in-session.

   On agreement the story **freezes**: `_source/story.md` is never edited again, and the canonical
   scope passes to `scope.md` (at approve) and then to `spec.md` (at Define). Any later change is a
   visible `spec.md` revision that re-opens the **Spec approved** tick. Scope never changes silently
   — there is exactly one canonical scope per unit of work at every moment.

7. **Stop.** Tell the owner: where the story landed, the `Q-n` list the author must answer, and
   that the next step — once they have — is `/pipeline approve <slug>`, which settles the answers
   into `01_scope/output/scope.md` and cuts the intake batch. Define comes after that.

## Outputs

- `.icm/runs/<slug>/01_scope/_source/story.md` — the story as written. **Verbatim, never edited.**
- `.icm/runs/<slug>/01_scope/output/questions.md` — the question sheet (step 4).
- `.icm/runs/<slug>/run.md` — the run's pointer index:

  ```md
  # Run: <slug>

  - lane: front
  - story: 01_scope/_source/story.md
  - author: <who wrote it>
  ```

The approve substage appends `scope-agreed:` + `stubs:`. A front run opens **no PR of its own** —
that is what marks it a front, and it is how `close-out.sh` recognises one.

**No settled scope is written by this stage** — not `scope.md`, not `.icm/intake/<slug>/`. The
story is the author's words and the questions are ours; reconciling the two is the approve
substage's job, and it needs answers this stage does not have.

## Verify (before handing off)

- `_source/story.md` exists, carries the provenance header (author, date, channel), and is the
  author's text **unedited** — no tidying, no restructuring, nothing dropped. Read it against what
  the owner supplied, line for line.
- **The interrogation is real.** The questions cover the actual gaps — who acts, what the rules and
  thresholds are, what state moves what, who is told what, what happens when it goes wrong. If the
  author could read the sheet and only reply "yes, all fine", it wasn't worth their time.
- **Every unknown is either answered in-session or raised as a `Q-n` — nothing was silently
  assumed.** Every `Q-n` states the recommendation taken by default; every assumption in
  **Assumptions taken** either has a `Q-n` or is safe enough to state without one.
- **Out of scope is filled**, in business terms.
- **Everything is pure business and product logic.** Re-read the question sheet end to end against
  the top-of-contract rule: no file paths, no function/component/route/field names, no framework or
  vendor names, no "already exists / currently doesn't", no effort or feasibility talk. One
  offending sentence → rewrite it in business terms before handing over.
- **No source code was read this stage.**
- You stopped at the gate and handed over the story path plus the `Q-n` list — you did not
  self-advance into the settle or the cut.
- `run.md` exists, carries `story:` and `author:`, and is committed on `main` and pushed — without
  the push the front is stuck on one device.
- **No `scope.md` was written and no intake folder was cut** — `.icm/intake/<slug>/` is still
  empty. Both are `/pipeline approve <slug>`'s to produce, from the answers the author actually
  gave.
- No spec, no code, no feature branch, no feature PR was created.

# Stage 03 — Build (contract)

Invoked via `/pipeline build <slug>`. The `/pipeline` router reads this file and follows it. Your
job: turn the approved spec into working code on the run's branch, then flip the run's draft PR to
open (ready for review) **and push**, so the full gate and the previews land. Reviews and the
merge are Release's job — the operator smoke-tests the preview of what you hand over and ticks
**Ready to merge** on the strength of it, so hand over only what you believe is complete.

**The cadence is blind-until-ready** (`_shared/ci.md` → verdict by phase): while the PR is draft,
every push runs the cheap CI tier and builds **no previews** — you are building blind, by the
operator's explicit decision, and that is not a defect to work around. The ready flip is the moment
the machine spends: the full gate re-earns the verdict and the affected product apps preview.
Build finishes on a cheap-tier GREEN, flips, pushes, and settles the full verdict — in that
order.

## Inputs (read only these)

- `.icm/_shared/stage-preamble.md` — run it **first**: it resolves the run into the working tree
  or STOPs. Never recreate a missing run.
- `.icm/runs/<slug>/02_define/output/spec.md` — the canonical spec you implement against.
- `.icm/runs/<slug>/run.md` — branch + PR pointers.
- The repo's code rules — the file `_shared/conventions.md` points at — plus the subtree
  `AGENTS.md` files, where the repo has them: the canonical code rules you must follow.
- `.icm/_shared/knowledge-map.md` — routes to the docs tree (`docs_path` in `.icm/project.json`).
  Read only the page(s) it names for Build: the architecture and package pages that say where
  code lives and which workspace package is the right entrypoint.
- `.icm/_shared/github.md` — the GitHub MCP calls (gate read, draft → open).
- `.icm/_shared/ci.md` — what the checks are and what green means. Step 9 depends on it.
- The specific source files named in the spec's `touches:` — those, not the whole repo.

Context budget: the Inputs table above is the budget (see `.icm/CONTEXT.md` → Layers) —
everything except the source files you actually edit. Record overruns on a one-line
`Context budget:` note in `notes.md`.

## Process

1. **Run the shared preamble** (`.icm/_shared/stage-preamble.md`) — resolve the run or STOP.
   Then the first act of every stage: `.icm/scripts/usage-snapshot.sh <slug> build start`
   (`SKIP` is fine, never a stop).
2. **Gate-check.** Read the PR body (GitHub MCP, per `_shared/github.md`): the **Spec approved**
   checkbox must be ticked. **If it isn't, STOP** — do not build against an unapproved spec, and
   never tick the box yourself. Tell the user to settle the spec (`revise <slug> "…"` if it
   needs changing) and tick the box, then re-run Build.
3. **Stage label — CI handles it.** The `pipeline.yaml` labels job re-projects labels on every
   push and derives `stage:*` from which run outputs exist, so committing `notes.md` (step 8) is
   what moves the board to `stage:build`. Skip `project-labels.sh` — it's only a manual fallback.
4. **Implement** the acceptance criteria, and only those. Follow the repo's code rules exactly.
   Keep edits minimal and focused — no drive-by refactors. Something broken or ugly that is
   **not this ticket's** → park it as a stub in `.icm/intake/triage/` (shape in
   `.icm/intake/CONTEXT.md`) and move on; never absorb it into this diff. **Cap notice:** if the
   folder then holds more than 60 active stubs (`ls .icm/intake/triage/*.md | wc -l`;
   `intake/CONTEXT.md` → Triage → cap), say so in your stop message — `triage/ holds N active
   stubs (cap 60) — run triage report` — and name `triage report` as the suggested next command.
   The finding is still parked either way.
   - **Tests ride along, scoped by the spec.** When the diff touches pure logic that already has
     unit tests, update them in the same commit — a knowingly-red suite never gets pushed as
     "someone else's problem". When the spec's acceptance criteria are unit-assertable (pure
     functions, validators, policy tables), write the asserting tests **from the criteria, not
     from your implementation** — that independence is the point. Do not add tests beyond the
     spec's scope, and never test the classes the repo's code rules exclude (their Testing
     section, where there is one). **Write them; don't run them** — the test run is blocked
     locally like every other gate, and the repo's quality workflow is what tells you whether
     they pass.
   - **Build does not gather requirements.** If the spec is ambiguous, or an `## Open questions`
     entry blocks an acceptance criterion, **do not** decide it here or invent an answer —
     **STOP** and send the user back to `revise <slug> "<what to change>"`, then re-run Build.
5. **Use capability skills where they apply.** For repeatable work (new shared component, new
   model, route, action, notification…) prefer the matching skill in `.claude/skills/` over
   hand-rolling it.
6. **Self-check** each acceptance criterion; if one can't be met, note it rather than dropping it.
   Tick the satisfied criteria in the PR body (tick state lives on the PR; the text stays the
   spec's — to reword, edit `spec.md` and reconcile).
7. **Commit and push — the factory verifies, not you.** Don't run the full sweep — format, lint,
   typecheck, test, build (see Verify below). A pre-commit hook formats on commit, where the repo
   has one; CI runs format/lint/typecheck; the Vercel preview builds the PR. Spend your turns on
   code. A pre-commit hook only exists in a fresh cloud session once the repo's dependencies are
   installed — if the session-start output said the hook is off, the commit lands unformatted.
   Two cheap, changed-files-only tools exist for exactly those gaps and nothing wider, where the
   repo wires them (`_shared/project-rules.md` → The factory): `.icm/scripts/format.sh` (the
   repo's formatter over the files the branch changed) before committing when the pre-commit
   hook is unavailable, and `.icm/scripts/lint.sh` (the repo's linter over the same files, each
   package's own config, the repo's warning ceiling in view) when CI reports a lint failure or
   before pushing a large change. Both run in seconds, build nothing, and end in one `RESULT:`
   line; neither is the verdict — CI is.
8. **Write build notes.** Commit the run files alongside the code and push, so the PR reflects
   current state.
9. **Establish a settled cheap-tier verdict on the draft head — Build does not flip an unread run.**

   First, the environment this branch changed, measured: `.icm/scripts/env.sh audit --changed`
   → `RESULT: OK`. `GAPS` names a key this branch added that is missing from a surface it is
   scoped to — declare it in `.env.example` (`env.sh doc <KEY>` prints the block) and tell the
   operator where the value must exist; the value is never yours. Release re-asks the same call
   as stop class 3, so a gap left here is a gap that stops the merge.

   Then the diff itself, scanned: `.icm/scripts/security-check.sh <slug>` → `RESULT: CLEAN` (or
   `SKIP`). `FINDINGS n` names a secret this branch **adds** (`file:line` and the rule — never
   the value) or a high/critical advisory in a lockfile this branch changed, and appends the
   same lines to `.icm/runs/<slug>/03_build/output/error.log`. A secret is removed from the
   diff **and rotated by the operator** — say so in `## Notes for Release`; an advisory is
   bumped here when the bump is in-ticket, else recorded there with its reason. Release re-runs
   the same call as stop class 2, so a finding left here is a finding that stops the merge.

   ```bash
   .icm/scripts/ci-status.sh <slug>
   ```

   It blocks until the run settles and prints `RESULT: GREEN | RED | PENDING`, naming the tier it
   settled on (`_shared/ci.md`). On a draft head that is the **cheap tier** — the checks the repo
   runs on a draft (`_shared/project-rules.md` → The factory), zero previews — and a draft GREEN
   authorises exactly one thing: the flip.
   - **GREEN** → go to step 10.
   - **RED** → this is your failure to fix, not Release's: read the failing job
     (`get_job_logs`, `failed_only: true`), fix on the branch, push, and re-run the call. Handing
     a red branch onward wastes the reviews on code that doesn't compile. If it is
     genuinely not yours to fix, say which check and why in `## Notes for Release` — never silently.
   - **PENDING** → the run didn't settle. Re-run the call. Never treat "nothing has failed yet"
     as green, and never read the verdict off a Vercel deployment event — those arrive per push
     and none of them is the verdict.

10. **Bring `main` in before the flip — a merge commit, never a rebase (D26).**

    ```bash
    git fetch origin main && git merge --no-edit origin/main
    ```

    Runs are cut for disjoint surfaces, but `main` has moved since this branch was cut, and
    the place to meet it is here — on the cheap tier, before the full gate and the previews
    spend anything — not at Release step 7, where a conflict costs a full gate and a smoke.
    Resolve conflicts on this branch; **a conflict inside `.icm/runs/<slug>/` itself is a
    STOP** (someone else wrote to this run — the preamble's run-folder rule). Release's step
    7(a) stays as the final merge and is usually a no-op after this. A merge that changed
    code takes the cheap tier again: re-run step 9's `ci-status.sh` before flipping.

11. **Flip ready, then push.** `update_pull_request`, `draft: false` (per `_shared/github.md`),
    **then push** — an empty commit (`git commit --allow-empty -m "chore: <slug> — ready"`) when
    nothing is pending. The flip itself produces no push, and previews build per push: the
    post-flip push is what makes the full-tier run and the affected product-app previews
    materialise on a fresh head, so the full verdict can never rest on a stale draft-era green.
    Open means "reviewable"; it is not the merge authorisation.
12. **Settle the full verdict on the post-flip head** — the same `ci-status.sh <slug>` call, which
    now reports the **full gate**: the checks the repo adds on a ready head
    (`_shared/project-rules.md` → The factory) and the affected product-app previews with their
    URLs. RED here is still yours to fix.
13. **Stop.** Last act: `.icm/scripts/usage-snapshot.sh <slug> build end`. Tell the user Build
    is done, the PR is open **with the full gate green**, and pass on the preview URLs the
    script listed. The path onward is: smoke-test those previews, tick **Ready to merge**, then
    `/pipeline release <slug>` — the tick attests the manual testing, so nothing after it
    re-asks.

## Outputs

**Run-scoped, without exception** (`.icm/_shared/stage-preamble.md` → Run-scoped isolation): every working artifact of this stage — notes, scratch
lists, intermediate results — lands under `.icm/runs/<slug>/03_build/`, on the run's own branch
`claude/<slug>` and in a working tree no other live run is using.

- Code on the run's branch, small conventional commits (`feat: <slug> — <what>`).
- A settled `GREEN` from `ci-status.sh` on the pushed head; `env.sh audit --changed` → `OK`;
  `security-check.sh <slug>` → `CLEAN` (or `SKIP`).
- `.icm/runs/<slug>/usage.md` with the `build start` and `build end` lines.
- The PR flipped from draft to open, satisfied acceptance criteria ticked.
- `.icm/runs/<slug>/03_build/output/notes.md`:

```md
# Build notes: <slug>

- commits: <short list>
- ci: <GREEN on <sha> | RED on <check> — why it is not mine to fix>

## What changed

- <file/area>: <why>

## Acceptance criteria status

- [x] <criterion> — <how it's met>
- [ ] <criterion> — <blocked because…>

## Notes for Release

- <anything the reviews should look at closely; a check you already know will fail, and why>
```

(Release later appends its own `## Release` record to this same file — leave the file ending
clean so the append reads naturally.)

## Verify (owned by the factory, not this agent)

Mechanical checks are deterministic, non-AI work — they belong to the factory (a pre-commit hook
where the repo has one + CI + the Vercel preview), not to your context window. **Do not run the
full sweep — format, lint, typecheck, test, build** — the `.claude/hooks/block-local-checks.sh`
`PreToolUse` hook blocks them, where the repo ships it: push and read CI back.

- **Format / Lint / Typecheck / Test** — the repo's quality workflow, tiered: a draft head runs
  the cheap tier, the ready phase adds the rest; which checks sit in which tier is the repo's own
  (`_shared/project-rules.md` → The factory). The **check run(s)** to look for on the PR are the
  repo's required check(s) (`required_checks` in `.icm/project.json`), and those are the names to
  require in branch protection. A required check that has not appeared means CI has not started,
  never "not applicable" — `ci-status.sh` waits for it. A pre-commit hook, where the repo has
  one, additionally auto-formats staged files.
- **Build** — the Vercel preview deploys, **from the ready flip on** (drafts are blind). These are
  **commit statuses, not check runs**: reading only the check runs is how a PR whose preview
  failed to compile looks entirely green. `.icm/_shared/ci.md` says how to read both surfaces and
  `_shared/project-rules.md` → The factory names the repo's deploy projects; `ci-status.sh` reads
  both surfaces for you.

Build, Release and every lane gate on the settled verdict from `ci-status.sh`. The only local
exception: if you _already know_ an edit introduced a type error, fix it before pushing rather than
burning a CI round-trip — but don't kick off a full-repo sweep to go looking.

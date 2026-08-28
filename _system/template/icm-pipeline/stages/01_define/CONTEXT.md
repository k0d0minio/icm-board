# Stage 01 — Define (contract)

Invoked via `/pipeline new` (walk the epic), `/pipeline new <stub|"request">`, or
`/pipeline define <slug>` (revise). Your job is **one thing**: produce a spec the owner
can approve, and open the run's **single feature PR** — one PR, one branch from here to
Release. No code here.

## Inputs (read only these)

- The intake stub, when one was passed (`.icm/intake/<epic>/<feature-slug>.md`) — it
  pre-seeds most of the spec; honour its epic's `breakdown.md` build order.
- The user's request, when there is no stub.
- `.icm/_shared/github.md` — the PR projection contract (the mechanics are scripted in
  `new-run.sh`; you supply only the one-line Summary).
- If revising: the existing `.icm/runs/<slug>/01_define/output/spec.md`.

A few targeted greps to confirm where something lives are fine; do not load the wider
codebase — that's Build's. The Inputs above are the context budget.

## Process

1. **Resolve the slug.** A stub's `feature-slug` is the slug; a plain request gets a
   short kebab-case slug you pick. Start from a fresh branch off `origin/main`.
2. **Resolve every remaining requirement here — Define is the last stage that gathers
   them.** Exact behaviour, touched areas, edge cases. If something that affects *what
   gets built* is ambiguous, ask sharp questions until nothing is open. Don't invent
   requirements, don't defer decisions to Build. Deliberate deferrals go under
   **Out of scope**, never left open.
3. **Write the spec** to `.icm/runs/<slug>/01_define/output/spec.md` (template below).
4. **Validate structurally (script, not eyeball):** `.icm/scripts/validate-spec.sh
   <slug>` → `RESULT: OK`, or fix what it lists. Heed its open-questions advisory.
5. **Open the run (script, not by hand):**

   ```bash
   .icm/scripts/new-run.sh <slug> --summary "<one plain sentence — what is true after this ships>" \
       [--stub .icm/intake/<epic>/<feature-slug>.md]
   ```

   It commits the run, consumes the stub into the epic's `_done/`, pushes, opens the
   draft PR (body projected from `spec.md`, both gate anchors), and writes `run.md`.
6. **Revising?** Edit `spec.md`, commit, push, re-run `validate-spec.sh`, then reconcile
   one direction only (file → PR body). Never re-run `new-run.sh` — one PR per run.
7. **Stop.** Point at the spec path + draft PR URL. **Ticking "Spec approved" on the PR
   is the gate** — Build won't start without it, and you never tick it.

## Outputs

`.icm/runs/<slug>/01_define/output/spec.md`:

```md
# Spec: <feature title>

- slug: <slug>
- touches: <areas/paths this will change — a best guess is fine>
- complexity: trivial | standard | complex

## Problem

<what's wrong / missing today, and why it matters — 2–4 sentences>

## Proposed change

<what we'll build, functionally — not implementation detail>

## Acceptance criteria

- [ ] <observable, testable outcome 1>

## Out of scope

- <things we are explicitly NOT doing this run>

## Open questions

- <only non-blocking notes, or "none" — anything affecting what gets built is decided
  before approval, or moved to Out of scope. Build will not answer it for you.>
```

Plus `run.md` and a **draft PR** whose body links to `spec.md` (never a copy).

## Verify (before handing off)

- Acceptance criteria are observable and checkable; no open question blocks one.
- The draft PR exists, both gate anchors present and unticked; `run.md` records
  branch + PR; everything committed and pushed — resumable from any device.
- You stopped for human review — you did not start building.

# Stub: Borrow four ideas from mattpocock/skills into the contracts, installing nothing

- lane: chore
- found-by: notes/mattpocock-skills.md (tool research, verdict Watch / borrow) · 2026-10-01
- priority: P2
- complexity: research
- sources: `notes/mattpocock-skills.md` (untracked, Jamie's `~/Apps` checkout) ·
  github.com/mattpocock/skills (MIT): `wizard`, `to-questionnaire`, `grilling` / `grill-me`, `pr`
- touches: `_system/template/icm-pipeline/_shared/output.md` (the `Operator:` list) ·
  `_system/template/icm-pipeline/lanes/handover/CONTEXT.md` ·
  `_system/template/icm-pipeline/stages/04_release/CONTEXT.md` ·
  `_system/template/claude/skills/pr-conventions/SKILL.md` ·
  `_system/template/claude-pipeline/skills/setup/SKILL.md` ·
  `workspaces/sell/references/call-crib.md` · `workspaces/sell/references/discovery-questions.md`

## Problem

mattpocock/skills is about 30 small engineering-discipline skills. Installing them estate-wide
would add a second process vocabulary beside the stage contracts (`/to-spec`, `/to-tickets`,
`/triage`, `/implement-spec`), plus a second way to cut a ticket and per-repo tracker config.
The house deleted exactly that kind of duplication. It would also put thirty global skills in
every repo, against the thin global layer.

Four of the skills do carry ideas the contracts lack:

1. **`wizard`.** Steps only a human can do (a Vercel custom environment, a ruleset, DNS, a token
   name) become a checked, resumable walkthrough, each with a verify command. Today they are a
   numbered `Operator:` list in chat and a bullet list in the handover. Some of those steps are
   still open weeks later.
2. **`to-questionnaire`.** When a decision belongs to one person, interview about the *send*
   (who reads the form, what they already know), not the subject, then hand them a form.
   `02_look`'s call crib and discovery questions are client-facing forms of exactly this kind.
3. **`grilling`.** Resolve every branch of a design before writing anything. `/setup` already
   asks intent first (D45); this is a sharper script for the same instinct.
4. **`pr`.** The smallest visual that makes the change clear, before/after evidence, and whether
   the change is a one-way or two-way door. All three are missing from `pr-conventions`.

Two ideas in the note are already covered, so nothing is ported for them:

- `depends-on:` and `sequence:` already give stubs blocking edges, which makes `blocks:`
  redundant.
- `/retro` overlaps the D27 retrospective collector.

The note's pointer to open questionnaire items Q22–Q24 is stale: those were answered on
2026-09-22.

## Proposed change

Read the four upstream `SKILL.md` files at HEAD and record the SHA. For each, write the smallest
contract edit that carries the idea in the estate's own words. Cite the upstream as the source
and vendor no text.

- **Operator steps** (`output.md`, handover lane, `04_release` close-out). Each `Operator:` item
  names where to do it and a read-only verify command, so the next session can confirm it
  happened instead of re-asking. A generated bash wizard is the alternative. Choose one, and say
  why; a script that *drives* steps is out, since the house never builds an orchestrator.
- **Questionnaire discipline** (`call-crib.md`, `discovery-questions.md`). Add one short "who is
  this for, what do they already know" pass before a form goes to a client.
- **Grilling in `/setup`.** Add an explicit "every branch resolved or parked as a question
  before anything is written" rule to the intent step. Size the gain against `/setup`'s
  current wording, and drop this one if the wording already holds it.
- **`pr-conventions`.** Add a PR body line on reversibility (one-way or two-way door), plus
  before/after evidence where a change has a visible effect.

Template files (`T`) ship as one icm-board PR and an `icm-sync.sh --apply`. Canonical `.claude/`
skills are drift-reported, never repaired, so a repo picks the change up on its next sync.
`workspaces/sell/` edits are icm-board-only.

## Acceptance

- [ ] Each of the four ideas lands as a contract edit or is dropped with a one-line reason
- [ ] No mattpocock skill is installed in any repo's `.claude/` or the template. If Jamie wants
      the full set for non-estate work, it is a machine plugin and that is his call.
- [ ] Upstream SHA recorded in the PR body

# Stub: The design capability skill — three tiers, taste-skill and impeccable distilled into it

- feature-slug: design-capability-skill
- epic: design-system-skills
- priority: P0
- size: L
- depends-on: research-fit-and-overlap, design-md-contract
- sequence: 3 of 7
- sources: `breakdown.md` → What I understood (2) · `_system/template/icm-pipeline/skills/README.md`
  (the three-tier contract, Level 1 ≤ 80 tokens, `list-skills.sh --check`) · the three seeded
  skills as the shape to copy · `Leonxlnx/taste-skill` `skills/taste-skill/SKILL.md` (87 KB,
  MIT; the dials `DESIGN_VARIANCE` / `MOTION_INTENSITY` / `VISUAL_DENSITY`; the "not
  dashboards" scope) and `skills/brandkit`, `redesign-skill`, `minimalist-skill` ·
  `pbakaus/impeccable` `.claude/skills/impeccable/SKILL.md` (12 KB, Apache-2.0; the
  `critique` / `audit` / `polish` / `bolder` / `quieter` / `typeset` / `layout` / `delight`
  sub-commands and the 61 detector rules) · `frontend-design` plugin `SKILL.md` (already
  installed — the overlap)

## Problem

The two prompt-side upstreams are large, general, and written for a harness that loads one
skill on demand by name. The estate loads capability skills by trigger from an always-on
registry line, budgets Level 1 at 80 tokens, and never loads a Level 3 asset speculatively.
Vendoring either `SKILL.md` as-is would put 12–87 KB into every UI Build session and duplicate
what the `frontend-design` plugin already says; not adopting them loses the parts that are
genuinely better than the estate's defaults (the dials, the critique vocabulary, the detector
rules). The right shape is a distillation with pinned provenance.

## Proposed change

`_system/template/icm-pipeline/skills/design/` (T), in the three tiers:

- **Level 1** — front matter: `name: design`, a one-line description, `triggers` that a Build
  session will actually have in front of it: `DESIGN.md`, `app/`, `components/`, `.tsx`,
  `tailwind`, `globals.css`, `landing`, `hero`, `redesign`, `polish`. Under 80 tokens.
- **Level 2** — the procedure a Build session follows on any ticket that touches UI:
  1. Read the repo's `DESIGN.md`; if a section is `<!-- unset -->`, say so in the run's
     `decisions.md` and pick the conservative default (never invent a brand).
  2. Set the three dials for this ticket from `DESIGN.md`'s agent-prompt section (or the
     ticket), state them once.
  3. Build. The rules of thumb that survive distillation from taste-skill and the
     `frontend-design` plugin live here, short, as imperatives — no essays.
  4. After the preview deploy is green, inspect it with the Level 3 runnable (stub 4) and
     run the critique pass from the impeccable-derived checklist; findings go to
     `tasks.md` as DoD items, not as silent fixes.
  5. Polish pass against the checklist; stop when the checklist is clean or every remaining
     item is a named decision.
- **Level 3** — `references/taste.md` (the distilled dials + rules, with an `UPSTREAM:` line
  naming the taste-skill commit and file), `references/critique.md` (the impeccable-derived
  critique/audit checklist and the subset of its 61 detector rules that apply to Next +
  Tailwind, same provenance line), `references/exemplars.md` (three to five
  awesome-design-md entries by URL, chosen for the estate's typical client — restaurant, retreat,
  consultancy, SaaS — never the whole corpus), and `scripts/inspect.sh` (stub 4's runnable).

Rules: no repo identity anywhere in the skill (it reads `DESIGN.md` and `project.json` at
runtime); `list-skills.sh --check` passes; the registry line reads well beside the other three.
Where the `frontend-design` plugin already says a thing, the reference cites it rather than
restating it — one home per rule. Say in `skills/README.md` that `design` is the fourth seeded
skill.

## Acceptance

- [ ] `.icm/scripts/list-skills.sh --check` prints `RESULT: OK` with the new skill present and
      its Level 1 within budget; the registry line is quoted in the PR body
- [ ] Every `references/*.md` carries an `UPSTREAM:` line with repo, path, commit SHA and
      licence; the PR body states the licence obligations met (MIT and Apache-2.0 notices)
- [ ] The Level 2 body is under 2,500 words, names no repo, and every step either reads a file
      the repo owns or calls a script under the skill
- [ ] A dry read by a fresh session with only the registry line in context, given a UI ticket
      on a fixture repo, loads exactly this skill and reaches step 4 without asking what
      "the brand" is

## Prompt

Read `.icm/intake/design-system-skills/design-capability-skill.md` and
`.icm/intake/design-system-skills/breakdown.md`, then `.icm/docs/design-system-skills-research.md`
(stub 1 — the layer and overlap verdicts are inputs, not open questions) and confirm
`design-md-contract` has landed. Read `_system/template/icm-pipeline/skills/README.md` and the
three seeded skills. Fetch the two upstream `SKILL.md` files at the SHAs the report pinned and
distil them into the three-tier `design` skill described above. Leave `scripts/inspect.sh` as a
documented stub for stub 4 to fill. PR on a `claude/` branch.

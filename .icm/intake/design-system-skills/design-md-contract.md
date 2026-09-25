# Stub: DESIGN.md — one project-owned design system per repo, in the Stitch schema

- feature-slug: design-md-contract
- epic: design-system-skills
- priority: P0
- size: M
- depends-on: research-fit-and-overlap
- sequence: 2 of 7
- sources: `breakdown.md` → What I understood (1) · `VoltAgent/awesome-design-md` README + a
  sample `design-md/<site>/DESIGN.md` (the schema, as extracted) · `pbakaus/impeccable`
  `reference/document.md` (the schema, as written: YAML token front matter + ≤ 8 fixed
  sections, per google-labs-code/design.md) · `projects/jamienisbet/packages/ui/BRAND.md` +
  `tokens/*.css` (the estate's one real design system) · `_system/template/icm-pipeline/MANIFEST`
  (`P` semantics) · `_system/template/claude-pipeline/skills/setup/SKILL.md` (how config gaps
  become questions)

## Problem

Three of the proposed tools read or write a root `DESIGN.md` in one shared schema, and no repo
in the estate has one. jamienisbet has a full design system in a different shape (`BRAND.md`
prose + nine token CSS files); every client repo has a brand in Jamie's head, a designer's PDF,
or a `globals.css`. Without a contract the design skill (stub 3) has nothing to read, and
"customised design systems within each project" stays a wish.

## Proposed change

1. **The schema.** Adopt the Stitch `DESIGN.md` schema as the research report (stub 1) pinned
   it — front matter for tokens, the fixed sections (visual theme, colour roles, typography,
   components, layout, depth, do's and don'ts, responsive, agent prompt guide). Write it down
   once in the template as `_system/template/icm-pipeline/_shared/design-md.md` (T): the
   schema, what each section is for, what a Build session may and may not infer when a section
   is empty. Cite the spec URL and the upstream SHA read.
2. **The stub.** `_system/template/icm-pipeline/DESIGN.md` → seeded to `<repo>/DESIGN.md`,
   `P` in the MANIFEST (seeded once, the repo's forever). The stub is the schema with every
   section present and marked `<!-- unset -->`, so a session can tell "no brand yet" from
   "brand says nothing here". Root placement is deliberate: the upstream tools look for it
   there, and the root is where `AGENTS.md` already lives — say in `AGENTS.md`'s routing table
   that the brand is `DESIGN.md`.
3. **`/setup` asks.** `setup.sh` reports `DESIGN.md unset` as a `[WARN]` (never `[FAIL]` — a
   backend repo has no brand) while any section is `<!-- unset -->`; the `/setup` skill asks the
   brand questions in the intent round, after intent, in the same ≤ 4-per-round rhythm as the
   rest — colours, type, tone, references ("which of stripe / linear / apple / … is closest?",
   pointing at awesome-design-md by URL), and writes the answers into the sections.
4. **The first real one.** Map jamienisbet's `BRAND.md` + `tokens/` into
   `projects/jamienisbet/DESIGN.md` by hand — that is a PR in jamienisbet, not here. Record
   in this stub's handoff what did not map (BRAND.md's desk tier, its voice rules, the
   Tailwind-namespace warning) and where that content now lives, so the schema's limits are
   known before 26 other repos get one. BRAND.md and the tokens stay the source of truth for
   jamienisbet's code; `DESIGN.md` is the agent-facing view of them, and says so in its header.

## Acceptance

- [ ] `_shared/design-md.md` (T) states the schema with the upstream SHA and spec URL, and
      `DESIGN.md` (P) is in the MANIFEST with the seeding proven by `icm-check.sh --fix` on a
      fixture repo
- [ ] `setup.sh --report` on a repo with the untouched stub prints one `[WARN]` line naming
      `DESIGN.md`; on a repo with every section filled it prints nothing about it
- [ ] `projects/jamienisbet/DESIGN.md` exists on a `claude/` PR in that repo, validates against
      the schema (every section present, front matter parses), and the handoff lists what did
      not map
- [ ] No token, colour or type value is duplicated between `DESIGN.md` and `tokens/*.css` in a
      way that can drift silently — either `DESIGN.md` names the token, or the mapping note says
      which file wins

## Prompt

Read `.icm/intake/design-system-skills/design-md-contract.md` and
`.icm/intake/design-system-skills/breakdown.md`, then `.icm/docs/design-system-skills-research.md`
(stub 1's report — confirm it has landed and take the schema and SHA from it). Read
`_system/template/icm-pipeline/MANIFEST`, `_system/template/README.md`, the `/setup` skill and
`setup.sh`, and `projects/jamienisbet/packages/ui/BRAND.md`. Build the four parts above: the
schema note, the seeded stub with its MANIFEST line, the `/setup` warning + questions, and the
jamienisbet mapping as a PR in that repo. icm-board changes go on a `claude/` branch PR here.

# Stub: Research — how the five design tools fit the estate, and what they overlap

- feature-slug: research-fit-and-overlap
- scope: design-system-skills
- priority: P0
- size: M
- complexity: research
- depends-on: none
- sequence: 1 of 7
- sources: Jamie, 2026-09-25 — "allow incredible front end design and customised design
  systems within each of my projects… researches and analyses how to make this work the most
  efficiently and effectively as possible" · `breakdown.md` → What I understood (the local
  evidence gathered when this epic was cut) · the five upstream repos named there

## Problem

Five upstream repos have been proposed for the template, and the estate already carries
overlapping capability at the harness level. Adopting all five verbatim would add always-on
context to every session, a second design vocabulary beside the one jamienisbet already has,
and a tool the estate's own guard blocks by name. Nothing yet says which of the five earn a
place, in which layer, at what token cost — and that is the decision every later stub in this
epic builds on.

## Proposed change

Produce one report, `.icm/docs/design-system-skills-research.md`, that answers each question
below with evidence (file paths, upstream commits, measured token counts — never impressions):

1. **Layer.** For each tool, which home fits the estate's file-ownership model:
   `_system/template/claude/skills/` (canonical `.claude/` asset — seeded, drift-reported,
   never repaired), `_system/template/icm-pipeline/skills/` (three-tier capability skill,
   `T` in the MANIFEST, byte-identical everywhere, Level 1 ≤ 80 tokens), a `P` file the repo
   owns (a root `DESIGN.md`), a harness plugin Jamie enables once on his machine, or nothing.
   Rule to apply: a thing every session must *know* is Level 1 of a capability skill; a thing
   only a Build session on a UI ticket needs is Level 2/3; a thing that is one repo's identity
   is `P`.
2. **Overlap with what is installed.** `frontend-design`, `superdesign`, `playwright` (the
   MCP plugin) and `browser-use` are already enabled plugins in Jamie's Claude Code, and the
   `design:design-system` skill is in the catalogue. State, per upstream repo, what it adds
   that these do not, and what it duplicates. A duplicate is a drop, not a merge.
3. **Token cost.** Measure each candidate's always-loaded footprint (front matter +
   any hook-injected registry line) and its on-trigger footprint (the body + references).
   `list-skills.sh --check` is the ceiling for Level 1; report the numbers.
4. **Dual harness.** Jamie runs Claude Code and OpenCode against the same repos (D44:
   OpenCode only on his machine). Confirm where OpenCode reads skills from and whether a
   `.claude/skills/<name>/SKILL.md` or `.icm/skills/<name>/SKILL.md` is reachable from it
   without a second copy. impeccable's installer already mirrors its skill under `.opencode/`
   and eleven other harness folders — that is the anti-pattern (twelve copies of one file);
   say what the one-home answer is, and whether OpenCode can be pointed at `.icm/skills/`.
5. **The guard.** `~/.claude/hooks/block-local-checks.sh` (and every repo's canonical copy)
   blocks any command whose word is `playwright`, by design (D43: the deploy is the verdict).
   `_system/template/root/opencode.jsonc` denies `* playwright*` for the same reason.
   Note the regex at lines 69–71 requires whitespace or end-of-command after `playwright`,
   so `playwright-cli` may already pass it — yet a `grep` containing the bare word was blocked
   while this epic was cut; find which rule fired and test both harnesses with a fixture.
   `microsoft/playwright-cli` is an inspection tool, not a test runner — propose the
   narrowest carve-out (a distinct binary name, an explicit allow line, an env flag) that keeps
   test runs blocked and only ever points the tool at a Vercel preview or UAT URL, never a
   local dev server.
6. **The design-system format.** `voltagent/awesome-design-md` is a corpus of `DESIGN.md`
   files. Compare its schema with `projects/jamienisbet/packages/ui/BRAND.md` + `tokens/`
   (the one real design system in the estate) and say whether the estate adopts the
   upstream schema, keeps BRAND.md's shape, or maps one to the other. The estate is 27 Next.js
   + Tailwind repos, 9 on shadcn, ~14 on motion/framer-motion; sustentus marketing is the only
   three.js user — weigh `img2threejs` against that.
7. **Licences and pinning.** Each upstream's licence, and how a vendored copy records its
   provenance (commit SHA in a `references/UPSTREAM` line) so a refresh is a diff, not a guess.
8. **Hooks and binaries.** impeccable's installer wires SessionStart, PostToolUse(Edit|Write)
   and Stop hooks that download a Rust engine to `~/.impeccable/bin/` and run on every stop.
   State whether any of that is acceptable under the estate's gentle-hooks rule and the
   security posture, or whether only the hook-free `npx impeccable detect|critique` paths are.

End the report with a **proposed decision D46** in the register's shape (what, rejected
alternatives, source) covering: which tools are adopted, in which layer, the carve-out, the
`DESIGN.md` schema, and what is dropped. Do not write it to `.icm/project.md` — the decision
is Jamie's; the report proposes.

## Acceptance

- [ ] `.icm/docs/design-system-skills-research.md` exists and every one of the eight
      questions above has an evidenced answer — a claim with no path, SHA or number is a gap
- [ ] Every tool has exactly one verdict: adopt into `<layer>`, enable as a plugin, or drop —
      with the overlap that justifies a drop named
- [ ] The playwright-cli carve-out is stated as the exact pattern change to
      `block-local-checks.sh` and the exact `opencode.jsonc` line, and it does not unblock
      `playwright test`, `npx playwright`, or any `e2e` script
- [ ] A proposed D46 closes the report; `.icm/project.md` is untouched
- [ ] Nothing in this stub installs, vendors or syncs anything — research only

## Prompt

Read `.icm/intake/design-system-skills/research-fit-and-overlap.md` and
`.icm/intake/design-system-skills/breakdown.md`, then `_system/template/README.md`,
`_system/template/icm-pipeline/MANIFEST`, `_system/template/icm-pipeline/skills/README.md`
and `~/.claude/hooks/block-local-checks.sh`. Fetch each of the five upstream repos' README and
skill/manifest files at their current HEAD and record the SHA you read. Answer the eight
questions in the stub with evidence and write the report to
`.icm/docs/design-system-skills-research.md`, ending with a proposed D46. Change nothing else.

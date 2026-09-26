# Breakdown: A design layer for the template — DESIGN.md per repo, one design skill, preview-side inspection

- scope-slug: design-system-skills
- sources: Jamie, 2026-09-25 — "introduce these skills/plugins to the icm template in order to
  allow incredible front end design and customised design systems within each of my projects…
  cut an intake batch that not only knows how to configure it to work but also researches and
  analyses how to make this work the most efficiently and effectively as possible" · the five
  upstream repos: `Leonxlnx/taste-skill` (c184364), `pbakaus/impeccable` (9d715cc),
  `microsoft/playwright-cli` (74354ec, v0.1.21), `VoltAgent/awesome-design-md` (f696123),
  `img2threejs/img2threejs` (6e60b5e) — READMEs, SKILL.md and manifests read 2026-09-25 ·
  `_system/template/README.md`, `icm-pipeline/MANIFEST`, `icm-pipeline/skills/README.md` ·
  `_system/scripts/icm-check.sh` CANONICAL list · `~/.claude/hooks/block-local-checks.sh` ·
  `projects/jamienisbet/packages/ui/BRAND.md` + `tokens/` · every estate `package.json`

## What I understood

Jamie wants each client repo to carry its own design system and every Build session to produce
front-end work that reads as designed, not defaulted. Five upstream repos are proposed. Read at
their current HEAD they are not five of the same thing:

| Upstream | What it is | Mechanism | Footprint | Licence |
|---|---|---|---|---|
| taste-skill | 13 prompt-only skills (design taste, brandkit, redesign, minimalist, brutalist, stitch…) | `npx skills add`, Claude plugin, or copy a `SKILL.md` | main `SKILL.md` is **87 KB**; dials (`DESIGN_VARIANCE`, `MOTION_INTENSITY`, `VISUAL_DENSITY`) are body text; scope says "not dashboards" | MIT |
| impeccable | one skill, 24 sub-commands (`init`, `document`, `critique`, `audit`, `polish`, `detect`…), 61 detector rules, `live` mode | `npx impeccable install` → `.claude/skills/impeccable/` **plus mirrors under `.opencode/`, `.cursor/`, …**, four agents, and SessionStart/PostToolUse/Stop hooks that auto-download a Rust engine binary to `~/.impeccable/bin/` | 12 KB `SKILL.md` + `reference/`; `detect <url>` needs a local Chrome/Chromium/Edge; `live` needs a **local dev server with HMR** | Apache-2.0 |
| playwright-cli | `@playwright/cli` — 80+ subcommands exposing Playwright to agents as a CLI + skill instead of MCP | `npm i -g @playwright/cli`, then `playwright-cli install --skills` writes `.claude/skills/playwright-cli/SKILL.md`; node ≥18; `.playwright/cli.config.json` with `allowedOrigins` | 15 KB `SKILL.md` + 10 references; `allowed-tools: Bash(playwright-cli:*)` | Apache-2.0 |
| awesome-design-md | 74 `DESIGN.md` files extracted from real sites (stripe, linear, vercel, apple…) | copy one to the repo root — no install, no code | reference corpus only; format is **Google Stitch's `DESIGN.md`** (YAML token front matter + ≤ 8 fixed sections) | MIT |
| img2threejs | image → procedural Three.js model, staged with Python gate scripts and vision review | `git clone … ~/.claude/skills/img2threejs` (user-global; also `~/.codex/skills/`), optional `img2` plugin harness | 33 KB `SKILL.md`, Python 3.10+, writes `.img2threejs/` into the project | Apache-2.0 |

Three facts shape the whole epic:

1. **Three of the five share one artefact.** impeccable `document` *writes* a Stitch-format
   `DESIGN.md` at the repo root and `context` loads it; awesome-design-md *supplies* ready-made
   ones in the same format; taste-skill's `stitch-skill` *generates* one. So the estate's
   design-system contract is a root **`DESIGN.md`** — one file per repo, owned by the repo
   (`P` in the MANIFEST's terms), in the Stitch schema. The estate already has one real design
   system — jamienisbet's `BRAND.md` + nine token files — and it is not in that schema. That is
   the first thing to map, and the proof that the schema holds.
2. **The estate is homogeneous, so one skill fits.** 27 repos, every one Next.js + Tailwind,
   9 on shadcn, ~14 on motion/framer-motion, exactly one three.js user (sustentus marketing),
   `@playwright/test` in four. What varies is the brand, and the brand lives in `DESIGN.md`.
   The procedure ("read DESIGN.md → build to it → inspect the preview → critique → polish")
   is the same everywhere, which is the definition of a template-owned capability skill
   (`.icm/skills/<name>/`, three tiers, Level 1 ≤ 80 tokens in the always-on registry). Vendoring
   87 KB + 12 KB + 15 KB of upstream `SKILL.md` into every session is not an option the token
   budget allows; distilling them into Level 2 and pinning the upstreams in Level 3
   `references/` (with the commit SHA) is.
3. **Two of the five collide with standing doctrine.** The deploy is the verdict (D43): no
   local dev server, no ad-hoc browser tests — `block-local-checks.sh` blocked a `grep`
   merely containing the word `playwright` while this epic was being cut, and
   `opencode.jsonc` denies `* playwright*`. impeccable's `live` mode (local HMR server) and its
   hooks (run on every Stop, download a binary) are out on those grounds and on the estate's
   "gentle hooks only" rule; its `detect <url>` and `critique` against a **Vercel preview or
   UAT URL** are exactly in. playwright-cli is an inspection tool, not a test runner, and is the
   right way to screenshot and snapshot a preview deploy from a session — but the guard has to
   let it through by name without unblocking `playwright test`.

Already in Jamie's harness and overlapping: the `frontend-design` and `superdesign` plugins,
the `playwright` MCP plugin, `browser-use`, and the `design:design-system` catalogue skill. The
research stub decides what each upstream adds beyond those; a duplicate is a drop.

## Where it sits

- `_system/template/icm-pipeline/` — a new `skills/design/` (T), a `DESIGN.md` stub (P) with
  its MANIFEST lines, and `/setup` learning to ask for the brand.
- `_system/template/claude/hooks/block-local-checks.sh`-equivalent guard copies +
  `_system/template/root/opencode.jsonc` — the carve-out.
- `_system/scripts/icm-check.sh` — presence check for `DESIGN.md`; registry check for the skill.
- `.icm/docs/design-system-skills-research.md` — the research report, ending in a proposed D46
  that Jamie records in `.icm/project.md` (a decision is his act, not a stub's).
- One client repo as the proof; the estate via `icm-sync.sh --apply` afterwards.

## Build order

1. `research-fit-and-overlap` — the evidenced verdict per upstream (layer, overlap, token
   cost, dual-harness reach, the guard carve-out, the `DESIGN.md` schema, licences/pinning),
   closed by a proposed D46.
2. `design-md-contract` — root `DESIGN.md` as a project-owned file in the Stitch schema:
   template stub, MANIFEST `P` line, `/setup` asks for it, jamienisbet's `BRAND.md` + tokens
   mapped into one as the first real instance.
3. `design-capability-skill` — `.icm/skills/design/` in three tiers: the registry line, the
   Build-time procedure, and pinned distillations of taste-skill and impeccable as references.
4. `preview-inspection-tooling` — playwright-cli and `impeccable detect` as the skill's
   Level 3 runnables, pointed only at preview/UAT URLs; the guard and `opencode.jsonc`
   carve-outs; no impeccable hooks, no `live`.
5. `img2threejs-machine-install` — user-global, opt-in, documented in the one repo that can use
   it; nothing in the template.
6. `prove-on-one-repo` — a real UI ticket on one client repo runs the whole loop end to end.
7. `rollout-and-conformance` — MANIFEST, `icm-check.sh`, `list-skills.sh --check`, sync to the
   estate, D46 recorded.

## Parallelizable

2, 4 and 5 depend only on 1 and can run together. 3 needs 2. 6 needs 2, 3 and 4. 7 needs 6.

## Out of scope (whole scope)

- Running any browser or dev server locally — every inspection targets a deployed preview or
  UAT URL (D39/D43). `impeccable live` stays out unless D46 says otherwise.
- Redesigning any client site. The proof stub picks up an existing UI ticket; it does not
  invent one.
- Vendoring awesome-design-md's 74 files. A handful of exemplars in `references/` at most; the
  corpus is cited by URL.
- Changing the three-tier skill contract or the MANIFEST's T/P semantics (D20).

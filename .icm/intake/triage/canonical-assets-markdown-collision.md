# Stub: D17's revisit trigger fired — the formatter surface is five files, not one

- feature-slug: canonical-assets-markdown-collision
- lane: chore
- priority: P3
- sources: courseday CI on k0d0minio/courseday#277, 2026-09-08 — found adopting
  courseday (`triage/courseday-pierpont-unadopted`) · supersedes the survey in
  `triage/canonical-assets-vs-repo-formatters` (D17)

## What this is

D17 settled the canonical-asset/formatter collision as **per-repo, no estate machinery**,
on a survey that found *"the exposed surface is one file, not the whole asset library"* —
`opencode.jsonc`, colliding in two repos. It recorded courseday as **"agrees; carries no
`opencode.jsonc`"** and set an explicit revisit condition:

> **Revisit if** … a formatter-checked repo starts failing on the markdown assets — that
> would mean the surface is two files, not one, and the case for a class-level exclusion
> returns.

**Adopting courseday fired that trigger.** Its CI runs `prettier --check .` over the whole
repo, and seeding the baseline put **five** files in scope, all failing at once:

| File | Canonical? | Drift risk if reformatted |
|---|---|---|
| `.claude/skills/pr-conventions/SKILL.md` | yes — drift-checked | **real** |
| `.icm/CONTEXT.md` | seeded, **not** drift-checked | none |
| `opencode.jsonc` | yes — drift-checked | **real** |
| `.icm/project.md` | no — repo-owned | none |
| `AGENTS.md` | no — repo-owned | none |

One correction to the table above (made on the branch that closed D17): `.icm/CONTEXT.md`
is **not** drift-checked. `icm-check.sh` runs exactly two `cmp -s` comparisons — over
`.claude/`'s `CANONICAL` and over `CANONICAL_ROOT` — so `.icm/CONTEXT.md` and
`.icm/intake/README.md` are seeded-when-missing and never compared, the same standing
`.claude/settings.json` has. That leaves **two** files with real drift risk, not three:
`skills/*/SKILL.md` and `opencode.jsonc`. It does not weaken the case here — the point is
that the markdown collides at all, and `SKILL.md` is drift-checked.

So the survey's two load-bearing facts are both now false: courseday *does* carry the rails
file, and the markdown assets *do* collide. `SKILL.md` "satisfies Prettier's defaults today"
held for `remi-ai`'s narrower glob (`**/*.{ts,tsx,md}`) and for the repos that ran no
formatter over `.claude/` — not for `prettier --check .`.

The count of *colliding* repos did not change (still two: cafe-jardim, dungeons-dragons,
now courseday makes three) — but the **third repo** was D17's other revisit condition, and
it is met too.

## Proposed change

Re-open the question D17 closed, with the corrected surface. The per-repo fix is already
applied in courseday (`.prettierignore`, four entries with stated reasons, mirroring
dungeons-dragons) — **this stub is not blocked**, and the estate is green either way. What
needs deciding is whether a fourth repo should have to rediscover this through a red check.

Options, unranked:

1. **Keep D17.** Three repos, three hand-written ignore blocks, each discovered by its own
   CI. Cheap per repo; the cost is that adoption of any formatter-checked repo now
   predictably ships one red build first.
2. **Seed the ignore block with the assets.** `icm-check --fix` already writes the files
   that cause the collision; it could write the exclusion beside them where the repo has a
   formatter config. This is the ground D16/D17 rejected as "reaching into each repo's lint
   config" — the counter-argument is that it is now reaching into a config to protect
   files the same script just seeded.
3. **Make the assets formatter-clean.** Format the canonical markdown and `opencode.jsonc`
   in `_system/template/` to Prettier defaults once, so the common case stops colliding.
   Does nothing for Biome/tab repos (cafe-jardim), so it shrinks the problem without
   closing it.

## Acceptance criteria (rough)

- [ ] D17 either re-affirmed with the corrected surface recorded, or superseded by a new
      decision ID naming it
- [ ] If the rule stays per-repo, the trigger is written where the next adopter reads it —
      `_system/template/README.md` already carries the rule, not the symptom
- [ ] `triage/canonical-assets-vs-repo-formatters`'s survey table corrected for courseday,
      or explicitly left as a record of what was true on 2026-09-04

## Prompt

Read `.icm/intake/triage/canonical-assets-markdown-collision.md` in the icm-board repo
(`~/Apps`), then the settled stub it supersedes,
`.icm/intake/triage/canonical-assets-vs-repo-formatters.md` (decision D17 in
`.icm/project.md`). Adopting courseday fired D17's own revisit trigger: with the estate
baseline seeded, `prettier --check .` failed on five files — three of them drift-checked
canonical assets (`.claude/skills/pr-conventions/SKILL.md`, `.icm/CONTEXT.md`,
`opencode.jsonc`) and two repo-owned (`.icm/project.md`, `AGENTS.md`). The per-repo fix is
already in courseday's `.prettierignore`, so nothing is broken — settle with Jamie whether
the rule stays per-repo now the surface is five files and three repos, and record the
outcome as a decision either way. Run on Jamie's machine — `projects/*` is local-only.
Ticket-only commits go straight to `main`.

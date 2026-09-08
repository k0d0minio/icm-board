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
| `.icm/CONTEXT.md` | **no** — seeded, never compared | none |
| `opencode.jsonc` | yes — drift-checked | **real** |
| `.icm/project.md` | no — repo-owned | none |
| `AGENTS.md` | no — repo-owned | none |

**Corrected 2026-09-08**, by the canonical-assets-formatter-drift session and verified
against [`icm-check.sh`](../../../_system/scripts/icm-check.sh) — this stub first listed
`.icm/CONTEXT.md` as drift-checked. It is not. The script runs exactly **two** `cmp -s`
comparisons (`:207` over `.claude/`'s `CANONICAL`, `:212` over `CANONICAL_ROOT`);
everything else in the baseline — `.icm/CONTEXT.md`, `.icm/intake/README.md`,
`.claude/settings.json` — is seeded when missing and never compared again. So the
drift-risk count in the five is **two**, not three. The seeded-vs-compared distinction is
the same one that dissolved half of D17's original ticket, which is why it is spelled out
here rather than corrected quietly.

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

## The method finding underneath it

The file count is the symptom; the survey method is the cause. D17's table recorded, per
repo, *what was in scope on the day* — and for an **unadopted** repo that is nothing.
`courseday` read as "agrees; carries no `opencode.jsonc`" because it carried none of the
assets yet. **Adoption is what creates the collision**, so any estate-exposure survey that
enumerates over adopted repos under-counts by construction. A future survey has to ask what
a repo *would* carry once adopted.

`pierpont`, adopted in the same session, is not the next repo to prove it and cannot be: it
carries no formatter config and no CI at all, so it has nothing to collide with. The next
proof would be adopting a repo that runs a formatter over its whole tree.

## Re-checked on the D17 branch, 2026-09-08 — this narrows the options

Four findings from re-running the survey with the method fixed (enumerate over *capacity
to collide*, not over what a repo carries today). All verified, none of them speculative:

**The markdown collision is config-specific and file-specific, not a property of the
asset.** All four copies of `pr-conventions/SKILL.md` — template, courseday, remi-ai,
dungeons-dragons — are byte-identical (`md5 20f6cfaf8031`). That same file **passes**
under Prettier's defaults (`remi-ai`, which checks `**/*.{ts,tsx,md}` over `.claude/`
with no exclusion, green) and **fails** under courseday's config (`printWidth: 100`,
`semi: false`, `singleQuote: true`). And in courseday itself, `ticket-craft/SKILL.md`
passed while `pr-conventions/SKILL.md` failed — same repo, same config, same run.

**That kills option 3.** The canonical markdown is *already* Prettier-default-clean, and
it is dirty under courseday's config at the same time. There is no single formatting of
the template that satisfies Prettier defaults, courseday's config, and cafe-jardim's tabs
at once — the cross product of formatter configs is unbounded and cannot be pre-satisfied.
Option 3 does not shrink the problem; it is not available.

**Biome cannot format markdown at all.** So `cafe-jardim`, `escondidinho` and
`collabimmo` can only ever collide on `opencode.jsonc` — the markdown assets are out of
reach for them. `escondidinho` being green is that, not "its style agrees". Only
Prettier-whole-tree repos see the full surface. (`collabimmo` also runs ESLint, not Biome,
in CI — its tab `biome.json` is editor-only. Latent, still not a hit.)

**Every repo is now adopted, so the adoption trigger is spent.** All 26 carry `.icm/`;
courseday was the last one. And new client repos are *not* born colliding — the dashboard's
`createClientRepo` calls `createRepo` for an empty repo and then `scaffoldIcmBaseline`, with
no formatter shipped. So this can now only fire one way: an already-adopted repo **adds or
changes a formatter config**. Nobody will be watching for it when it does, which is the
honest argument for the exclusion being seeded rather than rediscovered.

Net: the choice is narrower than the three options above suggest — option 3 is out, and
what remains is keep D17 (option 1) or seed the exclusion (option 2).

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
baseline seeded, `prettier --check .` failed on five files — **two** of them drift-checked
canonical assets (`.claude/skills/pr-conventions/SKILL.md`, `opencode.jsonc`); the other
three (`.icm/CONTEXT.md`, `.icm/project.md`, `AGENTS.md`) are seeded-or-repo-owned and
carry no drift risk, only prose-churn. The per-repo fix is
already in courseday's `.prettierignore`, so nothing is broken — settle with Jamie whether
the rule stays per-repo now the surface is five files and three repos, and record the
outcome as a decision either way. Run on Jamie's machine — `projects/*` is local-only.
Ticket-only commits go straight to `main`.

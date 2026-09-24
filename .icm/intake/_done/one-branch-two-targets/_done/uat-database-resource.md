# Stub: The UAT database is a second Marketplace database — the template learns two Neon projects (D41)

- feature-slug: uat-database-resource
- epic: one-branch-two-targets
- priority: P1
- size: M
- depends-on: template-two-targets
- sequence: 5 of 5
- sources: D41 (`.icm/project.md`) · berceo cutover 2026-09-24 (`cutover-agorasim-berceo.md` →
  berceo's section): the named-branch UAT database of D39 (3) sent every UAT build to production;
  the two-database shape proven — UAT build `dpl_Bj7r…` migrated `uat-berceo`
  (`dawn-scene-70949411`), probe k0d0minio/berceo#28 got `preview/claude/preview-db-probe` inside
  it, production (`tiny-cell-08223046`) untouched · `neon-cleanup.yaml` on #28's close looked in
  production's project: "preview/claude/preview-db-probe: not in the project — nothing to
  delete" · Vercel, *Storage on Vercel Marketplace → Use a Marketplace resource in a Custom
  Environment* (updated 2026-09-17): the Preview Deployment Action fallback; "For a Custom
  Environment, Vercel first uses the provider's Preview secret value"

## Problem

D39 (3) declared the UAT database as a named branch of production's Neon project
(`database.neon.uat_branch`), set by hand on the custom environment. On Vercel's native Neon
integration that cannot hold: a production database connected to Preview runs its Preview
Deployment Action on every UAT deployment (a custom environment is preview-type) and overrides
the environment's variables with production's; connected to the custom environment instead, it
hands it its Preview secret — production's string again. D41 replaces it with a second
Marketplace database (a separate Neon project) connected to `uat` + Preview, and production's
database connected to Production only.

The template still speaks the first shape: one `database.neon.project_id` that serves
production, previews and runs alike. So on a D41 repo `neon-cleanup.yaml` looks for
`preview/<branch>` in production's project (the orphan on berceo), `db-branch.sh` would make
`run/<slug>` a child of **production** (production data into a run — the thing D41 keeps out),
`db-env.sh` lists and resets the wrong project, and `setup.sh` requires `uat_branch`.

## Proposed change

- `project.json` → `database.neon`: `project_id` stays **production's**; new
  `nonprod_project_id` (the UAT database's project, where UAT is declared) — previews, runs and
  UAT live there. `uat_branch` retires with the named-branch shape (`setup.sh` fails it on a
  D41 repo, like `uat.branch` under D39); the UAT database is the non-production project's
  default branch. Without UAT nothing changes (one project, as today).
- `lib/project.sh`: `neon_nonprod_project_id` (falls back to `project_id` without UAT);
  `lib/neon.sh`'s write guard: never a write in the production project on a D41 repo.
- `neon-cleanup.yaml` (reference): the non-production project.
- `db-branch.sh`: `run/<slug>` a child of the non-production project's default branch.
- `db-env.sh`: `status` reads both projects (production: the branch, protected or not; non-
  production: UAT, previews, runs); `reset-uat` → re-create the UAT database's schema from the
  repo's migrate + seed on `--apply` (no parent to reset from); `init` lists D41's Storage acts
  (the checklist in `cutover-agorasim-berceo.md` step 3).
- `setup.sh`: a UAT repo must declare `nonprod_project_id`; read through the Vercel API that the
  production database's connection carries no Preview and no custom-environment scope (a
  `[TODO]` line when the API cannot say).
- Words: `_shared/promotion.md` (The UAT database), `_shared/ci.md`, `PIPELINE.md`, the `setup`
  skill (the question and the acts), D32's run-branch sentence where the contracts repeat it.
- MongoDB (`database.mongodb.uat_name`, D35–D37) is out of scope: no Marketplace override path
  there; say so in `promotion.md`.
- Then: berceo and agorasim `project.json` to the new block (a sync PR each), and their
  `project-rules.md`.

## Template shipped (2026-09-24) — what the sync PRs carry

The template half landed on its own `claude/` PR (see `.icm/project.md`'s log row of the same
date). What stays open here is the last bullet of the proposal and criterion 4:

- **Per repo (berceo, then agorasim), one sync PR:** `icm-sync.sh --apply` (T: `lib/project.sh`,
  `lib/neon.sh`, `db-branch.sh`, `db-env.sh`, `setup.sh`, `env-check.sh`, `promote.sh`,
  `_shared/promotion.md`, `_shared/ci.md`, the `database-migration` skill); **by hand**, because
  they are seeded once and never synced: the reference `.github/workflows/neon-cleanup.yaml`, the
  `setup` skill, and `project.json` → `database.neon`: drop `uat_branch`, add
  `nonprod_project_id` (berceo: `dawn-scene-70949411`, `uat-berceo`; agorasim: the id of its
  `uat-agorasim` once its step 3 is done) and `reset_command` (the repo's own, or empty);
  `project-rules.md` → The environments' databases in the D41 shape.
- **Read back on each:** `setup.sh --report` (no `[FAIL]` in project.json; the Vercel line
  "production's `$DATABASE_URL` targets Production only"), `db-env.sh status` (both projects —
  production's should list no `preview/*`/`run/*`), `lib/neon.sh --check`.
- **Unproven until then:** the Vercel env read (`customEnvironmentIds` on the `/v9/projects/<p>/env`
  entries — the field name is from Vercel's API, not yet seen on a live read); that one Neon key
  reaches both projects of a Vercel-managed organisation.

- **agorasim synced 2026-09-24** (k0d0minio/agorasim#129, by the cutover session): `nonprod_project_id`
  `lingering-frog-97017403`, `reset_command` empty, `uat_branch` dropped; `setup.sh --report` OK, 0
  warnings. **Proven live:** `neon-cleanup` read the non-production project and deleted
  `preview/claude/neon-two-projects-d41`, `preview/claude/main-takes-uat` (merged PRs) and
  `preview/claude/preview-db-probe` (#131, closed unmerged) — so the Actions `NEON_API_KEY` reaches
  both projects. Still owed: berceo's sync; `db-env.sh status` on both projects with the key exported.
- **berceo sync opened 2026-09-24** (k0d0minio/berceo#29, CI green, unmerged): synced to `e85de24`
  (also brings #74, #75, #79), `nonprod_project_id` `dawn-scene-70949411`, `reset_command` empty,
  `uat_branch` dropped, `project-rules.md` in the D41 shape; `setup.sh --report` OK, 0 warnings.
  **Unproven:** `neon-cleanup` against `uat-berceo` (#29's own close is the first run), and
  `db-env.sh status` / the Vercel env read on either repo (no key in the session's shell).
- **Read back on both, 2026-09-24** (two cloud sessions with the keys, read-only). berceo at
  `7e74115` (#29 merged): `setup.sh --report` OK (2 warnings), `lib/neon.sh --check` OK,
  `db-env.sh status` → `NEON 2 branch(es) · production main · uat present · previews 0 · runs 0`;
  production holds `main` only, uat-berceo its default branch only; Vercel `[OK] … production
  $DATABASE_URL targets Production only (D41)`. agorasim at `2e105da`: OK (3 warnings), OK,
  `NEON 3 branch(es)` — the same shape, plus one orphan in **production's** project,
  `run/quote-page-and-deposit-link` (11:29Z, before D41; its PR #122 ran on the harness branch
  `claude/sleepy-turing-k3vdjt`, so `neon-cleanup` looked for `run/sleepy-turing-k3vdjt` — triage
  `neon-cleanup-harness-branch-run`); Vercel `[OK]` the same. Both productions' `main` **not
  protected** (Jamie's, Neon Console). The "no preview/* yet" and "framework default" build lines
  are false alarms — triage `neon-readback-false-alarms`.

## Acceptance criteria (rough)

- [ ] A fixture D41 repo: `neon-cleanup` deletes `preview/<branch>` from the non-production
      project; `db-branch.sh up` makes `run/<slug>` there; production is never written
- [ ] `setup.sh` fails `uat_branch` on a D41 repo and a UAT repo without `nonprod_project_id`
- [ ] A repo without UAT: every script's output byte-identical to before
- [ ] berceo and agorasim synced; `db-env.sh status` reads both projects on each

## Prompt

In icm-board, carry out stub 5 of the `one-branch-two-targets` epic: read the breakdown, this
stub, the berceo section of `cutover-agorasim-berceo.md`, and decisions D39 and D41 in
`.icm/project.md`. Reshape `database.neon` in the pipeline template
(`_system/template/icm-pipeline/`) so production's Neon project and the non-production project
(UAT, previews, runs) are two declared ids, and bring `neon-cleanup.yaml`, `db-branch.sh`,
`db-env.sh`, `setup.sh`, `lib/project.sh`, `lib/neon.sh` and the words with it. Prove it on
scratch fixtures — no live Neon or Vercel write. Open one PR on a `claude/` branch; berceo and
agorasim follow as sync PRs afterwards.

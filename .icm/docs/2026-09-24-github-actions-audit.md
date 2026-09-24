# GitHub Actions audit — where the minutes went, and the cost floor that replaces them (D43)

- date: 2026-09-24 · window: 2026-08-25 → 2026-09-24 (30 days) · source: every run's jobs via
  `GET /repos/{r}/actions/runs/{id}/jobs`, non-skipped jobs only, each rounded **up** to a whole
  minute — GitHub's own billing rule. (The `/timing` endpoint's `billable` field is zeroed on
  these accounts; the job tally is the honest reconstruction.)
- decision: D43 (`.icm/project.md`) · contract: `_system/template/icm-pipeline/_shared/ci.md` →
  *What CI is for — the cost floor* · rollout: `.icm/intake/ci-cost-floor/`

## The two facts that reframe the problem

1. **Only three repos bill minutes.** GitHub Actions is free on public repositories. Of the 27
   repos under `projects/`, the ones that are private and on a pool Jamie pays for are
   **sustentus** (the `sustentus` org, its own 2,000 free min/month), **agorasim** and
   **jamienisbet** (the personal `k0d0minio` pool, 2,000 free min/month). serviflow is private
   on `kzinvogon`'s account. remi-ai, berceo and every small client site are public: their CI
   costs nothing, whatever it runs.
2. **A job is billed by the minute, rounded up.** A 9-second label job costs the same minute as
   a 50-second lint. Workflows that fire on every PR edit, every `.icm/` push or every commit
   status turn seconds of work into a minute each, many times a day.

## The personal pool — 2,489 billed minutes in 30 days (limit 2,000)

| Repo            | Workflow      | Runs | Jobs  | Billed min | …of which on push to `main` | What it was                                                                                 |
| --------------- | ------------- | ---: | ----: | ---------: | --------------------------: | ------------------------------------------------------------------------------------------- |
| **jamienisbet** | `CI`          |  320 | 1,514 |  **1,791** |                        ~640 | 4–5 jobs a run: `Typecheck + lint` (612), then a `next build` per site — `admin-dashboard` 345, `portfolio` 340, `sellers-site` 339, `payment-gateway` 155 — every one of them a build Vercel had already made. On every draft push, and again on `main`. |
| jamienisbet     | `DB migrations` |   41 |    36 |         41 |                          15 | Path-filtered; the production migrate. Stays.                                               |
| **agorasim**    | `CI`          |  137 |   142 |    **324** |                          62 | Lint · typecheck · test · **`next build`** on every draft push and on `main`.               |
| agorasim        | `Gates`       |  129 |   120 |    **124** |                           0 | Reads two checkboxes in the PR body. Nine seconds of work, a minute each, on every PR edit. |
| agorasim        | `Pipeline`    |  105 |    94 |    **104** |                           0 | Label projection + four advisory validations, on every push touching `.icm/`.              |
| agorasim        | `Neon cleanup` |   19 |    20 |         20 |                           0 | Deletes the PR's Neon branches on close. Stays.                                             |
| agorasim        | `Release` / `DB migrate` | 10 | 14 |        14 |                           5 | The promotion. Stays.                                                                       |

The chore jobs alone (`Gates` + `Pipeline`) were **228 minutes** — more than every real check
on agorasim's PRs combined once the build is taken out. jamienisbet's build matrix was **1,179
minutes** of building what Vercel builds.

## The sustentus org pool — 431 billed minutes in 30 days

| Workflow              | Runs | Jobs | Billed min | …on push to `main` | What it was                                                                                                                                     |
| --------------------- | ---: | ---: | ---------: | -----------------: | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `Quality`             |   37 |   51 |    **143** |                 14 | The tiered turbo pass, on every draft push and on `main`.                                                                                       |
| `Preview smoke`       |  277 |   68 |    **121** |                  0 | Triggered by **every commit status** (~16 a push). 209 runs skipped for free; 35 `Resolve preview` jobs (35 min) and 16 `Check the preview environment` jobs (16 min) ran for seconds each; 16 walks cost 69 min. |
| `Database migrations` |   37 |   54 |         93 |                 21 | Preview DB per PR (drafts included until stub 6) + production on merge. Stays, ready heads only.                                                |
| `Pipeline`            |   29 |   37 |         48 |                  0 | Label projection + validations.                                                                                                                 |
| `Database audit`      |    6 |    5 |         10 |                  0 | Per PR + nightly. Nightly only now.                                                                                                             |
| `MongoDB cleanup`     |    8 |   10 |         10 |                  0 | Stays.                                                                                                                                          |
| `Release`             |    6 |    6 |          6 |                  0 | Stays.                                                                                                                                          |

431 does not empty a 2,000-minute pool on its own; the month the walks fire in earnest (a walk
has a 100-minute timeout) is the month it does. The shape below removes that tail entirely.

## The public repos — free, and mostly the old shape

| Repo                                                     | Runs / month                                              | Shape                                                                                                       |
| -------------------------------------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| remi-ai                                                  | `Quality` 128 · `Gates` 148 · `Pipeline` 112 · `Release` 12 | On the template; the same chores as agorasim. Rolled out below for consistency.                            |
| berceo                                                   | `CI` 58 · `Neon cleanup` 14 · `Release` 5                 | Already Vercel-gated (the ruleset requires `Vercel` only); `CI` still on drafts and `main`. Rolled out below. |
| dungeons-dragons                                         | `CI` 81 · `Preview database` 79 · `Database migrations` 40 | Hand-written; a Neon branch per PR. Free. Untouched.                                                       |
| cafe-jardim · collabimmo · courseday · escondidinho      | `CI` 20 · 23 · 6 · 16                                     | Hand-written `ci.yml`: separate lint / build / test jobs, `push` to `main` (+ `develop`), a `next build`. Free. Take the shape when next touched (`estate-sync-d43`). |
| vinecliff · kau-american-bbq                             | `Database migrations` 20 · 14                             | Migrations only. Nothing to trim.                                                                           |
| serviflow                                                | none                                                      | Railway, no Actions.                                                                                        |
| barzinho, boystomenretreat, casey-hebbel, firedough, garmani, grafitala, le-pavillon-vert, little-grass-shack, lourenco-botelho, messy-play, miriamfridman, pierpont, simnao, the-library | none | No workflows.                                                                                 |

## The cost floor — one shape for every repo (D43)

| Belongs in CI                                                                                                              | Does not                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| **The deploy** — Vercel's status on the PR head. The verdict; costs no minute.                                              | A `build` step. Vercel built it.                                                                          |
| **One advisory quality job** on a **ready** head only — lint · typecheck · unit tests, one job, named `Quality (advisory)`. | The same on a draft, on `main` after a merge, or on a `.icm/**` + markdown diff.                          |
| **What needs a secret, a runner or a clock** — production migration behind its gate, a preview DB per ready PR, a nightly audit, cleanup on PR close, the release workflow. | The pipeline's chores — labels, validations, gate reads. The session runs the scripts at the step that changes the thing. |
| A browser walk **only where a client pays for its minutes.**                                                               | Everywhere else it is the operator's, at Ready-to-merge, from the preview URL `ci-status.sh` printed.     |

`required_checks` is empty by default; a ruleset requires the deploy status or nothing. The
"never run the full sweep locally" doctrine stands: the session's `format.sh` / `lint.sh` /
`security-check.sh` run over the **changed files** and are feedback, not the verdict.

### What each focus repo pays after the rollout (estimate, same activity)

| Repo        | Before (30 d) | After — what still runs                                                                                                                   | After (est.) |
| ----------- | ------------: | ----------------------------------------------------------------------------------------------------------------------------------------- | -----------: |
| jamienisbet |         1,832 | one typecheck+lint job on ready pushes that touch code (no drafts, no `main`, no builds); `DB migrations` as before                        |    ~150–250 |
| agorasim    |           657 | one lint+typecheck+test job on ready code pushes (no build, no drafts, no `main`); cleanup + release as before                              |     ~80–130 |
| sustentus   |           431 | the turbo pass on ready code pushes; the preview DB on ready PRs; nightly audit (~30); cleanup + release; **no smoke, no Pipeline**          |    ~150–200 |

The personal pool drops from ~2,500 to well under 500; the org pool loses its unbounded tail.
These are estimates from the same month's activity — the first month on the new shape is the
measurement (`usage-snapshot.sh` per run; the Actions billing page per pool).

## What changed, where

- **icm-board** (this branch): `_shared/ci.md` cost-floor section; Build/Release contracts and
  `github.md` → Labels (the session projects labels); the project-rules stub; `setup.sh` names a
  retired chore workflow, a `push:` trigger and a build step; `labels.yaml` deleted, the
  reference `quality.yaml` added; the two skills; `PIPELINE.md`; D43; the epic.
- **sustentus/sustentus#1160**, **k0d0minio/remi-ai#129**, **k0d0minio/agorasim#133**,
  **k0d0minio/berceo#31**, **k0d0minio/jamienisbet#163** — each: the T-file sync (stamped
  `--from-branch`), the quality workflow reshaped, the chore workflows removed where present,
  `required_checks: []`, `project-rules.md` → The factory rewritten.

## Operator — before the two merges that rename a required check

1. **sustentus** ruleset on `main`: `Quality Project` → `Vercel – web` (or nothing).
2. **remi-ai** ruleset on `main`: `Format, lint, typecheck` → the deploy statuses (or nothing).

A required check whose job no longer exists never reports, and the merge waits forever — the
rollout PR included.

## Unverified

- No run of the new shape has fired yet: every rollout PR's diff is `.github/**` + `.icm/**` +
  markdown, which the new `paths-ignore` skips by design. The first ready code PR on each repo is
  the first real run; its YAML parsed clean locally (js-yaml) and `setup.sh` on an old-shape
  checkout raised the three D43 warnings it should.
- The "after" column is an estimate, not a measurement.

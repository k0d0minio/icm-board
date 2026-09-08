# Breakdown: Vercel env system — values, notes and cloud hydration, one flow each

- epic-slug: vercel-env-system
- sources: Vercel research session 2026-09-02 (CLI 54.18.6 probed live, REST/SDK docs,
  claude.ai/code cloud-environment docs + anthropics/claude-code#63541) · Jamie's
  rulings same session: `.env.example` is the manifest; notes flow repo → Vercel only;
  values flow Vercel → local only; no shared team variables — project-level management
  is enough; full scope now; one token per team; Sustentus and REMI are separated team
  boundaries; orphan Vercel projects handled as triage, not here

## What I understood

Every project deploys on Vercel across three teams — kodominio (the client estate,
~24 projects), sustentus (8 projects, one monorepo) and remi21 (6 projects, one
monorepo) — and env vars today are ad-hoc: only 4 of 24 local repos are `vercel link`ed,
9 carry a `.env.example`, none carry notes, and Claude cloud sessions start with no env
at all. Vercel supports a note (`comment`, ≤500 chars) on every env var, but **only via
the REST API** — the CLI (54.18.6) cannot set, show or pull comments, and no existing
tool bridges that gap — so the estate grows one bash script in `_system/scripts/`
(house idiom: bash + curl + jq, CLI where it helps, no new dependency) with three
one-way flows and no two-way sync:

- **Notes**: `.env.example` (committed, values never) → Vercel comments, via API.
- **Values**: Vercel (dashboard / `vercel env add`) → generated `.env.local`, via CLI.
- **Docs**: the notes interleaved as `#` lines into the generated `.env.local`.

Claude cloud environments have no management API — the per-repo panel is web-UI only,
and panel env vars are invisible to the panel's *setup script* (#63541) — so the cloud
answer is: one team-scoped token pasted per panel (manual, once), and a committed
SessionStart hook that runs link + pull in-session. Change a var in Vercel and the next
cloud session simply has it; the panels are never touched again.

Team boundaries: one token per team (`VERCEL_TOKEN_KODOMINIO` / `_SUSTENTUS` /
`_REMI21`), env vars only, never committed. Sustentus and REMI are separated: the
script may operate across their teams with their own tokens (cross-repo tooling on
Jamie's machine), but their in-repo assets are governed by their own repos — icm-check
seeds the canonical hook to the kodominio estate only.

Monorepo fan-outs (registry must model path-level links): `jamienisbet` → portfolio,
client-referrals, jamie-nisbet · `sustentus` → 8 projects · `remi-ai` → 6 projects.
Everything estate-wide runs on the local disk — `projects/` is invisible to cloud
sessions.

## Build order

1. registry-and-link — team/repo/project registry + `link` across the estate — depends-on: none
2. example-convention-and-init — the `.env.example` note convention + `init` seeding — depends-on: registry-and-link
3. push-notes — `.env.example` notes upserted into Vercel comments — depends-on: example-convention-and-init
4. pull-documented — `pull` writing note-interleaved `.env.local` — depends-on: example-convention-and-init
5. env-audit — the estate env report, reports and never repairs — depends-on: example-convention-and-init
6. cloud-session-hook — canonical SessionStart hydration + panel tokens — depends-on: pull-documented

## Worth knowing — learned building stub 1 (2026-09-05)

Three things the research session could not have known, all found by running `link` on
the real estate rather than reasoning about it:

- **`vercel link` edits the `.gitignore` of the repo it links, unprompted**, appending
  `.vercel` and `.env*`. The `.env*` is wrong for this estate: it covers the
  `.env.example` that `example-convention-and-init` makes the manifest. Every repo where
  it was kept carries `!.env.example` on top; in the two monorepos the additions were
  redundant with existing root rules and were reverted. Expect stub 2 to meet this again.
- **`vercel link` also writes a `.env.local` holding a short-lived `VERCEL_OIDC_TOKEN`.**
  `pull` will be overwriting that file, not creating it.
- **A `.vercel/repo.json` above a directory puts the CLI in repo-link mode**, where
  `vercel link --project` reports success and writes no project link. Two stale ones —
  `jamienisbet`'s still describing paths from before the 2026-08-26 repo split, and
  `sustentus`'s listing projects that no longer exist — silently cost eight directories
  their link. `link` now names the condition before it tries, and verifies the link file
  landed afterwards either way.

## Worth knowing — learned building stub 2 (2026-09-07)

`init` seeded 40 registry entries in one pass. What running it taught, for the three
flows still to build:

- **347 keys, and most of them are not Jamie's.** The Neon and Supabase Vercel
  integrations inject their own aliases — `PGHOST`, `PGPASSWORD`, `POSTGRES_URL_NO_SSL`,
  `POSTGRES_PRISMA_URL` and a dozen more — into every project they touch, and the
  manifest documents every one. So `push-notes` is writing a few hundred comments, and
  the `# TODO: note` count `audit` reports will start very high and mostly stay there.
  Worth deciding, when audit lands, whether an integration-managed key deserves the same
  editorial pressure as one a human set.
- **17 of the 40 entries have no Vercel variables at all** — the static marketing sites.
  A flow that treats "no variables" as "not configured yet" will cry wolf about half the
  estate; init says the two things differently for that reason.
- **`.env*` in a repo's .gitignore is create-next-app's, not `vercel link`'s.** Stub 1
  read it as damage the CLI did; it is in the stock Next.js template, under the comment
  "env files (can opt-in for committing if needed)". Seven repos still had it bare and
  would have swallowed the manifest they were being given, so they carry `!.env.example`
  now — the same line the linked repos already had. Any repo scaffolded from that
  template will need it again.
- **A key that appears only commented-out (`# SANITY_API_READ_TOKEN=`) does not count as
  documented** and will be seeded again as a real key line if Vercel has it. Nothing in
  the estate hit this yet; `audit` is the natural place to notice a near-duplicate.

## Worth knowing — learned building stub 3 (2026-09-08)

`push-notes` set 42 comments estate-wide on its first run and zero on its second. What
the run taught, for `pull` and `audit`:

- **Only 12 of 40 entries had anything to push, and 347 keys are still `# TODO: note`.**
  Stub 2 predicted the placeholder count would start high; it is 347 out of 389 noted
  keys, so the estate's dashboards are ~11% annotated. The 42 that landed came almost
  entirely from repos that already had hand-written `.env.example` prose before init ran
  — agorasim, courseday, sustentus/apps/web. The editorial pass is the bottleneck now,
  not the plumbing.
- **Five notes are longer than Vercel's 500-character comment cap** — one runs to 1202.
  They are good documentation, not sloppy ones: paragraphs explaining which Stripe
  webhook events a secret signs, why a seed account exists. Failing the run over them
  would push Jamie to shorten prose to satisfy a tool, and truncating would let the
  mirror edit the original — so they are named in a warning section and left alone, and
  the run still exits 0. If the dashboard ever needs them, the answer is a shorter first
  sentence in `.env.example`, not a smarter script.
- **A `# SANITY_API_READ_TOKEN=` line reads as prose to the convention.** Stub 2 flagged
  the commented-out-key case as something audit should notice; it turns out `push-notes`
  meets it first, because the convention hands that line to the key below it as a note
  and publishing `SANITY_API_READ_TOKEN=` into a client dashboard as a sentence would be
  nonsense. The parser now refuses a note that is only an assignment. `audit` still owns
  noticing the near-duplicate key.
- **62 Vercel records already carry an empty-string comment, and two carry a real one.**
  The empty ones are noise — `comment` is absent when never set, so something touched
  these and cleared them. The two real ones are on `sustentus/marketing`
  (`CLERK_SECRET_KEY`, `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`), written in the dashboard,
  and they survived this run only because those keys are still `# TODO: note`. The
  moment someone writes that note, repo-authoritative means the dashboard text is
  replaced. That is the 2026-09-02 ruling working, not a bug — but it is the first real
  instance of it, and worth knowing before it surprises someone.
- **`PATCH .../env/{id}` with a `comment` field and nothing else leaves everything else
  alone.** Verified rather than assumed: a fingerprint of all 422 records in the estate
  — id, key, type, target set and a SHA-256 of the value — is byte-identical before and
  after. `updatedAt` does move, so `vercel env ls` timestamps are *not* a usable
  spot-check for this flow; the value hash is.

## Out of scope (whole epic)

- Shared team variables — Jamie's call 2026-09-02: project-level is enough. Revisit
  only if key duplication starts to hurt rotation.
- Two-way sync of anything — each flow is one-way by design; drift is audit's job.
- Cross-project same-key value-drift detection — noted as a possible audit extension,
  not cut.
- The 8 orphan kodominio Vercel projects — triage stubs
  (`triage/retire-orphan-vercel-projects.md`, `triage/adopt-courseday-pierpont.md`).
- The Managed Agents API — different product; claude.ai/code sessions are the target.
- Seeding the hook into sustentus / remi-ai — their repos, their conventions.

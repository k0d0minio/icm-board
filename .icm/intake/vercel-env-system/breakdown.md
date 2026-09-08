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

## Worth knowing — learned building stub 4 (2026-09-08)

`pull` ran clean across all 40 entries. What it found is mostly about what is *not* in
Vercel, and it changes what stubs 5 and 6 are walking into:

- **The estate has almost no development-scoped variables.** 22 of the 40 entries hold
  Vercel variables and not one of them in the `development` target — `remi-ai/apps/web`
  has 20 each in production and preview and nothing in development, and the same shape
  repeats across the client sites, the three `jamienisbet` apps and most of sustentus.
  Only 120 of the 347 keys `init` documented come down in a development pull at all, and
  those live in six repos. Verified against the API rather than trusted from the CLI's
  silence. So `audit` (stub 5) has a much sharper question than "is this key documented":
  *can this app run locally at all* — and `cloud-session-hook` (stub 6) needs an answer
  before it ships, because a cloud session hydrated by `pull` would today start with an
  empty `.env.local` in most of the estate. Whether the fix is adding development values
  in Vercel or pulling a different target is Jamie's call, not the hook's.
- **`vercel env pull` edits the app's `.gitignore` too**, appending `.env*` exactly as
  `vercel link` does (stub 1) — ten files across seven repos on the first run. `.env*`
  hides the `.env.example` this system runs on, so `pull` now holds the file across the
  CLI call and puts it back, reporting what it reverted. An estate-wide run leaves no
  tracked change in any repo. Expect stubs 3 and 5 to meet the same behaviour in
  whichever CLI commands they reach for.
- **The `[targets]` suffix earns its keep here.** It is what lets `pull` tell "this
  project holds nothing" from "this project holds 24 keys, none of which comes down in a
  development pull" without a single extra API call — the difference the breakdown warned
  about crying wolf over, answered for free by the manifest.
- **`boystomenretreat` still hides its own manifest**: a committed create-next-app
  `.env*` with no `!.env.example` under it, so the notes `pull` interleaves there exist
  only on Jamie's disk. Reported by both `init` and `pull`, repaired by neither — that
  .gitignore belongs to that repo.
- 104 of the 120 keys that do come down still carry `# TODO: note`. The editorial pass
  is where the breakdown said it would be.

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

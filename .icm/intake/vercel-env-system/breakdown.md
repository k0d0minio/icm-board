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

## Worth knowing — learned building stub 5 (2026-09-08)

The first estate-wide `audit` — 40 entries, 464 documented keys — and what it found that
changes the two flows still to build:

- **248 of the 464 keys are `type: sensitive`, and Vercel will not read those back at
  all.** Over half the estate — every Neon-injected `POSTGRES_*`/`PG*` alias, every
  `*_SECRET`, `RESEND_API_KEY`, `AUTH_SECRET` — can never reach a `.env.local`, by
  Vercel's design and not by any gap in this epic. `pull` will produce a file with holes
  in it wherever those keys matter, and a cloud session hydrated from it will be missing
  them. Worth deciding whether `pull` marks them (`# sensitive — set locally`) rather
  than leaving them silently absent. audit lists them per app for exactly this reason.
- **The drift runs the other way from the one we expected.** Zero Vercel variables are
  undocumented (init did its job three days ago), but **50 documented keys are absent
  from Vercel** — cafe-jardim alone documents 23 that no deploy will ever read. Some of
  those are a hand-written `.env.example` from before the manifest convention; some are
  genuinely a build reading nothing. Either way it is Jamie's call per key, which is why
  it is a GAP with a name rather than something a flow fixes.
- **The registry is clean in both directions** — every Vercel project has an entry and
  every entry a project, the 8 kodominio orphans having been retired since — but the disk
  is not: `projects/sustentus/.vercel/project.json` links the monorepo root to the `web`
  project, which no registry entry names. The find-on-disk half of the check earns its
  keep.
- **`# TODO: note` is 398 of 464 keys**, as stub 2 predicted. That is why warnings do not
  colour audit's exit code: a report that is permanently red is one you stop reading.
- **Staleness only means anything with a clock running.** Three `.env.local` files were
  133–273 days old at the first run and were refreshed mid-session by the `pull` branch
  running in parallel — which is the check working, and a reminder that estate-wide runs
  from two sessions at once do land on the same files.


## Worth knowing — learned building stub 6 (2026-09-08)

The hook is written, canonical and seeded by `icm-check`; nothing has run against real
Vercel yet, because a session has no token. What building it settled:

- **`vercel link --yes` creates whatever project name it is handed.** Stub 1 inferred it;
  the CLI's own source says it outright (54.18.6, `inputProject`: with `autoConfirm` it
  returns `detectedProject || detectedProjectName`, and a bare *name* is the create path).
  A cloud session cannot check a name against a registry it does not have, and the estate
  is already retiring eight orphans, so the hook never guesses from the directory name:
  it asks Vercel which projects are connected to this repo's git remote —
  `GET /v9/projects?repoUrl=…`, the same lookup the CLI's own cross-team search uses — and
  a repo with no match hydrates nothing and says so. That query is also what makes the
  hook configuration-free: no registry, no project id, no team slug in any committed file.
- **The registration problem decided the shape.** A second `SessionStart` entry would have
  meant editing 24 hand-owned `settings.json` files, of which **16 of 25 already differ
  from the template**; `session-start.sh`, by contrast, is byte-identical in all 23 repos
  that carry it. So the hook is a sibling file that `session-start.sh` invokes, and the
  fan-out is two canonical files instead of two dozen policy edits.
- **…and then the sting: 13 kodominio repos never register `session-start.sh` either.**
  Their `settings.json` has no `hooks` key at all (`pierpont` has no `settings.json`), so
  both canonical hooks have been inert there all along — `icm-check` has been saying so
  and nobody acted. It matters now because **every kodominio repo with values to hydrate
  today is one of them**: courseday, messy-play, pierpont, collabimmo, cafe-jardim. Parked
  as `triage/settings-json-without-hooks.md`; the panel checklist closes it by hand for
  those five.
- **Stub 4's open question, answered by giving it away.** The hook pulls `development` by
  default — the same environment `pull` writes locally, so the cloud file and the local
  file say the same thing — and takes `VERCEL_ENV_TARGET` from the panel where a repo
  needs otherwise. Which is not the hook's call, and now does not have to be: **5 of the
  26 kodominio entries deliver anything at all** at `development` (24, 17, 14, 13 and 3
  keys); 7 have no Vercel variables at any target, and the remaining 14 have variables
  that a development pull cannot reach. An empty hydrate is reported as the ordinary thing
  it is, with the reason.
- **An empty pull would have written the annotation pass's own summary line into
  `.env.local`.** `body="${body%$'\n'*}"` strips nothing from a string with no newline in
  it, and awk's `\001COUNTS` sentinel is the whole output when the file has no keys. The
  estate-wide `pull` never hit it — the CLI writes a `VERCEL_OIDC_TOKEN` into every file,
  so there is always a second line — and all 40 files on disk are clean; the hook guards
  it explicitly rather than relying on that.
- **Nothing here has touched Vercel.** No token reaches a Claude session, by design, so
  the hook was exercised against a stubbed CLI and a stubbed API: every refusal path, the
  monorepo fan-out, the empty pull, the `.gitignore` revert and the annotation. The
  end-to-end proof is a cloud session on `courseday` after the panel pass.

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

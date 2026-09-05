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

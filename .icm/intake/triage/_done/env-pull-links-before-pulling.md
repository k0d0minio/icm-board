# Stub: env.sh pull never links a project directory, so a cloud session with a deploy block gets no environment

- lane: chore
- found-by: jamienisbet runs `repo-and-estate-views`, `ticket-view`, `epic-view` (Release code
  review) · 2026-09-24 · template-change guard (D33) — full account in
  `projects/jamienisbet/.icm/intake/triage/template-change-cloud-env-hydrate-unlinked.md`
- priority: P2
- size: S

## Problem

`env.sh` (`_system/template/icm-pipeline/scripts/env.sh`, `T`) → `cmd_pull` runs `vercel env pull`
in each `deploy.projects[]` directory without ever linking it. The canonical hook
`_system/template/claude/hooks/vercel-env-hydrate.sh` hands off to `env.sh pull` whenever the repo
declares a deploy block — *before* its own remote-derived `vercel link --project` step and
*before* its `VERCEL_ENV_MAX_AGE` freshness check — and then prints only the last line of the
output. A fresh cloud checkout has no `.vercel/` under any project path, so every pull fails
("is the directory linked?"), the `FAILED` lines but one are hidden, and once a pull does work it
repeats on every resume. The finding also claimed `env.sh` ignores plain `VERCEL_TOKEN` when
`deploy.token_env` names another variable — `lib/vercel.sh` already falls back to it, so that part
is not a fault.

## Proposed change

- `env.sh pull` links each declared directory to the project it **names** (`vercel link --yes
  --project <name> [--scope <team>]`, never the folder name) when `.vercel/project.json` is absent
  or names another project; trust-then-check the link file; a link failure is that project's
  `FAILED <name>: …` line and the rest carry on; the `.gitignore` the CLI appends to is restored
  on every path, the failed ones included.
- The hook keeps its early hand-off, but runs the `VERCEL_ENV_MAX_AGE` check ahead of it over
  every declared project's `.env.local`, and prints `env.sh pull`'s verdict line plus each
  `FAILED`/`REFUSED` line, not the last line alone.

## Prompt

In the icm-board repo (`~/Apps`), read `.icm/intake/triage/env-pull-links-before-pulling.md` and
`projects/jamienisbet/.icm/intake/triage/template-change-cloud-env-hydrate-unlinked.md`, then read
`_system/contracts/PIPELINE.md` → File-level ownership. Change
`_system/template/icm-pipeline/scripts/env.sh` (`cmd_pull`: link before pull, by project name)
and `_system/template/claude/hooks/vercel-env-hydrate.sh` (freshness check ahead of the hand-off;
verdict + every FAILED/REFUSED line), and copy the new hook over icm-board's own
`.claude/hooks/vercel-env-hydrate.sh`. Keep the token off argv and out of temp files. Prove it
with a fixture (a fake `vercel` on PATH that records its argv and writes the link and env files),
ship on a `claude/` PR; after the merge the operator syncs `projects/jamienisbet` and copies the
hook by hand, retiring the jamienisbet stub in that commit and this one in the PR.

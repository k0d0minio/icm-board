# Stub: Smoke test — the rails hold in a real estate repo

> Completed 2026-08-30 in `projects/jamienisbet`, all six checks passing. No triage
> stubs cut — nothing broke.
>
> 1. **Layer 0 loaded** — the agent described the repo from its AGENTS.md unprompted
>    (four Next.js apps, three shared packages, four Vercel projects); verified against
>    the tree rather than taken on trust.
> 2. **`npm test` refused** — blocked by the `* test*` deny; the whole rule chain came
>    back in the error, matching the template.
> 3. **`git push` asks** — `git push --dry-run origin main` produced "permission
>    requested: bash; auto-rejecting". It reaches the final `ask` despite `git *`
>    allowing, confirming last-match-wins ordering works in a live session. Nothing was
>    pushed. `--dry-run` was used deliberately so an unexpected approval would still
>    have been harmless.
> 4. **Formatter quiet** — a real `edit` tool call appended a line to a deliberately
>    ugly file; `const x={a:1,b:2}` and `const   y  =  [1,2,3]` survived byte-for-byte
>    afterwards. A first attempt was discarded because the edit never landed — with no
>    edit there is no formatter hook to test. Artifact deleted; repo left clean.
> 5. **`share` disabled** — resolved config inside the repo reports `share: "disabled"`
>    and `formatter: false`. Both come from the global layer: this repo predates the
>    template change and sets neither key, which is exactly the gap triage stub
>    `opencode-rails-propagation` closes. On Jamie's own machine the rails hold today;
>    on a fresh clone without his global config they would not.
> 6. **`.env` read denied** — "permission requested: read (.env.local); auto-rejecting".
>    No contents were surfaced. `.env.local` is gitignored and untracked.

- feature-slug: rails-smoke-test
- epic: opencode-buildout
- priority: P1
- size: XS
- depends-on: global-core-config, template-opencode-rails
- sequence: 5 of 5
- sources: report artifact §Phase 5 + §What happens next
  https://claude.ai/code/artifact/806e3001-9c27-40a3-be2f-851c050086f8

## Problem

Every rail so far is config on paper. Nothing has proven that an OpenCode session
inside an estate repo actually refuses local checks, prompts on push, loads the
right rules, and stays quiet on formatting.

## Change

In one non-client repo (jamienisbet is the natural pick), run `opencode` and
check, in order:

1. Layer 0 loaded — the agent knows the repo's AGENTS.md identity when asked.
2. `npm test` (or equivalent) → denied by the permission chain.
3. `git push` → prompts (ask), not silent.
4. An edit to any file → no formatter rewrites it.
5. `/share` → disabled.
6. `.env` read → denied (OpenCode default).

Record any failure as a triage stub against whichever layer broke (template →
here; global config → fix in place). Done when all six pass; move this stub to
`_done/` in a ticket-only commit.

## Prompt

Read `.icm/intake/opencode-buildout/rails-smoke-test.md` in this repo and run the
six checks it lists inside an OpenCode session in projects/jamienisbet. Report
pass/fail per check; cut triage stubs for failures rather than fixing inline
unless the fix is a one-line config correction on Jamie's machine.

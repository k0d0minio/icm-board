# Stub: Two Neon read-back lines cry wolf — "no preview/* yet" and "the framework default"

- feature-slug: neon-readback-false-alarms
- lane: bug
- priority: P2
- found-by: the D41 read-backs on berceo and agorasim, 2026-09-24 (stub 5 of
  `one-branch-two-targets`)
- sources: `setup.sh:266` and `db-env.sh:383-387` in `_system/template/icm-pipeline/scripts/` ·
  both read-backs printed both lines · berceo's root `package.json` and agorasim's
  `web/package.json` carry a `vercel-build` script that migrates · berceo UAT build `dpl_Bj7r…`
  migrated `uat-berceo`, and the probes berceo#28 and agorasim#131 got `preview/<branch>` inside
  the non-production project (`cutover-agorasim-berceo.md`)

## What this is

Both lines read as a gap on a repo that has none:

1. **`setup.sh` warns `no preview/* branch yet — is the Vercel integration's Preview branching
   enabled?`** whenever the project holds zero previews. With no open PR, zero is the correct
   count, and both repos' branching was already proven by a probe PR. The warning should only
   fire when an open PR has no `preview/<its branch>`, or it should drop to `[INFO]` when no PR
   is open.
2. **`db-env.sh status` says `build: <project>: the framework default — previews and UAT carry a
   branch's migrations only if this runs the migrate step`** whenever the Vercel project has no
   `buildCommand` override. But Vercel runs a `vercel-build` script from `package.json`
   (in the project's root directory) ahead of `build`, and that is exactly how both repos migrate
   previews and UAT. The line should read the root directory's `package.json` for a `vercel-build`
   script and name it.

## Prompt

In icm-board, fix triage stub `neon-readback-false-alarms` (read
`.icm/intake/triage/neon-readback-false-alarms.md`): in `_system/template/icm-pipeline/scripts/`,
make `setup.sh`'s "no preview/* branch yet" warning depend on an open PR lacking its
`preview/<branch>` (or drop it to INFO when none is open), and make `db-env.sh status`'s build line
recognise a `vercel-build` script in the Vercel project's root-directory `package.json`. Keep a repo
without UAT byte-identical. Prove it on scratch fixtures, with no live Neon or Vercel call. Open one
PR on a `claude/` branch that moves this stub to `triage/_done/`.

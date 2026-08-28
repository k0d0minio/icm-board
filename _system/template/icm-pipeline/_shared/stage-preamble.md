# Stage preamble — resolve the run, or STOP (Layer 3 reference)

The single canonical procedure for **adopting** an existing run into the working tree.
Build and Release (and `status <slug>`, and a lane resumed by slug) run it before
anything else. Define never runs it — Define is what creates runs.

## Procedure

1. **Resolve the run with one blocking call** — don't read `run.md`, search for the PR,
   or check out a branch by hand:

   ```bash
   .icm/scripts/resolve-run.sh <slug>
   ```

   - Exit 0 / `RESULT: READY` → the run's branch is checked out and
     `.icm/runs/<slug>/run.md` is in the working tree. Go to step 2.
   - Non-zero / `RESULT: STOP` → no run resolved: Define has not run for this slug (or
     the slug is wrong). **STOP.** Do **not** create `runs/<slug>/`, a spec, a
     `run.md`, or a branch, and do not fall back to `git checkout -b`. Recreating the
     folder fabricates an unspecced run and orphans the real one. Point the user at
     `/pipeline new` and stop.

2. Load the stage contract (`.icm/stages/NN_*/CONTEXT.md`) and follow it.

The resolver reads `GITHUB_TOKEN`/`GH_TOKEN` from the environment for the PR search
(and honours `GITHUB_REPO`/`GITHUB_API_URL`); its header documents the full signature.

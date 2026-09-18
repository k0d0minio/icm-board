> Done: 2026-09-18 — in the same PR: `deliver/project` § 1c (the mechanical half), § 3 (the
> questions, asked once), § 6 (the writing) and the Audit; `PIPELINE.md` § profiles and the
> conformance gate point at it; the command allows `icm-sync.sh` and `gh api`.

# Stub: `/project` sets a repo up on the pipeline profile — the v5 setup as one ritual

- lane: chore
- found-by: Jamie, in the remi-ai rollout session · 2026-09-18
- priority: P1
- sources: remi-ai k0d0minio/remi-ai#105 (the steps as they were actually run) ·
  `_system/contracts/PIPELINE.md` § ownership · `_system/template/README.md` · the v5
  directive's § 2B and § 3 (project-owned files, the manifest)

## Problem

Onboarding a repo onto the pipeline profile was a guide, not a ritual: declare the profile,
run the fix, run the sync, then write the project-owned files by hand from what the repo and
Jamie know — the operator, the required checks, the deploy projects, how it announces. The
remi-ai rollout did it as a one-off session. `/project` already interrogates Jamie for intent
and reads the repo; the same rounds and the same reading answer everything the project-owned
files need, so the setup belongs inside it.

## Proposed change

Add the setup to `workspaces/deliver/stages/project/CONTEXT.md`: § 1c does the mechanical
half (declare, guard the formatter first, seed and sync, read the repo for the facts), § 3
asks the rest once, § 6 writes the project-owned files and the repo's own surfaces before the
register, and the Audit proves it (`env-check.sh` PASS, second apply `UNCHANGED`,
`icm-check.sh --repo` clean, the validators OK). The template still never upgrades a repo:
declaring the profile stays Jamie's answer.

## Prompt

Read `.icm/intake/triage/_done/project-onboards-pipeline-profile.md`. The change shipped in its
own PR; nothing to do here.

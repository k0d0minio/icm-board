# Stub: the database-migration skill and /setup still say every MongoDB preview reads its own database

- lane: chore
- found-by: template-change (sustentus triage/template-change-preview-db-migration-gate) · 2026-09-26
- priority: P2
- complexity: low
- sources: `_system/template/icm-pipeline/skills/database-migration/SKILL.md:108` · `_system/template/claude-pipeline/skills/setup/SKILL.md` (`previews: branch`) · sustentus chore preview-db-only-for-migration-prs

## Problem

With `database.mongodb.previews: branch` the skill promises a `preview_<branch>` database per
preview. On sustentus that copied the shared preview database once per ready PR and filled the M0
staging cluster (7 `preview_*` databases on 2026-09-25, most for PRs that never touched the
schema). The repo gated it locally — own database only when the PR adds a migration file, the
stale one dropped on the next push — so the template now describes behaviour its first adopter
no longer has, and any other MongoDB repo on `previews: branch` still pays a copy per PR.

## Proposed change

Make the gate the template's behaviour: `previews: branch` means a per-branch database only for a
PR that adds a migration file (`check-migrations.sh --changed` decides), the shared preview
database otherwise, and the per-branch one is dropped when the branch's next push carries no
migration. Rewrite the skill's paragraph and `/setup`'s description to say so; the reference
`mongodb-cleanup.yaml` already drops on close. Sync per repo; the source stub retires with
`- superseded-by:`.

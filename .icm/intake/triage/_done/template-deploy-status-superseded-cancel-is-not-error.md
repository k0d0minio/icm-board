# Stub: deploy-status.sh counts a production deployment superseded by a newer main commit as ERROR

- lane: bug
- found-by: template-change (sustentus triage/template-change-deploy-status-superseded-cancel) · 2026-09-26
- priority: P2
- complexity: low
- sources: `_system/template/icm-pipeline/scripts/deploy-status.sh:23,50,173` · sustentus merges fd9e290 → 5710a2e (PR 1168 / 1175)

## Problem

Vercel cancels a production build when a newer `main` commit supersedes it: `CANCELED`, no
`errorCode`, no `errorMessage`. `deploy-status.sh` keeps CANCELED with ERROR unless the ignore step
caused it, so Release step 9 reports a production ERROR and points at the hotfix lane while
production is healthy and the next commit's build is READY. The operator has to disprove it by hand
every time two merges land close together.

## Proposed change

Treat a CANCELED deployment as SUPERSEDED, not ERROR, when a newer deployment of the same project
exists for a descendant commit of `main` (the API already returns the newer one first): name it on
the line and settle on the newest deployment's state. Keep ERROR for a CANCELED with no successor.
Sync per repo; the source stub retires with `- superseded-by:`.

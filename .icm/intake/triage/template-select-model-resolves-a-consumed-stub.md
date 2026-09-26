# Stub: select-model.sh cannot find the stub of any spine run — new-run.sh already moved it to _done/

- lane: bug
- found-by: template-change (jamienisbet triage/template-change-select-model-run-slug) · 2026-09-26
- priority: P1
- complexity: low
- sources: `_system/template/icm-pipeline/scripts/select-model.sh:104` · jamienisbet run drop-todos-compliance (PR 168)

## Problem

`select-model.sh <slug> --stage 03_build`, as Build step 1 tells the session to call it, dies with
`no stub '<slug>' under .icm/intake/` for every spine run: `new-run.sh --stub` has already moved
the stub into its scope's `_done/`, and the resolver searches live intake only
(`find … -not -path '*/_done/*'`). Sessions work around it by passing the spec path, which the
contract does not say.

## Proposed change

Resolve a bare slug against the run first (`.icm/runs/<slug>/02_define/output/spec.md`, then
`run.md`'s `- stub:` line), then live intake, then `_done/`; keep the "never the archives" rule
only for the archived runs. Fixture the three cases. Sync per repo; the source stub retires with
`- superseded-by:`.

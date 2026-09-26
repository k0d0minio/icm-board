# Stub: env.sh reads a manifest row with a whitespace IFS, so an empty targets field swallows the note

- lane: bug
- found-by: template-change (agorasim triage/template-change-env-audit-empty-targets · sustentus triage/template-change-env-audit-count-unstable, its second fault) · 2026-09-26
- priority: P1
- complexity: low
- sources: `_system/template/icm-pipeline/scripts/env.sh:239,415` at e85a0e0 · agorasim run thankyou-review-email · sustentus PR 1165

## Problem

`env.sh audit` parses `parse_example`'s rows with `while IFS=$'\t' read -r key targets note`.
Tab is IFS whitespace, so `read` collapses the two tabs around an empty `targets` field: `targets`
receives the note and `note` is empty. Every `.env.example` key without a `[targets]` suffix — most
of them — is reported `[WARN] KEY: no note yet`, its note is never pushed to Vercel by the note-sync
loop (line 415), and `has_token "$targets" ci|cloud|optional` is evaluated against the note's
words. `printf 'K\t\tsome note\n' | while IFS=$'\t' read -r key targets note; do echo "[$targets]
[$note]"; done` prints `[some note] []`. (The first fault of the sustentus stub — unpaged Vercel
reads — was fixed by #60; only this one is owed.)

## Proposed change

Read the row with a non-whitespace separator (emit and split on `\x1f`, or `IFS=$'\t'` with
`read -r -d ''` per field), at both sites; extend `env-audit-stability.sh` with a fixture row that
has a note and no targets and assert the note survives. Sync per repo; both source stubs retire
with `- superseded-by:`.

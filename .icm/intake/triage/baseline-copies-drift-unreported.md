# Stub: icm-check never reports a stale .icm/CONTEXT.md or intake/README.md

- lane: bug
- found-by: /project lourenco-botelho · 2026-09-25
- priority: P2

## Problem

The baseline micro-copies `.icm/CONTEXT.md` and `.icm/intake/README.md` are seeded once by
`icm-check.sh --fix` (lines 185, 318–320) and never compared again. They are neither `T` in
the pipeline MANIFEST nor drift-checked like the canonical `.claude/` assets. lourenco-botelho
still described the retired `LOURE-NNN` numbering until 2026-09-25, when it was refreshed by
hand. berceo, vinecliff, jamienisbet and agorasim all differ from
`_system/template/icm/intake/README.md` today, and `setup.sh --report` says nothing.

## Proposed change

Have `icm-check.sh` report a baseline copy that differs from `_system/template/icm/` as drift,
the same way it reports canonical `.claude/` assets. Or make both files `T` in the MANIFEST so
`icm-sync.sh --apply` carries them. Then sync the estate.

## Prompt

In icm-board, make a stale baseline micro-copy visible: _system/scripts/icm-check.sh seeds
.icm/CONTEXT.md and .icm/intake/README.md from _system/template/icm/ once and never compares
them again (see .icm/intake/triage/baseline-copies-drift-unreported.md). Either report them as
drift like the canonical .claude/ assets, or add them as T files to
_system/template/icm-pipeline/MANIFEST so icm-sync.sh --apply carries them. Pick with Jamie,
implement on a claude/ branch with a PR, and list which estate repos differ today.

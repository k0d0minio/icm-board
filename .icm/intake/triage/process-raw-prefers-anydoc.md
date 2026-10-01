# Stub: process-raw.sh prefers anydoc for office and PDF kinds

- lane: chore
- found-by: notes/anydoc.md (tool research, verdict Adopt) · 2026-10-01
- priority: P2
- complexity: medium
- sources: `notes/anydoc.md` (untracked, Jamie's `~/Apps` checkout) · github.com/firecrawl/anydoc
  (MIT, Rust CLI + Node/Python/WASM bindings) · `_system/template/icm-pipeline/scripts/process-raw.sh`
- touches: `_system/template/icm-pipeline/scripts/process-raw.sh` (T) ·
  `_system/template/icm-pipeline/raw/README.md` · `_system/template/icm-pipeline/stages/01_scope/CONTEXT.md`
  (step 2's `processed/<id>.txt`) · `_system/knowledge/stack.md` · every pipeline repo via `icm-sync.sh --apply`

## Problem

`process-raw.sh` turns what a client sent into text Scope can cite, but its document extractors
flatten the structure that matters most in a brief, a spreadsheet or an old proposal:

- `office` (`docx pptx odt odp`) is a stdlib `zipfile` + regex dump: one line per paragraph,
  tables lost cell by cell, list numbering and headings gone.
- `pdf` is `pdftotext -layout`: columns survive as whitespace, tables as ragged text.
- `xlsx ods rtf epub` have no extractor at all — they hit the `unknown` branch and stay in `raw/`.

anydoc converts all of these (plus csv and text-layer PDF) to GitHub-flavoured Markdown locally,
in milliseconds: headings, nested lists with source numbering, tables with merged cells,
footnotes, speaker notes. Format is detected from bytes, and it fails with typed errors
(`Encrypted`, `NeedsOcr`, `Malformed`) instead of garbage. The crate makes no network call; only
the CLI's `--ocr hosted` does (it uploads to Firecrawl Parse).

## Proposed change

In `process-raw.sh`, when an `anydoc` binary is on PATH, prefer it for
`docx pptx xlsx odt ods odp rtf epub pdf`; when it is absent, keep today's extractors exactly
(and `xlsx ods rtf epub` skip with an install hint, as audio does without whisper). House rules
that bind the change:

1. **Nothing leaves the machine.** Never pass `--ocr`; never invoke through `npx` (it downloads on
   first run). `NeedsOcr` is a `SKIP` — a scanned PDF stays in `raw/`, as today. `Encrypted` and
   `Malformed` are `SKIP`s with that reason.
2. **Operators install tools, scripts never do.** Jamie runs `npm i -g @firecrawl/anydoc` (confirm
   the installed bin name); the script only detects it, like `whisper-cli` and `pdftotext`.
3. **Say it is Markdown.** anydoc output lands at `.icm/processed/<id>.md`, not `.txt` — still
   verbatim, never tidied. The manifest's `extractor` is `anydoc` (with its version), and the
   `<id>` collision loop, the parked stub's `source:` line, `raw/README.md` and Scope's step 2
   accept either extension. Existing `.txt` entries are untouched.
4. **Header and `--help` stay true**: the extractor table names anydoc first per kind, and the
   `sed -n '2,49p'` help range follows the header if it grows.

**Prove it before the sync**, in a lab repo (scratchpad, `cd … || exit 1`): one fixture each of a
docx with a table and numbered list, an xlsx, a pptx with notes, a text-layer PDF and a scanned
PDF. Run once with anydoc on PATH and once with it masked from PATH; the first gives `.md` with
the table intact and the scan skipped `NeedsOcr`, the second matches today's output byte for byte.
Then ship it as an icm-board PR (it is a `T` file, D20/D33), add an anydoc line to
`_system/knowledge/stack.md` beside whisper.cpp, and `icm-sync.sh --apply` each pipeline repo.

Out of scope: the free look (`sell/02_look`) and the knowledge lane, which the note also names —
they gain anydoc by using `process-raw.sh` or calling it by hand, and need no change here.

# Stub: Re-track private/ and bring the held client documents into the deal folders once the repo is private

- lane: chore
- found-by: estate audit 2026-09-26 (the repo was public while D24 keeps private reasoning in git) · 2026-09-26
- priority: P1
- complexity: low
- blocked: until Jamie flips k0d0minio/icm-board to private (end of September 2026)

## Problem

D24 puts every deal document, private reasoning included, in this repo — on the premise that the
repo is private. It was public on 2026-09-26 (Actions minutes), so the audit untracked the five
`private/` files (`git rm --cached`, files kept on disk) and ignored `workspaces/deals/**/private/`.
D24 is not superseded; the ignore is a bridge.

## Proposed change

The day the repo is private: delete the ignore block from `.gitignore`, `git add` every
`workspaces/deals/**/private/` file on disk, one `Deal:` commit straight to `main`. Then confirm
`run-economics.sh` (which writes `private/economics.md`) has somewhere tracked to write.

## Also: the client documents held outside git (D47)

On 2026-09-26 the client documents purged from remi-ai, agorasim and berceo were copied to
`~/Archive/deal-documents/<client>/<engagement>/raw/` (108 files, 130 MB; `chmod go-rwx`),
not into this repo, because it was public. The day it is private: `mv` each `raw/` tree into
`workspaces/deals/<client>/<engagement>/raw/` (documents/, transcripts/, originals/, and berceo's
image-bank/), one `Deal:` commit per client. Three berceo originals are 25–57 MB (the brand and
art-direction PDFs): GitHub warns above 50 MB and there is no LFS here — track them if Jamie
wants every clone to carry them, else keep them on disk and say so in the deal's `raw/README.md`.

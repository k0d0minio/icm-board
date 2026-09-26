# Stub: Re-track workspaces/deals/**/private/ once the repo is private again

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

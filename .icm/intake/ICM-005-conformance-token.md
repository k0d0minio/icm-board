# ICM-005 · Give the conformance workflow a token that can see the estate

| | |
|---|---|
| Status | today |
| Type | chore |
| Priority | P0 |
| Size | S |

## Problem

`.github/workflows/estate-conformance.yml` asks the GitHub API which `k0d0minio` repos
carry the `.icm`/`.claude` baseline. Actions' built-in `GITHUB_TOKEN` is scoped to **this
repo only**, so with no secret set the workflow reports every estate repo as unreachable —
a red run that says nothing true.

This is a human step: creating a token and adding a secret cannot be done from a session,
and cannot be verified from the repo.

## Build

A fine-grained personal access token, `ESTATE_TOKEN`, added under Settings → Secrets and
variables → Actions on this repo:

- Resource owner **k0d0minio**, all repositories (it must see repos created later — the
  dashboard's `createClientRepo` adds them without anyone touching this list)
- Repository permissions: **Contents: Read-only**, **Metadata: Read-only**. Nothing else —
  the workflow only reads file paths.
- No expiry longer than a year; note the renewal on the compliance calendar.

## Acceptance

- [ ] `ESTATE_TOKEN` exists as an Actions secret on `k0d0minio/icm-board`
- [ ] A manual `workflow_dispatch` run of `estate-conformance.yml` is green and its summary
      lists real repos with real gaps (not "unreachable")
- [ ] The token is fine-grained and read-only — if it can write, it is the wrong token

## Prompt

Human-only ticket — do not action it in a session. It records the `ESTATE_TOKEN` secret
that `estate-conformance.yml` needs in order to read the `k0d0minio` org over the GitHub
API. Until it is set, that workflow's findings are meaningless and should not be trusted;
`_system/scripts/estate-conformance.sh` run locally is the fallback, since on this machine
the repos are on disk.

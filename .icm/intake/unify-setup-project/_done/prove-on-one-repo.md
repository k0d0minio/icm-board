# Stub: Prove the merged skill end-to-end on one real repo

- feature-slug: prove-on-one-repo
- scope: unify-setup-project
- priority: P0
- size: M
- depends-on: write-unified-setup-skill
- sequence: 4 of 5
- sources: `.icm/project.md` D45 · lourenco-botelho adoption (k0d0minio/lourenco-botelho#7) —
  the repo that surfaced the original bug

## Problem

The merged skill (`write-unified-setup-skill`) is unproven until it runs against a real repo
end-to-end. It needs to be checked from a cold cloud session — no icm-board on disk — to
actually validate D23's standalone requirement, not just read as plausible.

## Proposed change

Run the new skill on lourenco-botelho (small, and the repo that produced the original bug —
its earlier corrections make a natural regression check: did intent-first ordering avoid
re-asking or re-overturning the same two answers). Simulate a cold cloud session (a fresh
clone with no `~/Apps` mounted, or equivalent) to prove the no-icm-board requirement holds.
Fix whatever breaks in the skill text or the newly-synced reference material.

## Acceptance

- [ ] One session run, standalone, produces: `setup.sh` → `RESULT: OK`, a project-owned-files
      PR, an updated `.icm/project.md`, and a ticket cut — in one pass
- [ ] No step reached for `_system/` or icm-board
- [ ] The `editor`/`production_url`-style overturn from the original bug does not recur

## Prompt

Read `.icm/intake/unify-setup-project/prove-on-one-repo.md` and
`.icm/intake/unify-setup-project/breakdown.md`. Confirm `write-unified-setup-skill` has
landed. Run the merged skill against lourenco-botelho from a session with no icm-board
reachable; fix what breaks; report the acceptance checks above.

## Outcome — 2026-09-28

Run on lourenco-botelho (a re-run: register established 2026-09-25) after syncing it to the
merged template straight to `main` (k0d0minio/lourenco-botelho@e9ff070: `icm-sync.sh --apply`,
15 T files; `icm-check.sh --fix --repo` for the two agents; the setup and ticket-craft skills
and `intake/README.md` copied by hand — see Findings).

- **Standalone:** a fresh clone in the session scratchpad; every script, `git push` and `gh`
  call ran under `bwrap --tmpfs ~/Apps` with `ICM_TEMPLATE` unset (`ls ~/Apps` → empty). The
  skill's reads, the ticket-scout and the four lens agents were confined to the clone. A
  static grep of the skill and everything it names finds `icm-board`/`_system` only in prose
  and provenance, never as a path read. Caveat: the orchestrating session was opened in
  icm-board, so the agent *definitions* loaded were icm-board's (byte-identical to the
  template's); a true cloud session is still unrun.
- **One pass:** `setup.sh --report` → `RESULT: OK (3 warnings)`, byte-identical twice; each
  warning a decision already recorded in `project-rules.md`. Ticket cut on `main`
  (b2c9bf8: scope `go-live-www`, 6 stubs; `website-copy-v2/getting-started-label` split out;
  3 triage incl. a health-check template change); register on
  k0d0minio/lourenco-botelho#20 (Posture maintenance, D8–D9). No config value changed, so the
  project-owned-files PR is the register alone.
- **No overturn:** no config question was asked before posture and intent were confirmed;
  step 5 asked nothing — `production_url` (faafo) and `personas` (visitor) were checked
  against D2 and the Intent and written from them, not re-asked.

Findings:
- `icm-sync.sh` never touches `.claude/` (D7), and `icm-check.sh --fix` only creates missing
  files — so the rewritten `setup` skill, and the stale `ticket-craft`, reach an existing repo
  only by a hand copy. Carried into `retire-project-command-and-rollout`.
- A register written by `/project` carries the old header (`> Last \`/project\` run:`); the
  skill's guards still read it as established and step 8b rewrites it. No change needed.

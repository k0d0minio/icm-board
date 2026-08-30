# Stub: Eleven estate repos have no Layer 0 at all

- feature-slug: repos-without-layer0
- lane: chore
- priority: P2
- sources: the AGENTS.md rollout, 2026-08-30 (epic `opencode-sidecar`, stub
  `estate-rollout`) · `_system/scripts/icm-check.sh` identity warn

## What this is

The rollout migrated every repo that *had* a Layer 0. Eleven did not, and still do not:

`berceo` · `cafe-jardim` · `casey-hebbel` · `collabimmo` · `firedough` · `garmani` ·
`kau-american-bbq` · `le-pavillon-vert` · `lourenco-botelho` · `messy-play` · `vinecliff`

Each is a real client Next.js site with a `README.md`, a `.icm/` baseline and a
`.claude/` folder — but no `CLAUDE.md` and no `AGENTS.md`, so a session opening one reads
no repo identity and no routing. `icm-check.sh` has been saying so on every run ("no
Layer-0 identity file"); the warn predates the AGENTS.md move and was not caused by it.

The rollout could not close this. Its whole per-repo change is *move and bridge* —
`git mv CLAUDE.md AGENTS.md`, seed the importer and `opencode.json` — and there is
nothing to move. The `--fix` seeding is deliberately gated on a repo already carrying
`AGENTS.md`, precisely so it never invents an identity; and writing Layer 0 for eleven
client products is authoring, not migration. So each of these repos is untouched and
carries no root rails: no `opencode.json`, no importer.

## What would close it

Not one ticket. Layer 0 is a statement of what a repo *is* and where a task goes, and
that is `/project`'s interrogation, one repo at a time, with Jamie answering. The useful
decision here is which of the eleven are live enough to be worth an interrogation and
which are dormant — a dormant client site with an accurate `README.md` and no agent
sessions running against it loses nothing by having no Layer 0, and gains a file nobody
maintains.

Worth settling alongside it: whether `--fix` should seed `opencode.json` into a repo with
no `AGENTS.md`. The rails are about what a harness may *run*, not about identity, so the
current gate arguably ties them to the wrong fact — but relaxing it means eleven repos
gain a root file without gaining Layer 0, which is its own kind of half-migrated.

## Prompt

Decide which of the eleven estate repos with no Layer 0 (berceo, cafe-jardim,
casey-hebbel, collabimmo, firedough, garmani, kau-american-bbq, le-pavillon-vert,
lourenco-botelho, messy-play, vinecliff) are live enough to warrant one. Read
.icm/intake/triage/repos-without-layer0.md for the full picture. For each live one, run
/project against it so Layer 0 comes out of a real interrogation rather than a template,
then complete the AGENTS.md shape there the way estate-rollout did elsewhere. Record the
dormant ones as a deliberate no.

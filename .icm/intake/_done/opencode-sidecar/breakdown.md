# Breakdown: OpenCode sidecar — the second harness, estate-wide

- epic-slug: opencode-sidecar
- sources: provider-agnostic research session 2026-08-29 (harness pick: OpenCode) ·
  Jamie's words, same day: repo setup only, he installs OpenCode himself — widened
  2026-08-29: the template must be adapted too, all current projects updated, nothing
  breaks presently (especially sustentus), and sustentus must also operate in OpenCode

## What I understood

Jamie wants light stubs runnable on cheaper models through OpenCode across the whole
estate, not just this repo. The shape: icm-board pilots the AGENTS.md move (Layer 0 to
the vendor-neutral filename, CLAUDE.md kept as a one-line `@AGENTS.md` import so Claude
Code behaves identically), then the template and conformance scripts canonize that
shape, then a rollout pass migrates every estate repo through per-repo PRs. Two safety
rails govern everything: the conformance scripts must tolerate both shapes during the
transition (an un-migrated repo is never suddenly red), and sustentus — exempt, its
`.icm/` authoritative — is never migrated: OpenCode reads CLAUDE.md natively as a
fallback, so sustentus operates in OpenCode with only an added `opencode.json`, its
CLAUDE.md untouched. Installing and model-configuring OpenCode stays Jamie's.

## Build order

1. agents-md-layer0 — icm-board pilots: Layer 0 to AGENTS.md, CLAUDE.md imports — depends-on: none
2. opencode-config — repo-side opencode.json with the estate rails, proven here — depends-on: none
3. agent-neutral-prompts — generalize "fresh Claude session" in the contract + copies — depends-on: none
4. template-and-checks — template canonizes the shape; conformance tolerates both — depends-on: agents-md-layer0
5. estate-rollout — migrate every non-sustentus repo, per-repo PRs, CI green each — depends-on: template-and-checks
6. sustentus-opencode — opencode.json only; CLAUDE.md and .icm/ untouched — depends-on: opencode-config

## Out of scope (whole epic)

- Installing, authenticating or model-configuring OpenCode — Jamie's, by his own word.
- Any dispatch/orchestration tooling — D3 stands; dispatch stays "copy the prompt".
- `- tier: light` delegation markers on stubs — recut from evidence if the pilot shows
  the need.
- The dashboard's `createClientRepo` scaffold — verified during estate-rollout; if it
  writes a CLAUDE.md it gets its own stub in jamienisbet (tickets live next to the
  logic they describe), never a widened PR here.
- Migrating sustentus to the AGENTS.md shape — deliberately never; its exemption is the
  point, and the CLAUDE.md fallback makes migration unnecessary for OpenCode.

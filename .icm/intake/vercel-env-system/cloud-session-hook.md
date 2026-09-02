# Stub: Cloud session hook — Claude sessions hydrate env from Vercel

- feature-slug: cloud-session-hook
- epic: vercel-env-system
- priority: P1
- size: M
- depends-on: pull-documented
- sequence: 6 of 6
- sources: breakdown (`.icm/intake/vercel-env-system/breakdown.md`) ·
  anthropics/claude-code#63541 (panel env vars invisible to the panel *setup script*,
  available in-session) · canonical-asset precedent:
  `_system/template/claude/hooks/session-start.sh`

## Problem

Claude cloud sessions start with no env vars, the per-repo cloud environment panel has
no management API, and hand-maintaining ~24 panels of variables would rot immediately.
The design that survives: each panel holds exactly one secret — that repo's team token
— and a committed SessionStart hook pulls everything else from Vercel, so the panels
are configured once and never touched again.

## Proposed change

- A canonical SessionStart hook asset in `_system/template/claude/hooks/` (sibling to
  `session-start.sh`, or folded into it if that reads better): when a
  `VERCEL_TOKEN`-shaped env var is present and the repo carries a linkable Vercel
  project, run `vercel link --yes` + `vercel env pull .env.local --yes` quietly.
  Inert when no token is present (local sessions where Jamie hasn't exported one, and
  every non-Vercel repo); silent, non-fatal degradation on network failure — a session
  must never be blocked by env hydration.
- Hook, not panel setup script — #63541 means the token is only visible in-session.
- Panel convention: the panel sets plain `VERCEL_TOKEN` (the hook needs no team
  lookup — the token itself is team-scoped). Generate a per-repo checklist (repo →
  team → which token to paste) for Jamie; the pasting is his manual pass, ~24 panels,
  once. The token value never appears in any committed file or session transcript.
- Seeding: kodominio-estate repos get the hook via icm-check's canonical-asset flow
  (seed missing, report drift). Sustentus and remi-ai are separated — hand them the
  hook file as a suggestion in their own repos' terms, don't seed.
- Proof: one cloud session on a client repo shows a hydrated, note-annotated
  `.env.local` at session start.

## Acceptance criteria (rough)

- [ ] Hook asset in the template; icm-check seeds and verifies it across the
      kodominio estate
- [ ] Sessions without a token (local or cloud) are completely unaffected
- [ ] Checklist delivered; after Jamie's panel pass, a cloud session on one client
      repo proves hydration end-to-end
- [ ] No token value in git, transcripts or generated files

## Prompt

Build the cloud hydration step of the estate's Vercel env system in the icm-board repo
(`~/Apps`). Read `.icm/intake/vercel-env-system/cloud-session-hook.md` and the epic's
`breakdown.md` first, plus `_system/template/claude/hooks/session-start.sh` for the
canonical hook pattern. Create the SessionStart hook that links and pulls from Vercel
when a `VERCEL_TOKEN` is present and is inert otherwise, wire it into the canonical
asset flow for the kodominio estate, and produce the per-repo panel checklist for
Jamie's one-time token pass — the pasting and the panel work are his, not yours. Ship
as a PR on a `claude/` branch; move this stub to the epic's `_done/` in that PR. The
end-to-end cloud proof happens after Jamie's panel pass — note it in the PR rather
than blocking on it.

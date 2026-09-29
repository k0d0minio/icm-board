# Stub: health-check.sh reads a redirect to another host's 200 page as healthy

- lane: chore
- found-by: template-change (lourenco-botelho triage/template-change-health-check-redirects) · 2026-09-28
- priority: P2
- complexity: low
- sources: `_system/template/icm-pipeline/scripts/health-check.sh` (curl config: `location`, `max-redirs = 5`) · lourenco-botelho `vercel.json:2-35`

## Problem

`health-check.sh` follows redirects and reads only the final status. lourenco-botelho's
`vercel.json` sends every path on www and the apex to a third-party profile page that answers
200, so a www `health_endpoint` reads OK while the site itself is not served — and would again
whenever a cross-host redirect comes back, in any pipeline repo.

## Proposed change

Report a redirect that leaves the endpoint's host as not-OK: either stop following and give a
3xx its own verdict (`WARN redirect <code> → <location>`), or keep following and compare
`%{url_effective}`'s host with the declared endpoint's. Same-host redirects (trailing slash,
http→https) stay OK. Add the fixture: an endpoint that 307s to another host answering 200 must
not print OK. Ship on a `claude/` branch, then `icm-sync.sh --apply` per pipeline repo; the
source stub retires to its `_done/` with `- superseded-by:` in lourenco-botelho's sync commit.

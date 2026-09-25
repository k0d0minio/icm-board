# Breakdown: Terse sessions — the files carry the history, the chat carries what a human must do

- epic-slug: terse-sessions
- sources: Jamie 2026-09-24 — "prompt the agent to be as little verbose as possible while
  maintaining a clear path for what is being done … the files generated at the various stages
  should give enough of a history as well as the PR body itself … operator actions left to do
  can be formatted to always be a checklist within the chat"; two rounds of questions the same
  session, seven answers (below) · read 2026-09-24: no output doctrine anywhere in
  `_system/template/` (no rule on length, shape or content of a session's messages); ten stop
  steps each phrasing their own "tell the user" (`stages/01_scope/CONTEXT.md:162`,
  `02_define:109`, `03_build:191-198`, `04_release:234`, `lanes/{bug:73,chore:69,tweak:70,hotfix:78,handover:51}`,
  knowledge); `_shared/run-pack/handoff.md` already holds Next steps / Blockers / Do not;
  `usage-snapshot.sh` already records `out=` per stage

## What I understood

A session's chat is the one surface only Jamie reads — agents and cloud sessions read the
files (`handoff.md`, `status.md`, `notes.md`, the PR body). Today every contract improvises its
own sign-off and nothing bounds the narration between tool calls, so the few lines worth
reading are buried. The gain is readability and steering speed first; output tokens are a
minority of a session's spend, so the token saving is measured, not promised.

Jamie's answers:

1. **Scope** — the pipeline (stages, lanes, `/pipeline`, `/setup`) *and* the canonical
   `.claude` skills (`pr-conventions`, `ticket-craft`), reaching every estate repo by sync.
   Not icm-board's own commands, not the global `~/.claude/CLAUDE.md`.
2. **Mid-session** — one line per phase change (`CI red on lint — fixing`); no narration of
   tool calls, no restating file contents.
3. **Two lists, split by actor** — `handoff.md` is what the next session or agent needs;
   the chat checklist is the human-only acts that never land in git (tick a gate, merge, a
   Vercel dashboard or env change, rotate a leaked secret, a DNS record). No fact in both —
   except that an operator act which *blocks the run* is also a `handoff.md` → Blockers line
   (`blocked on operator: <act>`), because a chat-only list dies with the session and
   "who unblocks it" is already that section's job.
4. **Audience** — Jamie; other agents and cloud sessions read files, never chat. Anything a
   later session needs is written to a file, never only said.
5. **Enforcement** — one template-owned doctrine file, `_shared/output.md`, cited by every
   stop step. Harness-neutral (Claude Code and OpenCode alike); no Claude Code output style
   (no OpenCode twin), no Stop-hook lint (a mechanical gate on prose is brittle).
6. **Measure** — `usage.md` `out=` per stage, archived runs before vs runs after the sync.
7. **Never trimmed for brevity** — a STOP and its reason, a red check, anything skipped or
   unverified, a plaintext credential found.

**The stop report, one shape everywhere:**

```
<stage/lane> <outcome> · CI <verdict> · <PR link>
Operator:
- [ ] <human-only act>
Unverified: <skipped, unproven, assumed>   ← only when non-empty
```

No recap of what changed — the PR body and `notes.md` carry it.

> Revised 2026-09-24, during stub 2 and before any sync: this shape read as too bare. The
> doctrine now governs the chat only, gate checkboxes stay in the PR body, the stop report adds
> 2–5 bullets of what matters, and `Operator:` is a numbered list — `_shared/output.md`, D40.

## Build order

1. `output-doctrine` — `_shared/output.md` (T), its MANIFEST line, decision D40 in
   `.icm/project.md`.
2. `wire-stop-reports` — the ten stop steps cite it; the four skills carry the rule inline;
   the `handoff.md` template's Blockers names the operator line. Depends on 1.
3. `measure-output` — baseline `out=` from archived runs, then the comparison after the first
   repo syncs. The baseline half can run any time; the comparison needs 2 synced and runs
   landed.

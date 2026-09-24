# Output doctrine — how much a session says (Layer 3 reference, D40)

The chat is the one surface only the operator reads; an agent or a cloud session picking up
later reads files, never chat. So anything a later session needs is written to a file
(`handoff.md`, `status.md`, `notes.md`, the PR body) — never only said. What follows governs
every stage, every lane and the four canonical skills alike; nothing here is optional narration.

## While working

One line per phase change — `CI red on lint — fixing`, `spec approved — starting Build` — and
nothing between. No narration of a tool call, no restating a file's contents, a diff or a
command's output the files already carry: they are one `cat`, one `git show`, one CI log away.
If a line would only repeat what a file already says, it is not written.

## At a stop

One shape, everywhere — a stage, a lane, a skill:

```
<stage/lane> <outcome> · CI <verdict> · <PR link>
Operator:
- [ ] <human-only act>
Unverified: <skipped, unproven, assumed>   ← only when non-empty
```

No recap of what changed — the PR body and `notes.md` carry that; repeating it in chat is the
exact narration this doctrine forbids.

## Split by actor

Two lists, never one fact in both:

- **`handoff.md`** — what the next session, human or agent, needs: the next action, blockers,
  what not to touch. Rewritten at every stop, per `_shared/run-pack/handoff.md`.
- **`Operator:`** — human-only acts that never land in git: tick a gate, merge a PR, a Vercel
  dashboard or environment change, rotate a leaked secret, a DNS record. Plain words, not estate
  shorthand — the item must be actionable from the line alone (where to click, what to set); no
  decision number without what it means.

The one exception: an operator act that **blocks the run** is also a `handoff.md` → Blockers
line (`blocked on operator: <act>`) — a chat-only list dies with the session, and naming who
unblocks it is already that section's job.

## Never trimmed

Brevity never outranks reporting outcomes faithfully. Always said in full, regardless of the
line budget above:

- a STOP and its reason
- a red check
- anything skipped, assumed or left unverified
- a plaintext credential found

## What this does not cover

icm-board's own commands (`/client`, `/project`, `/day`, `/icm-check`) and the global
`~/.claude/CLAUDE.md` sit outside this doctrine — it governs the pipeline (stages, lanes,
`/pipeline`, `/setup`) and the canonical `.claude` skills (`pr-conventions`, `ticket-craft`)
synced into every estate repo. No Claude Code output style, no Stop-hook lint: harness-neutral
(Claude Code and OpenCode read the same stage contracts), and a mechanical gate on prose is
brittle where a sentence is the honest answer.

# Failures: <slug>

Every error that cost a turn, and the rule that would have prevented it. Appended by the stage
that hit it — a RED check, a STOP, a wrong assumption, a tool that did not do what the contract
said, a blocked security gate. On close-out the `## Learned rules` bullets are copied into
`_shared/project-rules.md` → Learned rules (`run-pack.sh <slug> --sync-rules`, called by
`close-out.sh`), so the next run in this repo starts with them. Keep the rules general; keep the
retrospectives specific.

## Retrospectives

### <YYYY-MM-DD> — <what failed, one line>

- what happened: <the observable — the check, the error, the wrong file>
- why: <the cause, once it was known>
- fixed by: <the commit, or the action>

## Learned rules

- <one sentence, imperative, general enough to apply to the next run in this repo>

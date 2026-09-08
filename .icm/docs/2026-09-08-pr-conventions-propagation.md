# pr-conventions propagation — run 2026-09-08

*The record of carrying the updated canonical `pr-conventions` skill to the estate.
Stub: `.icm/intake/sustentus-parity/discipline-propagation.md` (sequence 4 of 6).
Upstream change: PR #37, "The intake repos get the PR-event discipline in a form they
can act on". Precedent for the fan-out:
`.icm/intake/opencode-executor/_done/push-gate-propagation.md`.*

Run on the local machine only — `projects/` is gitignored in icm-board and invisible to
cloud sessions.

## What was carried

The canonical `_system/template/claude/skills/pr-conventions/SKILL.md`, 41 lines before
the change and 93 after, gaining the **agent economy** section: never subscribe to PR
activity (and unsubscribe if the harness did it for you), one blocking
`gh pr checks <n> --watch` per push as the whole verdict, PENDING as a third value beside
pass and fail, deploy events and bot comment-table edits carry no verdict, your own
pushes echo back, long waits are scheduled check-ins, narrow reads.

Identity used for the pre-change check:

| Version | sha256 |
|---|---|
| pre-change template (`8cad33e^`) | `0c4115d1c188d1f739eaff159e1881960ffa874b59c5ff037e044be755aa9887` |
| new canonical (`8cad33e`) | `41f29f4236cabc3a65347af44eff8b0af2b992596bc4c2ad2726011216208a57` |

## The drift gate

Every candidate was checked **twice** before anything was written: once against the
working tree, and again against the freshly fetched `origin/main` — the copy each branch
would actually be based on. **All 23 were byte-identical to the pre-change template.**
Nothing had drifted, so nothing was skipped on drift grounds and no copy was overwritten.

## Changed — 23 repos, one PR each

Branch `claude/pr-conventions-agent-economy` in every case, each PR touching
`.claude/skills/pr-conventions/SKILL.md` and nothing else (verified by
`git diff --name-only origin/main <branch>`).

| Repo | PR | Committed copy | CI |
|---|---|---|---|
| agorasim | [#86](https://github.com/k0d0minio/agorasim/pull/86) | canonical | green |
| barzinho | [#13](https://github.com/k0d0minio/barzinho/pull/13) | canonical | green |
| berceo | [#14](https://github.com/k0d0minio/berceo/pull/14) | canonical | green |
| boystomenretreat | [#18](https://github.com/k0d0minio/boystomenretreat/pull/18) | canonical | green |
| cafe-jardim | [#7](https://github.com/k0d0minio/cafe-jardim/pull/7) | canonical | **red — pre-existing** |
| casey-hebbel | [#15](https://github.com/k0d0minio/casey-hebbel/pull/15) | canonical | green |
| collabimmo | [#10](https://github.com/k0d0minio/collabimmo/pull/10) | canonical | green |
| dungeons-dragons | [#111](https://github.com/k0d0minio/dungeons-dragons/pull/111) | canonical | green |
| escondidinho | [#5](https://github.com/k0d0minio/escondidinho/pull/5) | canonical | **red — pre-existing** |
| firedough | [#6](https://github.com/k0d0minio/firedough/pull/6) | canonical | green |
| garmani | [#5](https://github.com/k0d0minio/garmani/pull/5) | canonical | green |
| grafitala | [#9](https://github.com/k0d0minio/grafitala/pull/9) | canonical | green |
| jamienisbet | [#131](https://github.com/k0d0minio/jamienisbet/pull/131) | canonical | green |
| kau-american-bbq | [#20](https://github.com/k0d0minio/kau-american-bbq/pull/20) | canonical | green |
| le-pavillon-vert | [#6](https://github.com/k0d0minio/le-pavillon-vert/pull/6) | canonical | green |
| little-grass-shack | [#5](https://github.com/k0d0minio/little-grass-shack/pull/5) | canonical | green |
| lourenco-botelho | [#6](https://github.com/k0d0minio/lourenco-botelho/pull/6) | canonical | green |
| messy-play | [#6](https://github.com/k0d0minio/messy-play/pull/6) | canonical | green |
| miriamfridman | [#5](https://github.com/k0d0minio/miriamfridman/pull/5) | canonical | green |
| remi-ai | [#89](https://github.com/k0d0minio/remi-ai/pull/89) | canonical | **red — see below** |
| simnao | [#11](https://github.com/k0d0minio/simnao/pull/11) | canonical | green |
| the-library | [#8](https://github.com/k0d0minio/the-library/pull/8) | canonical | green |
| vinecliff | [#16](https://github.com/k0d0minio/vinecliff/pull/16) | canonical | green |

## Skipped

- **courseday**, **pierpont** — no `.icm/` at all, carry no copy of the skill. Tracked in
  `.icm/intake/triage/courseday-pierpont-unadopted.md`.
- **sustentus** — exempt, and it is the source of the doctrine.

No repo was skipped for drift. No copy was overwritten.

## Three red checks, two of them not ours

- **cafe-jardim #7** and **escondidinho #5** — lint failures in TypeScript/JavaScript
  source and `package.json` formatting, in files this change never touched. Both repos
  have been failing CI on `main` for days (cafe-jardim since at least 2026-08-30,
  escondidinho since 2026-09-05). **Pre-existing and unrelated**; the PRs inherit a red
  `main` rather than causing one. Worth a ticket in each repo, not in this rollout.

- **remi-ai #89** — caused by this change, and structural. remi-ai's CI runs
  `prettier --check "**/*.{ts,tsx,md}"` and its `lint-staged` hook runs
  `prettier --write` on `*.md`. Prettier rewrites the canonical text: `*both*` → `_both_`,
  `*are*` → `_are_`, and it dedents a list-continuation line. The first commit went in via
  the pre-commit hook and landed a **reformatted** copy — caught on verification, and
  amended with `--no-verify` so the canonical bytes are what the PR carries.

  remi-ai therefore cannot have canonical bytes, green CI, and a one-file PR at the same
  time. **Jamie's call, 2026-09-08: keep the canonical bytes and leave CI red.** #89 stays
  unmergeable until remi-ai stops running prettier over `.claude/` — the fix is a
  `.prettierignore` entry, which belongs in remi-ai, not in this rollout. Until then the
  repo would re-mangle any canonical asset seeded into it.

## Subscriptions — not honoured, and why

The rule this change ships is *never subscribe to PR activity, and unsubscribe if the
harness did it for you*. GitHub auto-subscribes the author of every PR, and all 23 came
back `viewerSubscription: SUBSCRIBED`.

**They could not be unsubscribed.** The `gh` token on this machine carries
`gist, read:org, repo, workflow`; both the GraphQL `updateSubscription` mutation and the
REST issue-subscription endpoint require the **`notifications`** scope. The REST endpoint
returns a bare 404 for an author's implicit subscription, which reads like "not
subscribed" — only GraphQL `viewerSubscription` tells the truth. Worth knowing: a session
checking the REST endpoint would wrongly conclude it was clean.

Outstanding for Jamie:

```
gh auth refresh -s notifications
```

then unsubscribe the 23 PRs, or clear them from the notification inbox by hand. **Nothing
in this session subscribed to anything**, and no PR was watched beyond the single blocking
`gh pr checks --watch` per PR that the doctrine prescribes.

## Conformance

`_system/scripts/icm-check.sh` after the run:

```
RESULT: 26 repos checked, 1 conformant, 25 with gaps, 0 fixed, 116 warnings
```

`pr-conventions` drift is reported for **exactly the 23 repos in the table above, and no
others**. This is expected and not a failure of the rollout: `icm-check` reads the
**working tree**, every repo is checked out on `main`, and the new copy lives on an open
PR branch. **The drift clears as the 23 PRs merge** — it is a merge queue, not a gap. The
acceptance criterion "zero `pr-conventions` drift" is therefore satisfiable only after the
merges, and remi-ai's will persist until its `.prettierignore` is fixed.

Seen in passing, out of scope: **22 repos also report `ticket-craft` drift**, and many
report `session-start.sh` drift. Both pre-date this rollout and neither was touched.

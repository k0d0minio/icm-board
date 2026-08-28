# start/06_repo — the delivery repo exists and carries the baseline

One stage, one job: the client's work gets its home, made the house way. Client repos
are **created by the admin dashboard** (`createClientRepo`) — never by hand; that rule
outranks this stage.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`_system/knowledge/stack.md`](../../../../_system/knowledge/stack.md) | What a delivery repo defaults to |
| 3 | [`TICKETS.md`](../../../../_system/contracts/TICKETS.md) | The intake shape the seeded baseline carries |
| 4 | `05-onboarding.md` | Confirms onboarding didn't leave gaps that block setup |

## Process

1. Confirm the repo does not already exist (a returning client may have one — adopt,
   never duplicate).
2. After Jamie creates it from the profile (gate below): clone under `projects/<name>`
   (local sessions), run `_system/scripts/icm-check.sh --fix`, and confirm what it
   seeded.
3. Write `06-repo.md`: repo URL, what was seeded, what the stack will be where it
   deviates from default. (Ticket identity is the `epic/slug` path — there is no prefix
   to choose or register.)

## Gate — Jamie

- Creates the repo via the dashboard profile (**Connect / create repo** — this also sets
  `github_repo`, clearing that conversion gap and putting the repo on the tickets board).

## Outputs

| Artifact | Lands in |
|---|---|
| `06-repo.md` | the deal folder |
| Seeded `.icm/` + `.claude/` baseline | the client repo (via `--fix`, uncommitted for review) |

## Audit

- `github_repo` is set on the profile — a null there means the work is invisible to the
  board, which is the exact failure this stage exists to prevent.
- Nothing was created by hand that the dashboard or the template owns.

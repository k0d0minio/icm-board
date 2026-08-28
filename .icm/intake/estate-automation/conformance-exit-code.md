# Stub: Decide what a red conformance run should mean

- feature-slug: conformance-exit-code
- epic: estate-automation
- priority: P2
- size: S
- depends-on: none
- sequence: 1 of 2
- sources: recut from ICM-015 (intake/_done/ICM-015-conformance-exit-code.md) · first token-backed estate-conformance.yml run, 2026-08-27

## Problem

Both conformance scripts exit non-zero on any gap anywhere (`(( gaps == 0 ))`), so the
07:00 daily run is red every morning until the whole estate is seeded — and the
2026-08-28 pipeline rework widened the baseline (triage/, .icm/CONTEXT.md, new canonical
hooks), so every repo has gaps again until `estate-migration/seed-estate-baseline` runs.
A scheduled report that is always red teaches you to stop reading it. The counter-case:
red is the nag that gets the seeding done. Decide deliberately.

## Proposed change

Put the options to Jamie (the original ticket recommends: gaps exit 0 with the summary
listing them; exit 2 stays for "unreachable" — the case where the report is lying rather
than reporting). Whichever wins: make `estate-conformance.sh` and `icm-check.sh` agree,
comment the exit line in each with the reasoning, record the decision in
`.icm/project.md`.

## Acceptance criteria (rough)

- [ ] The decision is recorded in `.icm/project.md` (a decision row)
- [ ] Both scripts use the same convention; each exit line carries a why-comment
- [ ] A scheduled run in the chosen steady state has been seen and is the colour intended

## Out of scope (this feature)

- A regression baseline file (option 2 in the original) unless Jamie picks it.

## Prompt

Decide what a red estate-conformance run should mean, then make the scripts agree. Read
.icm/intake/estate-automation/conformance-exit-code.md and the archived original
.icm/intake/_done/ICM-015-conformance-exit-code.md for the three options. This is a
judgement call — put the options to Jamie rather than picking for him. Once he picks,
change _system/scripts/estate-conformance.sh and _system/scripts/icm-check.sh, comment
the exit lines, and record the decision in .icm/project.md. Open a PR on a claude/
branch; do not run local checks — CI is the source of truth.

# forms/ — the questionnaires the dashboard sends

The house questionnaires the admin dashboard's Forms card offers on every lead (and the
portfolio's `/start` page renders for `intake-diagnostic`). Moved here from
`jamienisbet`'s `.icm/onboarding/` on 2026-09-22 (D24: one home per fact — the questions
are business knowledge and live with the sell workspace; the answers are Neon's and are
snapshotted, immutable and provenance-stamped, into the deal's `answers/`). A client's own
delivery repo may still carry questionnaires written for that one client under
`.icm/onboarding/`; the picker lists both.

| File | Sent when | Answers land in |
|---|---|---|
| [`intake-diagnostic.md`](intake-diagnostic.md) | before or after the first call — also the portfolio's `/start` form | `answers/intake-diagnostic.md` — the first evidence at `01_intake` |
| [`onboarding.md`](onboarding.md) | after signature, from `06_onboarding` | `answers/onboarding.md` |
| [`content-and-brand.md`](content-and-brand.md) | after signature, for anything with a public face | `answers/content-and-brand.md` |

## The grammar (what the dashboard parses — do not drift from it)

One form per file, `<slug>.md`; the filename is the slug and is never renamed once a link
has been sent. Front matter with `title` and `intro` (a plain scalar, or `>` folded / `|`
literal blocks); nothing else is read. **Each `##` heading is one question**, worded as
the customer sees it; under it one unordered list of `key: value` lines: `type:` (`text`
default · `textarea` · `select` · `boolean`), `options:` (`select` only, ` | `-separated),
`optional: yes`, `hint:`, `key:` (the stable answer key — set it on any question you may
reword). Prose outside the list is ignored. Four types, deliberately; no conditional
logic, no uploads — a link to a recording is a `text` question.

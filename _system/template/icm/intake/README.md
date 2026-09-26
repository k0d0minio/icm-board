# Intake — the work, as scopes and stubs

> This folder follows the estate-wide intake standard (canonical spec:
> `_system/contracts/TICKETS.md` in the icm-board estate; in a pipeline repo the fuller
> `.icm/intake/CONTEXT.md` beside this file). Tickets are **stubs** that never live alone:
> related work is a **scope** — `intake/<scope-slug>/` with a `breakdown.md` (what was
> understood + the build order) and one stub per unit of work, each `- sequence: <n> of <m>`
> with `- depends-on:` naming any in-scope prerequisite — and one-off findings are **triage**
> stubs in `intake/triage/` tagged `- lane: bug | tweak | chore` (at most 60 active).
> Identity is the path (`<scope>/<slug>`, feature-slug matching the filename); there are no
> ticket numbers.
>
> **Status is positional.** Open = the stub is here; done = `git mv` into the scope's
> `_done/`; dropped = deleted (the commit says why) or archived with a `> Dropped:` line —
> never left open. A completed scope moves whole into the archive (`intake_archive` in
> `.icm/project.json`, else `intake/_done/`), and the front run that cut it goes with it.
> Optional lines the tooling reads: `- priority: P0|P1|P2`, `- complexity:`,
> `- blocked: <reason>`. **`## Prompt` is optional** — a stub is its own brief: the admin
> dashboard reads this folder from `main` (a stub exists once its direct commit lands there,
> `pr-conventions`) and its "Copy prompt" sends only the verb and the slug —
> `new <scope>/<slug>` for a scope stub, `<lane> <slug>` for a triage stub.

Any plan, backlog, or task list for this repo becomes stubs here — never a loose
`TODO.md` or `BACKLOG.md` at the root.

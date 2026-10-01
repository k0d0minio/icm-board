# Stub: Branded editorial diagrams in proposals, free looks and docs pages (diagram-design)

- feature-slug: diagram-design-for-documents
- scope: design-system-skills
- priority: P2
- complexity: medium
- depends-on: research-fit-and-overlap
- sequence: 6 of 8
- sources: `notes/diagram-design.md` (untracked, Jamie's `~/Apps` checkout; verdict Adopt for
  documents and docs pages) · `notes/archify.md` (verdict Trial) ·
  github.com/cathrynlavery/diagram-design (MIT) · `_system/scripts/render-deal.sh` ·
  `workspaces/sell/stages/02_look/CONTEXT.md` · `workspaces/sell/stages/04_proposal/CONTEXT.md`
- touches: `_system/scripts/render-deal.sh` · `workspaces/sell/stages/02_look/CONTEXT.md` ·
  `workspaces/sell/stages/04_proposal/CONTEXT.md` · `_system/knowledge/` (Jamie's diagram
  profile) · `_system/knowledge/stack.md`

## Problem

A proposal or a free look often needs one picture: the client's current state, a phased
timeline, a tier pyramid. Today there is no way to make one that looks like Jamie's brand, so
the deliverable is words only. `diagram-design` is already installed on this machine as a Claude
Code plugin (`diagram-design@diagram-design`). It renders forty editorial diagram types as
self-contained HTML + SVG, exports SVG/PNG, and redraws Mermaid, draw.io and Excalidraw. A named
profile carries one brand's tokens and fonts, so each client keeps its own look. Nothing in the
estate uses it yet, and no profile exists (`~/.diagram-design/` is absent).

Three frictions stand between "installed" and "used":

1. **The thin global layer.** A marketplace plugin is global by nature. Whether it stays a
   machine plugin, and whether it or `archify` is the default for which kind of document, is
   `research-fit-and-overlap`'s call (question 9). This stub implements that verdict, not its
   own.
2. **Profiles are machine-local.** `~/.diagram-design/profiles/<slug>.md` is absent from a
   cloud session, which then renders default-skinned diagrams. The tool's first-run gate refuses
   to do that in a branded project, so a cloud session gets no diagram at all.
3. **`render-deal.sh` cannot carry an image yet.** It renders a temp copy of the markdown
   (`mktemp`, line 40) with no `--resource-path`. Any relative image link in a deal artefact
   therefore resolves against the wrong directory, and the image is dropped from the DOCX.

## Proposed change

Apply the D46 verdict for diagram-design. Assuming it says "adopt for documents":

1. **Jamie's own profile.** Onboard diagram-design to jamienisbet.com and check the result
   against `projects/jamienisbet/packages/ui/BRAND.md` and its tokens. Commit the resulting
   style guide to `_system/knowledge/` (one home), so a cloud session in icm-board renders on
   brand. Name how the machine profile is refreshed from that file. Use the editable-install
   path if a package update would otherwise overwrite a customised style guide.
2. **Deal documents.** In `02_look` and `04_proposal`, add an optional step: when a picture
   says it better, render one diagram, track its HTML source beside the markdown under
   `workspaces/deals/<client>/<engagement>/diagrams/`, and export the PNG to the gitignored
   `out/`. The markdown links the PNG. The markdown stays canonical and the image stays a build
   artefact, as the DOCX already is (D9).
3. **`render-deal.sh`.** Pass `--resource-path` covering the artefact's own folder and `out/`, so
   the linked PNG embeds in the DOCX. A link to a missing image is a reported `SKIP`, never a
   silent drop.
4. **Client repos.** A client repo's profile comes from its `DESIGN.md` once `design-md-contract`
   lands. The `.diagram-design` marker is project-owned and written only when that repo first
   needs a diagram. Nothing goes into the template here; if D46 wants a template line, it
   belongs in `rollout-and-conformance`.
5. Add one line to `_system/knowledge/stack.md` saying what diagram-design is for and what
   `archify` is for, per the verdict.

## Acceptance

- [ ] A deal artefact with one diagram renders through `render-deal.sh` to a DOCX with the image
      embedded. Proven on a fixture deal, then on the next real proposal or free look.
- [ ] A cloud-shaped session (no `~/.diagram-design/`) renders that diagram on brand from the
      committed style guide, or the stub records why it cannot.
- [ ] No new global skill, hook or `~/.claude` file beyond what D46 allows
- [ ] `archify` is not wired here. Its trial on a handover is recorded in the research report.

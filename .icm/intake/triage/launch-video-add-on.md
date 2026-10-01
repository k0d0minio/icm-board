# Stub: Decide whether a launch video (HyperFrames) becomes a quoted add-on to a client website

- lane: chore
- found-by: notes/hyperframes.md (tool research, verdict Watch) · 2026-10-01
- priority: P2
- complexity: research
- sources: `notes/hyperframes.md` (untracked, Jamie's `~/Apps` checkout) ·
  github.com/heygen-com/hyperframes (Apache-2.0; Node 22+, FFmpeg) ·
  `_system/knowledge/services.md` → Client website, Non-services · `_system/knowledge/pricing.md`
  (€120/h internal anchor) · D8 (marketing and content stay with `jamienisbet`)
- touches: `_system/knowledge/services.md` · `_system/knowledge/pricing.md` · `_system/knowledge/stack.md`

## Problem

HyperFrames is already installed on this machine as a Claude Code plugin (`hyperframes@hyperframes`).
Its prerequisites are present too: Node v24 and FFmpeg via linuxbrew. It renders HTML/CSS/media
into deterministic MP4. Of its 21 skills, `/product-launch-video` captures a live site,
`/pr-to-video` explains a PR, and `/slideshow` builds a deck. Nothing in sell, start or deliver
produces video, and the tool fits no stage, so it is not a template change.

The tool does open one commercial question that nothing answers yet: is "a launch video with your
site" something Jamie sells? `services.md` has a home for it. A Client website excludes imagery
and content but allows "a separately quoted add-on". A video with no build attached is pure
content work, which Non-services declines on sight. Until Jamie decides, a proposal cannot offer
the add-on, and a client who asks for one gets an improvised quote.

## Proposed change

Gather the evidence Jamie needs for a yes or no. **The catalogue line is his act, not this stub's.**

1. **Prove it on Jamie's own estate first.** Make one site-tour clip of a live jamienisbet site.
   That work belongs to the `jamienisbet` repo (D8), so cut it there as a stub if Jamie wants the
   clip, not here. Record the wall-clock time from prompt to approved MP4, the hand-edits it
   needed, and the render time.
2. **Licences.** Say what the generated or bundled music, voices, images and registry blocks
   are licensed for, and whether a client can use the clip commercially. Anything unclear
   means that asset class is excluded from the add-on.
3. **Where it renders.** Only local CLI renders. Never in CI or a pipeline stage (D43). Never
   HeyGen cloud or AWS Lambda by default, because a client's site and media would leave the
   machine. State whether that limit still leaves a viable service.
4. **Price.** Derive a fixed add-on price from step 1's hours at the €120/h anchor, and check
   it against the €500 floor logic in `pricing.md`.
5. **Recommend** one of these, with the evidence:
   - (a) add it under Client website as a quoted add-on, with a one-line `stack.md` entry
   - (b) keep the tool for Jamie's own content only
   - (c) drop it and uninstall the plugin, because 21 skills is a lot of global surface
     against the thin global layer

## Acceptance

- [ ] The proof clip exists (made in `jamienisbet`), with its hours and render time recorded
- [ ] Every asset class that would ship to a client has a stated licence position
- [ ] One recommendation (a, b or c) is written into this stub. Only on Jamie's word does it
      become a `services.md` or `pricing.md` change, and then the stub moves to `_done/`
- [ ] Nothing in `_system/template/`, CI or any pipeline stage changes

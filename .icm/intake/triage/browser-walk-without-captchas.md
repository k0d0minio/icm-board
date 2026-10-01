# Stub: A ready-made browser tool for testing and interacting with our own apps, captcha-free by design

- lane: chore
- found-by: notes/patchright.md (tool research, verdict Pass) + Jamie, 2026-10-01: "multiple use
  cases when testing an application or requiring interaction on a web page… a ready made tool
  for browser use that avoids captchas"
- priority: P2
- complexity: research
- sources: `notes/patchright.md` (untracked, Jamie's `~/Apps` checkout) ·
  github.com/Kaliiiiiiiiii-Vinyzu/patchright (Apache-2.0) ·
  `.icm/intake/design-system-skills/preview-inspection-tooling.md` (the `inspect.sh` runnable
  and the guard carve-out) · `_system/template/icm-pipeline/_shared/ci.md` ·
  `projects/collabimmo/package.json` (`@marsidev/react-turnstile`, the one captcha in the estate)
- touches: `_system/template/icm-pipeline/skills/` (where `inspect.sh` lands) ·
  `_system/template/icm-pipeline/_shared/ci.md` · `_system/knowledge/stack.md` ·
  `.env.example` guidance for a repo with a captcha

## Problem

Sessions keep needing a real browser: to walk a booking or contact flow on a preview, to check
that a form submits, or to click through a dashboard after a deploy. Each time, the tool is
improvised (the in-app browser, the `playwright` MCP plugin, `browser-use`, Chrome). Each
session also hits the same two walls:

1. Vercel Deployment Protection on previews.
2. Whatever bot challenge the app itself carries. collabimmo uses Cloudflare Turnstile, and
   Vercel's firewall or attack-challenge mode can challenge on any project.

Patchright's answer is to make automation undetectable. It is a patched Playwright Chromium that
hides from Cloudflare, Akamai, Datadome and Kasada. That is the wrong tool for the estate:

- The patch **disables the console API**, and console errors are the thing a smoke walk reads.
- A detection-evasion dependency is a security-posture finding in any client repo.
- On a site the estate does not own, defeating the bot defence breaks that site's terms.
  Agents must never solve or bypass a captcha there; a human does.

On apps the estate *does* own, no evasion is needed. Every captcha and challenge involved has a
sanctioned way through for automation, and the gap is that nobody has packaged it.

## Proposed change

Build one ready-made browser walk that never meets a captcha **because the target lets it in**.
It must not try to hide from the target.

1. **One runnable, shared with design.** Extend `preview-inspection-tooling`'s `inspect.sh`
   instead of building a second tool. Read its Problem first so the design scope and this stub
   do not grow two browser tools. Add a `walk` mode that runs a short scripted flow (goto,
   fill, click, expect text) from a file the repo owns. It keeps the same refusals: only
   `https://` previews, the repo's declared UAT or production URLs, and never `localhost`.
2. **Ways through that the target sanctions**, documented once and applied per repo:
   - **Vercel Deployment Protection:** the protection-bypass-for-automation header, with the
     token `deploy-status.sh` already reads. Never printed or logged.
   - **Vercel firewall or attack-challenge mode:** a firewall bypass rule scoped to the
     automation. Verify in Vercel's docs whether the protection-bypass header already skips the
     challenge.
   - **App captchas (Turnstile, reCAPTCHA, hCaptcha):** each provider publishes test site and
     secret keys that always pass. Preview and UAT environments use the test keys, and
     production keeps the real ones. collabimmo is the first case: a `[preview]` key pair in
     `.env.example` and the Vercel preview and UAT envs.
3. **Out of scope, stated in `stack.md`:** browser automation against third-party sites past
   their bot defences. If a client product needs that, it is that client's decision and legal
   review, in their repo. For agents, a captcha on a site we do not own stops the walk and
   hands it to a human. Patchright is not adopted and not seeded.
4. **Where it runs** follows `ci.md`: in-session against a deployed URL, or in CI only where a
   client pays for the minutes. Nothing runs locally (D43).

## Acceptance

- [ ] One walk against collabimmo's preview submits a Turnstile-protected form with the test
      keys, reads the console, and prints a `RESULT:` line. It uses no stealth, evasion or
      fingerprint patch.
- [ ] The same walk against production stops at the real challenge and reports it. It does
      not attempt to get past it.
- [ ] `stack.md` names the sanctioned ways through and the third-party line
- [ ] No patchright, puppeteer-stealth or similar dependency appears in any repo or template

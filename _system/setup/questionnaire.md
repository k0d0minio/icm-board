# Setup questionnaire — filling the knowledge layer

*One sitting, flat, all questions at once — the ICM setup pattern. Answers configure the
factory ([`../knowledge/`](../knowledge/) and two sell references); they are written into
those files and this questionnaire records only the date it was done. Tracked as ICM-009.*

**The rule: concrete examples, not descriptions.** "Friendly but professional" configures
nothing. A pasted paragraph from a real proposal configures everything. Where a question
asks for an example, paste a real one — lightly redacted if it names a client.

Answer inline under each question; a session then distributes the answers and replaces
each `— not yet established` marker. Skip freely — a skipped question stays an honest gap.

## Services → [`knowledge/services.md`](../knowledge/services.md)

1. List everything you sold in the last two years, one line each — even one-offs.
2. Which of those would you happily sell again? Which never again (→ Non-services)?
3. For each keeper: what does the client *get*, in their words? What is always included,
   always extra? What is the smallest version you'd sell without embarrassment?

## Pricing → [`knowledge/pricing.md`](../knowledge/pricing.md)

4. Paste the numbers from your last three real quotes (shape + amount + what for).
   These calibrate the bands better than any invented figure.
5. What is the floor — the number below which a project isn't worth opening the laptop?
6. Retainers: what do you charge monthly today, for what? What *should* the tiers be?
7. In-kind deals you've done: what was traded, and what would each have invoiced as?

## Voice → [`knowledge/voice.md`](../knowledge/voice.md)

8. Paste one reply to a lead you were happy with, and one proposal paragraph you'd
   reuse. (These become the register examples.)
9. Write one sentence you would *never* send to a client.
10. Words: any you always use? Any that make you wince?

## Terms → [`knowledge/terms.md`](../knowledge/terms.md)

11. Deposit and payment schedule on your last fixed-price deal — what was it, did it work?
12. Revisions: where did a past deal bleed scope? What limit would have stopped it?
13. At handover, who owns the repo, the content, the Vercel/domain accounts? Who pays
    hosting after?
14. Any deal you regret taking — what red line would have caught it?

## Stack → [`knowledge/stack.md`](../knowledge/stack.md)

15. Confirm or correct the observed defaults (Next.js/Vercel, Neon, Clerk, Resend,
    Stripe). What has changed?
16. What ceilings should discovery flag early — work the default stack can't honestly do?

## Target profile → [`../../workspaces/sell/references/target-profile.md`](../../workspaces/sell/references/target-profile.md)

17. Describe your three best clients ever — what made them good (money, ease, referrals)?
18. Describe the worst — what should qualification have caught?
19. Who do you actually want more of, concretely enough to recognise one on sight?

## Outreach → [`../../workspaces/sell/references/outreach.md`](../../workspaces/sell/references/outreach.md)

20. Paste any outreach message you've sent that got a reply.
21. Where do your leads really come from today (referral, portfolio form, in person)?
    Which channel do you want the playbook to grow?

## Positioning → [`knowledge/positioning.md`](../knowledge/positioning.md)

22. **The offer in one sentence, and the three verbs, in your words.** The page carries a
    drafted sentence (a senior engineer who looks at how a business runs, sorts which parts
    belong to software, an assistant, a person or nothing, builds what makes sense at a
    fixed price, hands over a repository that carries its own method) and three verbs —
    *Look, then sort · Build what makes sense · Hand it over, governed*. Rewrite each as
    you would actually say it; strike what you would never say.
23. **Per register — a café owner, an SME founder, an enterprise team:** one real sentence
    you would say to them about what you do, and one word you would never use with them.
    Three pairs; they fill the two empty rows of the registers table.

## Paper → [`knowledge/terms.md`](../knowledge/terms.md) § Paper

24. **The Drive parent folder** for client documents (proposals, agreements, the signed
    copies) — its name or link; each client gets a folder inside it. And **the house DOCX
    look**: a reference `.docx` whose styles the rendered proposals and agreements should
    take (saved as `_system/knowledge/house.docx`), or "plain" for pandoc's default.

---

**Done log** — when answers are distributed, record it here and in ICM-009:

| Date | Sections filled | By |
|---|---|---|
| 2026-08-26 | All seven, conversationally (ICM-009). Still open, deliberately: voice example pastes (Q8) · outreach message examples (Q20) · web-app/AI standing inclusions (Q3, partial) · the AI-SME outbound channel (Q21, partial). Each is marked in its file. | Jamie + Claude session |
| 2026-09-22 | Positioning, pricing (anchor, floor, four shapes, diagnostic, tiers), services (free look, diagnostic, hosting & support), terms (support, paper, partnerships, languages), stack — from the rework brief's decisions, not a questionnaire run. **Open: Q22, Q23, Q24** — asked here, marked `— not yet established` in their files. | Claude session (directive of 2026-09-22) |
| 2026-09-22 | **Q22–Q24 answered** (positioning: sentence and verbs confirmed as drafted, three register sentences and banned words; terms § Paper: Drive parent `Clients`, house look generated from the brand, Google Docs eSignature confirmed). Also decided: support is never a line of its own — landing pages carry nothing, anything larger folds support and maintenance into the retainer (pricing § Support, terms, services). | Jamie + Claude session |

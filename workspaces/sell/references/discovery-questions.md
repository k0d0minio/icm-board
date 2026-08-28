# Discovery questions — the bank

*Layer-3 reference for [`02_discovery`](../stages/02_discovery/CONTEXT.md). Stable IDs,
never reused; answers are recorded against IDs in the discovery notes so re-asking is
visible. `[BLOCKER]` = a responsible quote cannot be written without the answer.
`[LAWYER]` = the answer may need real counsel, flag it, don't play one. Grown from real
deals — a question asked twice ad hoc earns an ID here. The berceo and messy-play
originals were folded in 2026-08-28 (discovery-references epic); berceo's full
client-specific master bank stays in that repo as the worked example of paring this
down for one deal.*

## Business — what is this for

| ID | Question | Tags |
|---|---|---|
| B1 | What does the business actually sell, to whom, in one paragraph? | `[BLOCKER]` |
| B2 | What must this project change — what number or pain moves if it works? | `[BLOCKER]` |
| B3 | What happens today instead — the workaround this replaces, and what's failing about it? | |
| B4 | Who decides yes, who else has a veto — and are there stakeholders behind them (investors, advisors, an agency already involved)? | `[BLOCKER]` |
| B5 | Why now — what makes this month different from last year? | |
| B6 | What does success look like at 3–6 months, as something countable? Push past features to a number. | |
| B7 | Who do they see as competitors — and what's their answer when the obvious incumbent adds this feature? | |
| B8 | What evidence exists that anyone will pay — interviews, pre-orders, a waitlist, a running manual version? | |
| B9 | Is there a written plan or financial model behind this — and can we see it? | |

## Scope — what gets built

| ID | Question | Tags |
|---|---|---|
| S1 | "Done looks like" in their sentence — what would they demo to a friend? | `[BLOCKER]` |
| S2 | What is explicitly *not* wanted, even if it seems obvious to include? Get them to say it, so it's on record. | |
| S3 | Who writes the words and takes the pictures — them, us, nobody yet? (Product copy too: emails, error states, FAQ.) | `[BLOCKER]` |
| S4 | What exists already — domain, brand, old site, accounts, prior code or prototypes — and who controls each? (Accounts belong in the client's name from day one, us as invited admin.) | `[BLOCKER]` |
| S5 | After handover: who updates content, and how comfortable are they doing it? (This decides whether a CMS is in scope — nail it down.) | |
| S6 | For each imagined feature: needed at launch, later, or never? "Later" is a real answer; write it down. | |
| S7 | If only three things could ship, which three? | |
| S8 | Where a written spec exists: which of its internal contradictions have the founders actually resolved? Each unresolved pair changes the architecture, the estimate, or both. | `[BLOCKER]` |

## Constraints — what bounds it

| ID | Question | Tags |
|---|---|---|
| C1 | Deadline, and what actually happens if it slips? What besides the build gates launch (contracts, legal opinions, content)? | `[BLOCKER]` |
| C2 | Budget shape — total for the build, its source, and is it a hard cap or a starting point? What happens if it runs out mid-build? | `[BLOCKER]` |
| C3 | Languages the thing must speak (PT/EN/other) — at launch, and planned? (Planned languages shape the architecture now.) | |
| C4 | Where do their customers show up — phone, walk-in, Instagram, Google? | |
| C5 | Anything the default stack can't do (see [`stack.md`](../../../_system/knowledge/stack.md) § Ceilings)? | `[BLOCKER]` |
| C6 | Which third parties need contracts, approvals or verified accounts before launch — and what are their *real* lead times and prices? (An identity provider can take months; the build isn't the critical path.) | `[BLOCKER]` |
| C7 | The exact prices, tiers and fees for anything the product sells — numbers, not intentions. Billing can be neither built nor quoted from "TBD". | `[BLOCKER]` |
| C8 | Separately from the build: what *monthly run budget* is acceptable (hosting, email, per-check vendor fees, maps, monitoring) — and budget for the non-code essentials (lawyer, insurance, content, photography)? | |
| C9 | What accessibility bar is this built to — and does their sector make WCAG AA a legal question rather than a choice? | |

## Design — how it should feel

| ID | Question | Tags |
|---|---|---|
| D1 | Three words for how it should feel — then three words for how it must *not* feel. | |
| D2 | Two or three sites they like — and for each, *specifically* what they like about it. ("Modern and clean" is a starting point, not an answer.) | |
| D3 | One site they dislike, and why. | |
| D4 | Polished vs playful — where on that line do they lean? How much motion is right, and how much is too much? | |
| D5 | Photography-led or illustration-led — and do the assets exist, are they theirs to use, and is anyone in them a child? | |

## Data & rules — what could bite

| ID | Question | Tags |
|---|---|---|
| L1 | What personal data will this hold or collect, and why? Any of it about children, health, or anything else special-category? | `[LAWYER]` |
| L2 | Sector rules — licensing, health, food, finance, children? Where an activity may need a licence or declaration, a *written opinion from their counsel* is a launch precondition, not our analysis. | `[LAWYER]` |
| L3 | Whose photos, texts, logos, fonts — and is that use actually licensed? | `[LAWYER]` |
| L4 | Existing terms/privacy pages to inherit, or none? Who drafts the legal pages (not us), and by when — they gate launch. | |
| L5 | Is the legal entity incorporated — and who signs our contract in the meantime? (Also gates any provider that requires a verified entity.) | `[BLOCKER]` |
| L6 | Does the product intermediate other people's work or money (a marketplace, bookings, payouts)? If yes: platform-work, platform-regulation and settlement/tax questions exist for *their counsel* before we architect payments. | `[LAWYER]` |
| L7 | Insurance and liability: what do they carry, what must users prove, and what liability do they imagine *us* carrying? (We cap ours in the contract.) | `[LAWYER]` |
| L8 | How long is each kind of data kept, and what does deletion actually mean here? (Retention shapes the storage design.) | `[LAWYER]` |

## Relationship — how we'll work

| ID | Question | Tags |
|---|---|---|
| R1 | How do they want to communicate, how fast do they expect answers — and how fast will *they* answer? Client-side blockers pause the clock, not invoicing of completed work. | |
| R2 | Have they worked with a developer before — and how did it end? | |
| R3 | Ongoing: retainer relationship or hand-off? Who maintains it after launch — them, us, or nobody? | |
| R4 | Engagement shape: fixed price, milestones, or a paid discovery sprint whose output is the resolved scope plus a fixed quote? (For anything spec-shaped and contradictory: never fixed-price the full scope.) | `[BLOCKER]` |
| R5 | Payment terms — deposit, invoicing rhythm, days-to-pay. In whose name is the contract (see L5)? | |
| R6 | What checklist means "done" and triggers final payment — and who signs acceptance, per milestone or at the end? | |
| R7 | What worries them most about this project? (Ask it plainly; the answer reorders the plan.) | |

## Operations — after it ships

| ID | Question | Tags |
|---|---|---|
| O1 | The 3 a.m. question: when something goes wrong live — who is on call, what is *published* as the promise, and is the marketing consistent with it? | |
| O2 | Who staffs support and any manual queues (reviews, verifications, disputes) — hours per week, honestly? | |
| O3 | If we part ways: notice, handover obligations, what documentation they expect. | |

## Internal — we answer these ourselves, never sent

*From the berceo assessment's ethics section — asked before taking the money, recorded
in the deal folder.*

| ID | Question | Tags |
|---|---|---|
| K1 | Would we use this product ourselves, for our own family or money? The gap between the spec and that bar is the real scope. | |
| K2 | Are we comfortable with what the product claims ("verified", "safe", "guaranteed") and how value settles (visibility to tax and labour authorities)? Where is our walk-away line — decided *before* it's tested? | |
| K3 | If the honest analysis says real failure risk, have we told them clearly, in writing, before taking their money? | |

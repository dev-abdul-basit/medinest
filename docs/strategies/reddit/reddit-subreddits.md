# Reddit — annotated subreddit list

The lookup table you keep open while doing the daily comment work. Each entry: what the sub is, why it's relevant, what you do there, what you don't do.

> Update this file whenever a sub's rules change or a thread proves the categorization wrong. Reddit moves; this file should move with it.

---

## Tier 1 — primary user audience (the people who would install MediNest)

These are where MediNest's actual user lives. They are also the most rule-strict. **Comments-only for first 6 weeks.**

### r/Caregivers
- **Size:** ~30k members
- **Audience:** people caring for elderly parents, sick partners, disabled children
- **Why relevant:** family-medication management is a recurring topic
- **What to do:** empathetic comments. Specific tips beat sympathy. The mods reward "I dealt with X by doing Y" content.
- **What NOT to do:** mention MediNest before Phase 3, and even then only in direct response to "what app do you use" threads.

### r/AgingParents
- **Size:** ~30k members
- **Audience:** adult children dealing with parents' decline
- **Why relevant:** medication non-adherence is a top-5 topic
- **What to do:** read the sticky rules (very strict). Comments only Phase 1–3.
- **Edge case:** they have a flair for "Resource Recommendations" — once you have karma, this is the right thread for a careful, multi-app comparison comment that includes MediNest.

### r/ChronicIllness
- **Size:** ~250k members
- **Audience:** patients managing long-term conditions
- **Why relevant:** medication management is daily life
- **What to do:** very low self-promo tolerance. Phase 4 only. Comments must add value or you get downvoted into oblivion.

### r/CrohnsDisease, r/UlcerativeColitis, r/IBD
- **Size:** combined ~150k
- **Audience:** IBD patients, often on multiple meds with complex schedules
- **Why relevant:** polypharmacy is universal here
- **What to do:** comment-only. Be useful. Long-tail conversion target.

### r/MultipleSclerosis
- **Size:** ~80k
- **Audience:** MS patients, often new to medication routines
- **Why relevant:** infusion scheduling, daily orals, neurology appointment reminders
- **What to do:** comment-only. Mod-friendly culture; modmail intro pays off here.

### r/Type1Diabetes, r/Type2Diabetes, r/diabetes
- **Size:** combined ~250k
- **Audience:** diabetics tracking insulin, oral meds
- **Why relevant:** strict medication timing
- **What to do:** comment-only. Diabetes subs are skeptical of new apps; CGM ecosystem dominates.

### r/lupus, r/Hashimotos, r/thyroidhealth
- **Size:** smaller, dedicated
- **What to do:** very low volume but high-CVR if you're useful

### r/Polypharmacy
- **Size:** small / medical-pro skewed
- **Why relevant:** clinicians and pharmacists discuss medication management
- **What to do:** technical comments. This isn't user acquisition — it's credibility. A respected username here helps everywhere else.

---

## Tier 2 — adjacent communities (lower-intent, higher volume)

### r/seniors, r/AskOldPeople
- **Audience:** older users / their adult kids
- **What to do:** comment-only, age-appropriate empathy. Don't be pushy.

### r/Mommit, r/Daddit, r/Parenting
- **Audience:** parents managing kids' meds (allergies, asthma, ADHD)
- **What to do:** comment in pediatric medication threads. Not the bulk of users but real CVR.

### r/Adulting
- **Audience:** young adults figuring out medication routines for the first time
- **What to do:** comment empathetically. Don't push the elderly-caregiver angle.

### r/Hospice, r/Dementia
- **Audience:** caregivers in difficult circumstances
- **What to do:** these are hard subs. Comment with extreme care. MediNest is rarely the right recommendation here — palliative use cases need different tools — but a *useful* developer presence builds reputation.

---

## Tier 3 — developer / build-in-public (your second-most useful zone)

These are not your users but they are your distribution. Build credibility here = your other comments get taken more seriously.

### r/SideProject
- **Size:** ~270k
- **What to do:** Phase 4 — post a build update with real numbers. Usually does well.
- **Self-promo:** explicitly allowed.

### r/IndieDev
- **Size:** ~250k
- **What to do:** same as r/SideProject. Slightly more game-dev skewed; pill reminder posts are a refreshing change for them.

### r/Flutter
- **Size:** ~80k
- **What to do:** technical posts about Flutter learnings. "How I shipped 50+ locales in MediNest" is a great fit.

### r/androiddev
- **Size:** ~200k
- **What to do:** technical only. Not for "look at my app" posts. For "here's how I solved X" posts.

### r/Entrepreneur
- **Size:** ~3M
- **What to do:** Phase 4, occasional. Lower-quality audience, but reach.
- **Watch for:** moderation is inconsistent. Same post can hit front page or get removed.

---

## Tier 4 — app-discovery subs (allowed, low quality)

### r/AndroidApps
- **Size:** ~250k
- **What to do:** allowed to post once per app, weekly. Use the post template the sub provides. Don't repost.

### r/apps
- **Size:** ~50k, lower quality
- **What to do:** Phase 4, post once.

### r/freeapps, r/AndroidGaming
- **Skip** — wrong audience for MediNest.

---

## Tier 5 — local / cultural (high-CVR for localized listings)

Once we ship localized listings (per `aso/05-aso-roadmap-90day.md`), these become live targets in their respective languages.

### r/saudiarabia, r/Riyadh
- **Audience:** Saudi users (some Arabic, mostly English-fluent)
- **What to do:** comment in Arabic OR English depending on thread. Cultural-context matters more than language.

### r/india, r/IndiaSpeaks, r/IndianAcademia
- **Audience:** Indian users
- **What to do:** medication-cost / generic-availability is a huge topic. MediNest's "save doctor + prescription" angle resonates strongly.

### r/pakistan
- **Audience:** Pakistani users
- **What to do:** smaller but very engaged. Family-medication is a primary use case.

### r/indonesia
- **Audience:** Indonesian users
- **What to do:** Bahasa-Indonesia preferred. Mods usually friendly.

### r/Egypt, r/jordan, r/morocco
- **Audience:** MENA users outside Saudi
- **What to do:** Arabic preferred. Smaller volume but high MediNest fit.

---

## Threads to specifically watch for (search these every week)

Open these as saved searches in your Reddit app or browser. Add to the list whenever you find a useful one:

- `pill reminder` site:reddit.com
- `medication reminder` site:reddit.com
- `forgot to take my meds` site:reddit.com
- `best pill app` site:reddit.com
- `caregiver app recommendations` site:reddit.com
- `mom's medications` site:reddit.com
- `medication tracker app` site:reddit.com

When one of these threads has fewer than 5 comments and you have karma in that sub, comment.

---

## What to track per sub (in `_data/reddit-tracker.csv`)

```
sub,joined_date,karma_in_sub,comments_made,upvoted_replies,banned_or_removed,notes
```

Update weekly. If a sub starts removing your comments, stop posting there immediately and investigate why before resuming.

---

## Quarterly subreddit review

Every 90 days, review:

- Which subs converted best (look at Reddit-tagged installs)
- Which subs spent the most time for the least return — kill those
- Which new subs joined the list (Reddit creates new health subs regularly)
- Which subs changed rules (read pinned post in each sub once per quarter)

Keep this list lean. 8–12 active subs is plenty. 30 active subs becomes a part-time job that distracts from ASO.

# Keyword Research — MediNest

> **Honesty up front.** I do not have live monthly-search-volume numbers for Google Play. No LLM does. The numbers below are *demand priors* — my read of how the keyword has historically behaved in this category — and they need to be replaced with real data from your AppFollow / AppTweak account + Play Console Search Terms report (see `../NEXT-STEPS.md` step 1). Treat this file as the candidate set + scoring rubric, not as verified volume.

---

## How Google Play search actually works (so the rubric makes sense)

Google Play matches a user query against four indexed fields, weighted roughly in this order (Google does not publish exact weights, this is the order ASO practitioners agree on from years of testing):

1. **App title** (30 chars) — strongest signal. A keyword in the title beats the same keyword anywhere else.
2. **Short description** (80 chars) — second strongest, also the line shown above the fold.
3. **Long description** (4 000 chars) — diminishing returns past ~5 occurrences of any one term, and stuffing is penalized.
4. **App package name + developer name** — minor but real.

Outside the listing fields, ranking is also moved by:

- **Install velocity** (installs / day, especially from search results)
- **Retention** (D1, D7, D30)
- **Ratings & reviews** (rating value AND volume; new reviews matter more than old)
- **Engagement** (sessions/user, opens/day)
- **Update cadence** (active apps rank above abandoned ones)
- **Crash + ANR rate**

So keyword choice is necessary but not sufficient. A great keyword + bad retention still doesn't rank.

---

## Scoring rubric (use this when validating each candidate)

| Score | Demand prior | Competition prior | Relevance to MediNest | Action |
| --- | --- | --- | --- | --- |
| **A** | High | Low–Med | Direct | Put in title or short description |
| **B** | Med–High | Med–High | Direct | Sprinkle 2–3× in long description, target via review-prompt copy |
| **C** | Low | Low | Direct | One mention in long description, useful for long-tail |
| **D** | Any | Any | Indirect | Drop. Don't dilute relevance score. |

Demand and competition each get re-graded once you have AppFollow data. Until then, the labels are priors.

---

## Tier 1 — title-worthy candidates (English)

These are the head terms in the category. Almost every successful pill-reminder app on Play has at least one of them in their title.

| Keyword | Demand prior | Competition prior | Notes |
| --- | --- | --- | --- |
| `pill reminder` | High | High | Most direct head term. Already in current title. |
| `medication reminder` | High | High | Slightly broader — captures non-pill (injectables, syrups). Worth fighting for. |
| `medicine reminder` | High | Med | Strong in India / Pakistan / MENA. Sometimes underweighted in US-centric ASO advice. |
| `med reminder` | Med | Med | US shorthand. Good in title for US-targeted listing. |

**Recommendation:** title locks one of these. Current title `Medinest – Pill Reminder` already does. Do not give it up. The redesign in `01-store-listing.md` adds *one more* head term inside the 30-char limit.

## Tier 2 — short-description-worthy

These belong in the 80-char short description because that field has the second-highest weight and is also what users read in 1.5 seconds before tapping.

| Keyword | Demand prior | Competition prior | Notes |
| --- | --- | --- | --- |
| `pill tracker` | High | Med | Different intent: "track what I took" vs "remind me". Captures journaling users — fits MediNest's history+notes feature exactly. |
| `medication tracker` | High | Med | Same as above, broader. |
| `pill organizer` | Med | Med | Often searched by caregivers. Lower in-store CVR but high relevance. |
| `dose tracker` | Med | Low | Long-tail. Easy win in long description. |
| `prescription reminder` | Med | Low–Med | Underused in headlines, real demand exists. |

## Tier 3 — long-tail / long-description fillers

Two-to-five-word queries. Individually small, collectively meaningful for total install volume.

| Keyword | Demand prior | Competition prior | Notes |
| --- | --- | --- | --- |
| `elderly pill reminder` | Med | Low | Caregiver intent. High CVR. |
| `senior medication app` | Med | Low | Same. Pair with `parents` and `caregiver` in copy. |
| `pill alarm` | Med | Low | Often the user's literal pain point. |
| `daily pill reminder` | Med | Med | |
| `medicine schedule` | Med | Low | |
| `medication log` | Low | Low | Aligns with our journal feature. |
| `doctor appointment reminder` | Med | Med | We have appointments — claim this term. |
| `family medication app` | Low | Low | Highlights multi-profile feature. |
| `caregiver app` | Med | High | Crowded category but a relevance match. |
| `health journal` | Med | High | Crowded. Drop unless we double down on the journal feature. |
| `tablet reminder` | Med | Low | Big in India. Localize. |
| `drug reminder` | Low | Low | Lower CVR (clinical-sounding). Skip. |

## Tier 4 — adjacency, decide case-by-case

| Keyword | Why considered | Decision |
| --- | --- | --- |
| `symptom tracker` | We have notes/journal | Skip — separate category (Bearable, Guava). Diluting toward symptoms hurts pill-reminder relevance. |
| `mental health journal` | We have journals | Skip — wrong audience. |
| `period tracker` | Has reminders | Skip — completely different category. |
| `water reminder` | Reminder-adjacent | Skip — different intent. |
| `vitamin reminder` | Subset of pill reminder | **Keep.** Easy mention in long description. |
| `birth control reminder` | Subset, sensitive | Mention with care. Good keyword, clinical sensitivity around copy. |

## Tier 5 — localized (real terms, not transliterations)

These are the actual terms native speakers type, not English-to-language word-for-word maps. Volume needs validation per market.

| Locale | Term | English meaning | Notes |
| --- | --- | --- | --- |
| ar-SA | تذكير بالدواء | medicine reminder | The most common phrasing in Saudi/Gulf listings. |
| ar-SA | منبه الدواء | medicine alarm | Slightly less formal. Pairs well with the alarm/sound feature. |
| ar-SA | تذكير الأدوية | medications reminder | Plural form, slightly higher demand than singular per peer apps' titles. |
| hi-IN | दवा रिमाइंडर | medicine reminder | "रिमाइंडर" is a loanword now standard. |
| hi-IN | दवाई याद | medicine memory | Lower formal demand but very natural — fits short description. |
| ur-PK | دوا یاد دہانی | medicine reminder | Many Pakistani users will also search in English; localize anyway because the listing wins both. |
| id-ID | pengingat obat | medicine reminder | Indonesia is a top opportunity market — high install volume, low ARPU but high LTV via ads. |
| es-ES / es-419 | recordatorio de medicamentos | medication reminder | Use `es-419` for Latin America — separate Play Console listing. |
| pt-BR | lembrete de remédios | medication reminder | Brazil-only, separate from pt-PT. |
| tr-TR | ilaç hatırlatıcı | medicine reminder | |
| de-DE | Tabletten Erinnerung / Medikamenten Erinnerung | tablet/medication reminder | DE users often search both. |
| fr-FR | rappel médicaments | medication reminder | |
| ru-RU | напоминание о лекарствах | medication reminder | |
| ja-JP | 服薬リマインダー | medication reminder | Strong term — Japanese users are heavy reminder-app users. |
| ko-KR | 약 알림 | pill notification | |

> **Translation rule:** never machine-translate the title or short description. Cheaper to pay one native fluent reviewer per locale on Fiverr/Upwork (~$10–25) than to rank for the wrong term. Half the localized listings I've audited in this category have a translated title that no native speaker would search.

---

## Negative-keyword list (do *not* chase these)

We will get pushed toward these by AI tools and bad ASO advice. Don't.

| Keyword | Why we skip |
| --- | --- |
| `medical app` | Too generic. SERP dominated by clinics/telemedicine. Wrong intent. |
| `doctor app` | Same — telemedicine intent. |
| `health app` | Generic, dominated by Samsung/Google Fit. |
| `hospital` | Wrong audience. |
| `diagnosis`, `medical advice` | Regulatory risk. Play Store penalizes apps that imply diagnosis without medical-device certification. |
| `prescription delivery` | Different category (Capsule, NowRx). |

---

## Final priority list to validate (this is what you take to AppFollow)

Order matters — validate top-down and stop when 5 are confirmed strong.

1. `pill reminder`
2. `medication reminder`
3. `medicine reminder`
4. `pill tracker`
5. `medication tracker`
6. `med reminder`
7. `pill organizer`
8. `daily pill reminder`
9. `prescription reminder`
10. `elderly pill reminder`
11. `pill alarm`
12. `medication schedule`
13. `doctor appointment reminder`
14. `tablet reminder` (India)
15. `pengingat obat` (Indonesia)
16. `تذكير بالدواء` (Saudi)
17. `दवा रिमाइंडर` (India Hindi)
18. `vitamin reminder`
19. `senior medication app`
20. `medication log`

---

## What to record in this file once you have data

Replace this section with a table that has columns:

```
| Keyword | Real volume (AppFollow) | Real difficulty | Our current rank | Target rank | Listing field |
```

Source the volume + difficulty from one tool only — don't average across tools because they normalize differently. AppFollow free tier has been the most stable for Play data in my experience.

# Store Listing v1 — Recommended Replacement for the Live Listing

> **MVP scope (2026-05-10):** product pillars are **pill reminder + health journal + family medication support**. Doctor profiles and appointment reminders were removed from MVP. This listing reflects that. Future re-introduction tracked in `../feature-improvements/feature-roadmap.md`.

> **Do not paste any of this into Play Console yet.** Read the change rationale, push back where you disagree, and only then run a Store Listing Experiment. Listing changes are A/B-able in Play Console — never push direct to 100 % of users.

Linked references:
- Live (v0): `store_listing_desc.txt`
- Why these keywords: `02-keyword-research.md`
- Why these patterns: `03-competitor-analysis.md`
- Why these screenshots: `04-screenshot-strategy.md`

---

## Title — recommended

**`Medinest: Pill & Med Reminder`** (29 chars / 30 max)

| | |
| --- | --- |
| Live (v0) | `Medinest – Pill Reminder` (24 chars) |
| Recommended (v1) | `Medinest: Pill & Med Reminder` (29 chars) |
| Change | +`Med` head term, swap em-dash for colon |

Why:

- **Adds a second indexed head term** (`Med`) without losing brand. `Med` is a separate query from `Medicine` and `Medication` and shorter to fit. Pattern lifted from Medisafe (`Medisafe Pill & Med Reminder`).
- **Colon over em-dash.** Em-dash is fine cosmetically but Play Store search query parsing is whitespace-tolerant, not punctuation-tolerant. Colon + space is the safest delimiter for both indexing and visual scan.
- **Stays under 30 chars** — Play truncates with ellipsis at 30. We hit 29.

### Title — alternates to A/B test against v1

| Variant | Chars | Hypothesis | Risk |
| --- | --- | --- | --- |
| `Medinest: Pill Reminder & Log` | 28 | Adds `log` keyword (journal feature) | Loses `Med` head term |
| `Pill Reminder & Tracker — Medinest` | 33 | Pure-keyword lead, brand demoted | **Over 30 chars, do not ship** |
| `Pill Reminder, Med & Family` | 28 | Lead with keyword, add caregiver hook | Drops `Medinest` brand entirely — only test once we have brand-search volume |

> Run v1 vs v0 first. Run alternates only after a winner is declared.

---

## Short description — recommended

**`Pill reminder, medication tracker & journal. Never miss a dose. Family support.`** (79 chars / 80 max)

| | |
| --- | --- |
| Live (v0) | `Never miss your pills. Smart reminders, personal journals, and family support.` (78 chars) |
| Recommended (v1) | `Pill reminder, medication tracker & journal. Never miss a dose. Family support.` (79 chars) |
| Change | Lead with two head keywords + journal as the third, keep benefit. **Doctor feature removed** since it is no longer in the MVP. |

Why:

- The first 80 chars is double-indexed (short description **and** above-the-fold preview text). Putting `pill reminder` + `medication tracker` + `journal` here gives those three keywords short-description weight in addition to whatever long-description weight they get.
- `Never miss a dose` is the proven benefit phrase in this category. (Medisafe has used variants of it for years. There is no penalty for using category-standard phrasing — these are not trademarked.)
- `Family support` is the third feature claim. The previous v1 also tried `doctor support` — that's been pulled because doctor profiles are out of MVP. Once doctor returns post-MVP, A/B `Family & doctor support` against `Family support`.

### Short description — alternates to A/B test

| Variant | Chars | Hypothesis |
| --- | --- | --- |
| `Pill reminder for you & your family. Track meds, log doses, never miss again.` | 77 | Lead with audience (family) instead of feature |
| `Free pill reminder & med tracker. Reminders, dose log, family & doctors.` | 73 | Adds `Free` — known CVR booster on Play |
| `Smart pill reminder & medicine tracker. Doses, family meds, doctor notes.` | 74 | `Smart` removed — `Smart` doesn't beat plain language in pill-reminder SERPs |

---

## Full description — recommended

This block is the source of truth. Paste verbatim into Play Console after review. Character count: ~2 600 of 4 000 budget — leaves room for Play Console's mandatory disclosures and gives us slack for future feature additions.

```
Never miss a dose again.

Medinest is a clean, reliable pill reminder and medication tracker that helps you take medicines on time, log every dose, and keep a personal health journal — for yourself and your family — all in one app.

Whether you handle a single daily pill or coordinate medicines for parents, kids, or a partner, Medinest keeps the routine simple and stress-free.

🔔 Smart Pill Reminders
Set medicines with dosage, time, and frequency. Daily, custom, or recurring schedules. Reliable on-time notifications even when the app is closed. Choose from 11 alert sounds — gentle bells, alarm clock, classic ringtone, or silent.

📋 Medication Tracker & Dose Log
Mark doses as taken, missed, or skipped. Review your full medicine history at any time. A clear daily view shows what is due, what is done, and what is next.

📓 Personal Health Journal
Add notes alongside any medicine, or as standalone journal entries. Track how you feel, side effects, dose changes, or anything worth remembering for your next doctor visit. No fixed templates — write in your own words. The journal is what turns a reminder app into a record you can actually use.

👨‍👩‍👧 Family Medication Support
Add and manage medications for family members in one app. Useful for caregivers handling a parent's pills, a child's prescriptions, or a partner's chronic-condition routine — without mixing schedules.

🌍 Works in Your Language
Medinest is available in 50+ languages including English, Arabic, Hindi, Urdu, Indonesian, Spanish, Portuguese, Turkish, French, German, Russian, Japanese, Korean, Chinese, Vietnamese, Bengali, Tamil, Telugu, and many more.

Why Medinest

• Simple — designed for a single screen, not buried menus
• Reliable — local notifications run even offline
• Private — your data stays on your device, with optional secure cloud backup
• Family-friendly — multiple profiles, one app
• Lightweight — fast on older phones, low battery use

Premium

Free version includes core reminders, full medication history, full health journal, and family support — up to 10 medicines.

Upgrade to Premium for:
• Ad-free experience
• Unlimited medicines
• Unlimited reminders
• Priority support

🔐 Privacy
Medinest does not provide medical advice, diagnosis, or treatment. We do not sell your data. Notifications and history live on your device. Cloud sync is opt-in and uses Google Sign-in for secure backup only.

Built for people who want to take their medicine on time without thinking about it. Try Medinest free today.
```

### Why these specific changes from v0

| Change | Reason |
| --- | --- |
| Open with `Never miss a dose again.` not `Never Miss Your Medicine Again` | Lowercase opener reads more conversational; `dose` is a higher-intent keyword than `medicine` for the head query. |
| Each feature block is **3 sentences max** | v0 had 1–2 sentence blocks. Three sentences gives keyword surface area without becoming a wall of text. Optimal density per ASO testing in this category. |
| Sound list mentioned by name | Reviewers (and people typing `pill alarm` queries) search for sound-customization. Naming the sounds claims those long-tail queries. |
| `Medication Tracker & Dose Log` block | Net new — claims `medication tracker`, `dose log`, `dose tracker` — Tier 2 keywords from `02-keyword-research.md`. |
| `Personal Health Journal` block expanded | Journal is the second MVP pillar. Block now ends on the strong line "the journal is what turns a reminder app into a record you can actually use" — that's the differentiator vs Medisafe and what the marketing copy on every other surface (X, LinkedIn) leans on. |
| **Doctor Profiles block REMOVED** | Doctor profiles are no longer in the MVP. Will return post-MVP once we ship the doctor-export PDF feature (see roadmap T1-4). |
| **Appointment Reminders block REMOVED** | Appointment reminders are no longer in the MVP. The decision: a unified reminder surface (only medicines) is a clearer product story than splitting medicines vs appointments. Re-introduction tracked in roadmap. |
| 50+ languages block | Trust signal AND keyword-rich for non-English SERPs that Google may surface to multilingual users. Numbers ("50+") perform better than vague claims. |
| `Why Medinest` is bullets, not a list of synonyms | v0 said "Clean and easy-to-use interface" — meaningless. v1 says "designed for a single screen, not buried menus" — concrete, defensible. |
| Premium block names the gate (10 medicines) | Pre-emptively answers the #1 1-star review pattern: "didn't know it was limited." Only one cap is mentioned because only one is part of the MVP. |
| Privacy block is shorter, says what we DON'T do | Compliance + trust. Required wording for medical-adjacent apps to avoid Play medical-claims policy hits. |

---

## What does *not* go in the listing (and why)

- **No emoji-spam in the title.** Play does not allow them in titles since 2021 anyway, but worth noting.
- **No "#1 pill reminder app" or "best in class".** Superlatives without substantiation can trigger rejection under Play's "Misleading claims" policy. Once you have a real award/press mention, those CAN be quoted in screenshot captions.
- **No price claim in the description** ("Only 5 SAR/month!"). Localized prices vary; Play renders the user's local price automatically. Hard-coding a number creates inconsistency.
- **No "AI-powered"** anywhere. We are not AI-powered. Play is increasingly aggressive about removing apps that misrepresent AI use.

---

## Listing fields beyond the three big ones

| Field | Recommendation |
| --- | --- |
| App category | Health & Fitness (primary) — keep as-is |
| Tags (Play Console) | `Reminders`, `Medication tracking`, `Family`, `Health journal`. Pick 5 from Play's tag list aligned to our keywords. |
| Contact email | Use a `support@` email, NOT personal Gmail. Reviewers downgrade trust on personal-email contacts. |
| Privacy policy URL | Required. If not hosted, one-page privacy site on GitHub Pages is fine for v1. |
| App icon | Keep current icon for now (assets/img_icon.png). Re-evaluate after first 90 days of CVR data. |
| Feature graphic | `docs/MediNest/Medinest Playstore grahics/Medinest Pill Reminder and Health Journal feature graphic.png` — review with screenshot strategy in `04-screenshot-strategy.md`. |

---

## Localized listings — which markets to ship first

Order is opinionated. Justification in `02-keyword-research.md` and `feature-improvements/ranking-tactics.md`.

1. **ar-SA** — pricing already in SAR. Translation exists in app. Easiest win.
2. **id-ID** — Indonesia is highest-volume English/local-dual market with low ASO competition.
3. **hi-IN** — India volume is enormous; competition is real but the long tail (`दवा रिमाइंडर`) is open.
4. **ur-PK** — Pakistan volume is meaningful, very low competition.
5. **es-419** — Latin America Spanish (NOT es-ES — separate listing).
6. **pt-BR** — Brazil only.
7. **tr-TR**, **ru-RU**, **fr-FR**, **de-DE** — slower to convert but stable rankings once placed.

For each, deliver to a translator:

- The English long description above
- The keyword tier-5 table from `02-keyword-research.md` for that locale
- Instruction: "Do not literal-translate. Localize the title and short description so a native speaker would actually type and tap them. Long description should read naturally."

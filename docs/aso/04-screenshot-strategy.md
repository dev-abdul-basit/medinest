# Screenshot Strategy

> Conversion lever, not a vanity exercise. Play Store CVR (impressions → installs) is moved more by the first 3 screenshots than by the long description. ASO peers in this category typically see CVR swings of **15–40 %** from a screenshot redesign — bigger than from a title change.

You currently have screenshot files in `docs/MediNest/Medinest Playstore grahics/`. They are not on the Play listing in their current form yet (or they are — if so, paste the live ones into Play Console screenshots area as reference). This doc is the redesign brief.

---

## Hard rules from Play Console

- **Phone screenshots:** min 320 px, max 3 840 px, aspect 9:16 to 16:9, **2 minimum, 8 maximum**. Use 1080×1920 or 1242×2208.
- **Tablet screenshots (7" and 10"):** optional but Play boosts visibility on tablets if provided. Often skipped — the work-to-payoff is not great unless tablet usage is high (it isn't, in pill reminder).
- **Feature graphic:** 1 024 × 500. Required.
- **Format:** PNG or JPEG. Keep under 8 MB each.

## What converts in this category — observed pattern

Studying the SERP for `pill reminder` (top 10 across en-US, en-IN, ar-SA — verifiable when you do `NEXT-STEPS.md` step 2):

1. **Slot 1 (above the fold)** — leader almost always shows a person-in-context image. Hand on phone, "Mom's medicine" caption, calendar metaphor. **Not a UI screenshot.**
2. **Slots 2–3** — single phone, big caption ("Never miss a dose", "Family meds in one app"), one feature visible.
3. **Slots 4–6** — feature drilldowns. UI front and center, caption secondary.
4. **Slots 7–8** — social proof ("Trusted by X users", privacy guarantee, awards if any).

What loses: 3-phone collages. Tiny captions. Generic stock photos. Untranslated screenshots in localized listings.

---

## Recommended 8-screenshot set

Caption text is what you give the designer verbatim. Visual idea is the layout brief.

| # | Caption (≤8 words, big text) | Visual idea | Purpose |
| --- | --- | --- | --- |
| 1 | **Never miss your meds.** | Hand holding phone, lockscreen with MediNest reminder visible. Soft natural lighting. | Hook. Above-the-fold conversion. |
| 2 | **One tap to mark a dose.** | Single phone, the today-view UI, big "Taken" button highlighted. | Show core action is fast. |
| 3 | **Reminders for the whole family.** | Phone with the family-member switcher visible, two profile avatars (e.g., "Mom" and "You"). | Differentiator — family/multi-profile. |
| 4 | **Save doctor & prescription details.** | Phone showing doctor profile linked to a medicine. | Differentiator vs Medisafe. |
| 5 | **A journal that goes with your meds.** | Phone showing a journal entry with a medicine attached. | Differentiator + content for screenshots-text-as-keywords ("journal", "notes"). |
| 6 | **11 alert sounds. Pick what wakes you.** | Phone showing the sound picker. Subtle, but claims `pill alarm` keyword. | Long-tail + delight. |
| 7 | **Works offline. Syncs when online.** | Phone showing a "Synced" toast or icon. | Trust + reliability claim. |
| 8 | **Private. No medical advice. No data sold.** | Plain text card, MediNest logo, lock icon. | Trust. Pre-empts privacy concern reviews. |

> Captions stay under 8 words because Play renders screenshots small in search results. Long captions become unreadable.

## Color & font notes for the designer

- Use the app's existing brand color (splash background `#1976D2`) as the dominant accent. Don't introduce a new palette.
- Caption font: bold, sans-serif, minimum 64 pt at 1080 px width. Reader can read at thumbnail size.
- Background: clean (#F7F9FC or off-white). Avoid noisy gradients — they survive Play's lossy compression poorly.
- Always include the phone bezel (mockup), never raw screen — looks more polished and signals "real app".

## Localized screenshots — yes, do them

Same 8 layouts, captions translated by the same native fluent translator who handles the listing copy. Do not OCR-translate — Play sees them as images so there is no penalty for skipping localization, but conversion in non-English markets jumps dramatically when screenshots are translated. Empirically: 20–60 % CVR lift in MENA / India when shown in-language vs. English-only.

Priority order matches `01-store-listing.md`:
1. ar-SA (RTL — flip phone bezel layout)
2. id-ID
3. hi-IN
4. ur-PK
5. es-419
6. pt-BR
7. then en-IN if it tests differently from en-US (occasionally yes — different humor/visuals work)

## Feature graphic

Keep the current `Medinest Pill Reminder and Health Journal feature graphic.png` for v1 unless we A/B test. If redesigning, the brief is:

- Left third: phone with reminder UI
- Middle: app name + 4-word benefit ("Never miss a dose")
- Right third: small icon row — bell, family, doctor, journal
- Avoid the over-stylized 3D phone trend; flat looks more credible in Health & Fitness

## What to A/B test, and in what order

Play Console "Store listing experiments" gives 3 variants per test. Run **one variable at a time** or you can't read the result.

1. **Test 1** — Screenshot 1 (hero): hand-holding-phone vs current static. Run 2 weeks or until 5k installs per arm.
2. **Test 2** — Screenshot 2 caption: `One tap to mark a dose` vs `Mark doses in seconds` vs `Track every pill, every day`.
3. **Test 3** — Title: v1 vs v0.
4. **Test 4** — Short description: v1 vs alt-A from `01-store-listing.md`.
5. **Test 5** — Icon. Only after 1–4 done. Icon tests need ~3× the volume to read.

Stop reading mid-test. Pick the winner with ≥95 % confidence (Play Console reports it). Do not "feel" the result.

## What to record in this file as tests complete

Append a results table:

```
| Test | Variants | Winner | Lift | n (installs) | Date |
```

This becomes the institutional memory. In a year, when "should we redesign screenshots?" comes up, the answer is in this file.

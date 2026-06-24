# X — first 30 days, day-by-day plan

> **Voice / persona note (2026-05-11):** the post copy below is the v1 draft and uses a "grandmother takes 6 medicines" first-person narrative voice that does **not** match Abdul's actual posting style on [@abdlbasit_](https://x.com/abdlbasit_) (which is technical-first, dash-bullet, stack-callout). The **canonical post calendar** is now `docs/ready-to-use/02-x-posts.html` — that file uses Abdul's actual voice with `[relative]` / `[N medicines]` placeholders for the personal-caregiving details. Use this `.md` file for the cadence + reply searches + pillar structure (still correct), but pull post copy from the HTML.

Source posts. Not templates — these are written. You will of course adjust to what's actually true that week.

> Posting time defaults: 9:00 am and 6:00 pm in your local timezone. Caregiver / patient audience is most active in the early morning (medication time) and the evening. Avoid 12–4 pm — engagement dead zone for this niche.

> Convention: `[REPLY:topic]` = your daily 5–10 reply work, listed by theme not by post. `[POST]` = your own post that day.

---

## Week 1 — establish credibility, no link drops

### Day 1 — Mon
- `[POST]` (9 am) Pinned thread (4 tweets) — see `x-strategy.md` "Pinned tweet" section. Write it once, pin it, leave it.
- `[REPLY:5]` Caregiver Twitter — 5 useful replies, no link, in threads about elderly parent care.

### Day 2 — Tue
- `[POST]` (6 pm) Pillar 2 — Build in public:
  > *Shipped today: re-tuned the medication alert to fire even when phone is in Do Not Disturb (Android only — iOS won't let me, sadly). Took 2 days because flutter_local_notifications + DND on Samsung is a maze. Now MediNest behaves the way I needed it to for my grandmother's morning meds.*
- `[REPLY:5]` Polypharmacy / chronic-illness threads.

### Day 3 — Wed
- `[REPLY:8]` Reply-only day. Search: `forgot my pill`, `forgot my meds`, `med reminder` — last 7 days.

### Day 4 — Thu
- `[POST]` (9 am) Pillar 1 — Caregiver pain point:
  > *My grandmother takes 6 medicines a day. Three are timed within 30 minutes of each other. The pillbox doesn't tell her if she took them. The phone alarm dismisses if she rolls over. MediNest's full-screen reminder is one solution to one of those problems. I'm working on the others.*
- `[REPLY:5]`.

### Day 5 — Fri
- `[POST]` (6 pm) Pillar 5 — Journal:
  > *Real journal entry from my own MediNest log: "Switched to evening dose. Less GI upset." That note saved a wasted appointment last month. The journal feature is the one I use most and the one that's hardest to advertise.*
- `[REPLY:5]`.

### Sat / Sun
- Light reply-only days. 3 replies each. Don't post — health niche underperforms on weekends.

### Friday review (5 min)
Note: profile clicks, bio link clicks, DM count. Save to `_data/x-weekly.csv`.

---

## Week 2 — start mentioning the app gently

### Day 8 — Mon
- `[POST]` (9 am) Pillar 4 — Counter-position:
  > *MediNest is not Medisafe. Medisafe is the gold standard and has 100× the team. MediNest is for people who want a fast, no-signup reminder and a dead-simple journal. If you've tried Medisafe and bounced because it felt like too much app, this is for you. (Also free.)*
- `[REPLY:6]`.

### Day 9 — Tue
- `[POST]` (6 pm) Pillar 3 — One-feature-deep:
  > *MediNest's family profiles aren't user accounts. No signup, no separate logins. They're parallel medicine lists inside one app. I built it that way because every caregiver I talked to was logging in and out of medication apps multiple times a day to check on a parent. That's broken UX.*
- `[REPLY:5]`.

### Day 10 — Wed
- `[REPLY:10]` Reply-only. Search target: `my mom's meds`, `caregiver`, `nursing home`, `dementia caregiving`.

### Day 11 — Thu
- `[POST]` (9 am) Pillar 1:
  > *The reason most reminder apps fail older users isn't UI. It's notification trust. If 3 alarms in a row dismiss without action, the user stops believing the alarm. MediNest's interstitial-style reminder is a tax on trust — but I think the trust is worth the friction.*
- `[REPLY:5]`.

### Day 12 — Fri
- `[POST]` (6 pm) Pillar 2 — Build in public:
  > *Stat from this week: ~73% of MediNest users open the app within 30 minutes of a reminder. ~14% never open after a reminder fires. That second number is the one I'm trying to fix.* (Replace with real number from your analytics.)
- `[REPLY:5]`.

### Friday review.

---

## Week 3 — first thread, first targeted outreach

### Day 15 — Mon
- `[POST] [THREAD]` (9 am) Title: *Why my mom uses 3 alarm apps and what I'm doing about it.* 7 tweets. End with "MediNest is what I built. Free." Link in bio, NOT in last tweet — Twitter algorithm de-prioritizes posts with external links.
- `[REPLY:5]`.

### Day 16 — Tue
- `[OUTREACH]` Identify 3 caregiver creators (5k–30k followers). Reply meaningfully on a recent post each. No DM yet.
- `[REPLY:5]`.

### Day 17 — Wed
- `[POST]` (9 am) Pillar 5:
  > *Most underrated feature in MediNest is being able to attach a journal note to a specific medicine. The note shows up next to that medicine forever. Doctors love it. Patients forget to use it.*
- `[REPLY:6]`.

### Day 18 — Thu
- `[POST]` (6 pm) Pillar 2:
  > *MediNest update shipping today: 11 alert sounds. The most-requested in early reviews. Yes, "Telephone" is in there. Yes, my grandmother specifically asked for it. No, "Cartoon" is not for kids — three users said it's the only sound they don't snooze through.*
- `[REPLY:5]`.

### Day 19 — Fri
- `[OUTREACH]` Reply on the second post of each of the 3 creators from Mon.
- `[REPLY:5]`.
- Friday review.

---

## Week 4 — first DMs, light advocacy

### Day 22 — Mon
- `[POST]` (9 am) Pillar 4:
  > *Real talk on pricing: I charge 5 SAR/month for MediNest Premium. That's about $1.30. People in MENA pay it. People outside it usually don't. Annual plan is the upgrade path I should have led with — fixing that next month.*
- `[REPLY:5]`.

### Day 23 — Tue
- `[OUTREACH]` DM the 3 creators. Template — adjust per person:
  > *Hi [name], I've been following your posts about [specific topic from their feed]. I'm a solo dev building MediNest, a free pill reminder app, and your audience overlaps strongly with our users. Not pitching anything — happy to give you Premium for life and walk you through it on a 10-min call if it's interesting. If not, no worries.*
- `[REPLY:5]`.

### Day 24 — Wed
- `[POST]` (9 am) Pillar 1:
  > *Story I keep hearing from MediNest users: they didn't want a reminder app, they wanted to stop feeling guilty about forgetting. The reminder is the symptom. The journal is the actual fix — it makes the guilt visible and movable. Took me 8 months to figure that out.*
- `[REPLY:6]`.

### Day 25 — Thu
- `[POST]` (6 pm) Pillar 2:
  > *Localized MediNest into Arabic this week. Listing live in Saudi Arabia. Conversion in MENA on day 1: 5× English-only. The lesson: it's never the language, it's the trust.*
- `[REPLY:5]`.

### Day 26 — Fri
- `[POST]` (9 am) Pillar 3:
  > *Doctor profiles in MediNest are intentionally lite. Just name, specialty, contact. I do not want this to become a CRM. Reminder apps that creep into "patient management" lose the one thing that made them useful: speed.*
- `[REPLY:5]`.
- Friday review + update `aso/05-aso-roadmap-90day.md` with X-attributable installs.

---

## Reply-search shortcuts to keep open in tabs

These saved searches should be bookmarked in your browser for the daily reply work. Pin them as a Twitter list if your X plan allows.

| Search | Purpose |
| --- | --- |
| `forgot my pill -is:retweet lang:en` | Live caregiver / patient frustration |
| `medication reminder -app -ad -is:retweet lang:en` | Discovery without competitors flooding the feed |
| `polypharmacy -is:retweet lang:en` | Medical / clinician audience |
| `my mom's meds -is:retweet lang:en` | Caregiver-of-parent audience |
| `caregiver burnout -is:retweet lang:en` | Adjacent — handle with empathy, not pitch |
| `pill alarm -is:retweet lang:en` | Direct intent |
| `(t1d OR ms OR ibd OR lupus OR crohns) (medication OR meds) -is:retweet` | Chronic-illness niche |
| `from:user1 OR from:user2 OR from:user3` | Your top 3 outreach creators (replace usernames once chosen) |

---

## End-of-month review template (2 minutes)

At Day 30, paste this into `_data/x-month-1.md`:

```
## Month 1 X review (date)

### Hard numbers
- Followers gained: __
- Profile clicks: __
- Bio link clicks: __
- DMs received: __ (of which: meaningful __)
- Estimated installs from X: __

### Best-performing post
[paste link + 1 line on why]

### Best-performing reply
[paste link + 1 line on why]

### What I'll change for month 2
- Less of: __
- More of: __
- New experiment: __
```

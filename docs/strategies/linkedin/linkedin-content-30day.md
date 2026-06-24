# LinkedIn — first 30 days, posts written out

> **Voice / persona note (2026-05-11):** the post copy below is the v1 draft and uses a personal-narrative voice that does **not** match Abdul's actual posting style on [dev-abdul-basit](https://www.linkedin.com/in/dev-abdul-basit/) (technical hook, arrow-bullets, question CTA, hashtag stack). The **canonical post calendar** is now `docs/ready-to-use/03-linkedin-posts.html` — that file uses Abdul's actual voice and references his existing live Medinest posts. Use this `.md` file for the cadence + targets + DM strategy (still correct), but pull post copy from the HTML.

These are the actual posts, not templates. Edit before publishing — your real numbers go in the `__` placeholders.

> Posting time: Tue 8:30 am for long-form, Thu 9:30 am for short. Avoid Mon (algorithm priority is for hiring posts) and Fri afternoon (low engagement).

---

## Week 1

### Tuesday — Pinned founder post (long, ~2 000 chars)

> **Subject line (LinkedIn auto-pulls first line as preview, treat it like a hook):**
> *I've spent the last year building a pill reminder app. Here's what I got wrong before I shipped.*
>
> ---
>
> A year ago I started building MediNest because my grandmother's pillbox kept failing her in three predictable ways:
>
> 1. The morning alarm dismissed itself when she rolled over and her phone pressed against the bed.
> 2. She couldn't tell, mid-day, if she had taken the pill — the pillbox slot was empty either way.
> 3. The doctor visit always ended with "and have you been taking your medicine?" — and nobody had a clean answer.
>
> The first version of MediNest tried to fix problem 1 with louder alarms. That was wrong. Louder alarms train the user to swipe faster. The fix was a full-screen reminder that requires a tap to dismiss — friction *as a feature*.
>
> The second version tried to fix problem 2 with a checklist UI. Also wrong. People don't want to check things off; they want to *not have to*. The fix was a single "Taken" button on the home screen, no list to navigate.
>
> The third problem was the most interesting. The fix isn't a tracker — it's a journal. A note saying "switched to evening dose, less nausea" attached to that medicine, visible six months later at the doctor's office. That's the feature MediNest gets the most quiet thank-yous for, and the one that's hardest to advertise.
>
> Lessons that compounded across all three:
>
> — Designing for the **caregiver** matters more than designing for the user. The person who installs the app is rarely the person taking the medicine.
> — Friction can be a feature when the goal is trust, not speed.
> — The boring features (notes, profile-switching, sound choice) drive far more retention than the cool features (graphs, AI, social).
>
> MediNest is now in 50+ languages, free, and has [__] users. I'm a solo developer. The hardest week was the week I stopped adding features and started removing them.
>
> If you build in healthtech or caregiver tools, my DMs are open.

End with: link to Play Store. Tag the MediNest company page.

### Daily comments — Week 1 (5/day)
Search `caregiver tech`, `polypharmacy`, `medication adherence`, `healthtech UX`, `aging in place`. Reply with one sharp observation, no app link.

---

## Week 2

### Tuesday — long post (~1 200 chars)

> *I priced MediNest's premium plan at 5 SAR per month. That's about $1.30. Let me explain why.*
>
> Saudi Arabia is our top non-US market. Setting prices in SAR — and not auto-converting from USD — has lifted MENA conversion 3× compared to a USD price.
>
> The trade-off: when the same SAR price auto-converts to USD for a US user, MediNest looks suspiciously cheap next to Medisafe at $4.99/mo. That's bad.
>
> The fix is Play Console regional pricing — set a price tier per region, not a single global one. Most indie developers skip this step because Play Console buries it. It is one of the highest-leverage 30-min jobs in mobile pricing.
>
> A pill reminder for $1.30/mo in Riyadh and $4.99/mo in Chicago is not pricing chaos — it's purchasing-power parity, which is what every category leader does and most solo devs forget.
>
> If you're an indie dev shipping a freemium app and pricing in one currency for the world, you're leaving 30–60 % of revenue on the floor. (Source: my own A/B in MediNest.)

### Thursday — short post + image
Image: side-by-side phone mockup of English vs Arabic listing.
> *The Arabic version of MediNest's listing took 3 hours and a $25 native-fluent reviewer. CVR in MENA jumped 5× the first day. The lesson is the same as it was 10 years ago: localization is the cheapest growth lever in mobile.*

### Daily comments — Week 2 (5/day) — continue. Send first DM (low-stakes target).

---

## Week 3

### Tuesday — long post (~1 800 chars)

> *Why I almost added AI to MediNest, and why I pulled back.*
>
> Six months ago, "AI medication assistant" felt inevitable. Every healthtech investor I bumped into asked when MediNest would have it. Two issues stopped me:
>
> First — regulatory. Even a soft "AI suggests when to take your dose" feature crosses a line that triggers Play Store medical-device policy review. Most apps that try get through eventually. Some don't. The cost of getting it wrong, for a one-person operation, is the company.
>
> Second — actual user need. I shadowed five caregivers for two days each. Not one of them said "I wish my reminder app understood me better." All five said variants of "I wish my reminder app would just *not fail*." That's a notification reliability problem, not an AI problem.
>
> What we built instead: full-screen reminders that require a tap to dismiss; per-medicine custom sounds; family-profile reminders that route to the right person's phone if multiple people install MediNest.
>
> The "AI feature" we will probably ship eventually: an opt-in summary of your medication notes for your next doctor's visit. Local processing only. No diagnosis, no advice. That's a writing-aid feature, not an AI agent.
>
> If you're building healthtech and an investor asks where your AI story is — be ready with an answer that protects your audience, not your fundraising.

### Thursday — short post
> *Solo dev, no marketing budget, 50+ languages. The pipeline: open-source community translations for the in-app strings, paid native-fluent reviewers ($25–50/locale) for the store listing only. Total cost so far: under $400. Total localized markets: 6 in the next month. The internet is full of cheap leverage if you ignore the "AI translation" advice.*

### Daily comments — 5/day. Send DMs #2 and #3 (newsletter writers).

---

## Week 4

### Tuesday — long post (~2 000 chars)

> *MediNest, 30 days into telling its story on LinkedIn. Here's what worked, what didn't, what I changed.*
>
> Hard numbers from the month:
> — Followers: __ → __
> — Profile views from target audience: ~__/wk
> — DM conversations started: __
> — Press inquiries: __
> — Installs attributable to LinkedIn: __ (small. expected. LinkedIn is for trust, not installs.)
>
> What worked:
> 1. The pricing post (Week 2). Generated more replies than every other post combined. Lesson: indie devs hunger for pricing transparency. I will write about pricing again.
> 2. Reply-style commentary on a big healthtech post in Week 3. Got more reach than my own post that day. Lesson: I am still building distribution. Borrow it from people who already have it.
>
> What didn't work:
> 1. The "AI features" post got reach but the wrong reach — investor traffic, not user traffic. I'm a freemium consumer app. Investor reach has near-zero value for me.
> 2. Posting from the company page. 5 % of the reach of the same post from my personal profile. Confirmed.
>
> What's next:
> — Doubling down on caregiver-tech POV posts.
> — Cutting company-page posting to 1/month, repost-only.
> — First press pitch ships this week.
>
> The job on LinkedIn for an indie consumer app is to look credible enough that someone evaluating you stops at the profile and doesn't keep clicking. Done well, that's all you need from this channel.

### Thursday — short post
> *Press pitches go out today. Three writers, three angles, three different outlets. The angle that always works: "Solo developer, hard problem, real users, specific story." The angle that never works: "Disruptive AI-powered next-gen platform." Pick one.*

### Daily comments — 5/day. Send DMs #4 and #5 (caregiver org managers).

---

## End-of-month review template

Paste into `_data/linkedin-month-1.md`:

```
## Month 1 LinkedIn review (date)

### Hard numbers
- Connections gained: __
- Post impressions total: __
- Best post (link + impressions): __
- DMs sent: __
- DM replies: __
- Press pitches: __ (responses: __)
- Estimated installs: __

### What worked
[2 sentences]

### What didn't
[2 sentences]

### Plan changes for month 2
[3 bullets]
```

---

## Long-form pipeline for months 2–3 (titles only — write closer to date)

- *The boring features that drive 80 % of MediNest's installs*
- *I removed a feature that cost me a week of work. CVR went up.*
- *What 200 reviews of pill reminder apps taught me about caregiver UX*
- *Pricing pill reminder apps in 50 markets: a developer's regional-price playbook*
- *Why I won't build "social features" into a medication app*
- *The night-shift problem: nobody designs for shift workers and they need pill reminders most*

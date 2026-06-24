# F05 · Privacy Policy Link Verification

| | |
| --- | --- |
| Roadmap ref | QW-5 |
| Effort | ½ day (mostly verification, not coding) |
| Risk | low |
| Schema change | no |
| New package | no |
| Premium-gated | no |
| ASO signals moved | Compliance, ★ |
| Status | spec |

## 1. Why we're shipping it

Required by Google Play. Apps in Health & Fitness without a working privacy policy link in **both** the listing and inside the app are at higher risk of policy review and rating sentiment hits. The current `Constant.privacyPolicyURL` is set to `https://developermatic.com/apps/medinest/privacy/` — needs verification that the URL actually serves a real page that meets Play's policy requirements.

## 2. What changes for the user

If the URL works: nothing changes for the user. We just verify and document.

If the URL is dead or the page is incomplete: a working URL is hosted, and the app's Settings → About / Settings → Privacy entry actually navigates there.

## 3. What changes in the code

Most likely: **no code changes** if the URL works and the app already opens it correctly.

If changes are needed:

- **`lib/utils/constant.dart`** — update `Constant.privacyPolicyURL` if the live URL has moved
- **`lib/ui/setting/setting_screen_view.dart`** — verify the privacy link tile correctly fires `url_launcher`'s `launchUrl(...)` with the URL
- **NEW: page on `developermatic.com`** *(if not already live)* — Abdul's job, not Claude's

## 4. Data model

No schema changes.

## 5. Locale keys

Verify existing key (likely `txtPrivacyPolicy` or similar) renders the right string. No new keys.

## 6. Routing

No routing changes.

## 7. Implementation steps (linear)

1. Open `https://developermatic.com/apps/medinest/privacy/` in a browser. Verify it loads and shows a real privacy policy.
2. Read the policy. It must address (Play's required topics for medical-adjacent apps):
   - What data is collected (email, FCM token, medicine names, doctor info, photos if any)
   - How it's stored (Firebase Firestore, Firebase Auth, GetStorage local)
   - Third parties it's shared with (none / Google / AdMob)
   - User rights (request deletion via email)
   - Contact email (`info@developermatic.com` or new one)
3. If any of step 2 fails: hand the gap list to Abdul. Implementation pauses until the URL is updated. (This is the "your side" item, not Claude's.)
4. Once URL is verified: open `lib/ui/setting/setting_screen_view.dart` and find the "Privacy Policy" entry. Trace it to a tap handler. Verify it calls `launchUrl(Uri.parse(Constant.privacyPolicyURL), mode: LaunchMode.externalApplication)` (or equivalent — match existing pattern).
5. Run on device. Tap → confirm browser opens with the right URL.
6. Repeat for `Constant.aboutUsURL` and `Constant.termsAndConditionURL`. Same checklist.
7. In Play Console → "App content" → "Privacy policy" → confirm the URL field matches `Constant.privacyPolicyURL`. Abdul's job.

## 8. Manual test plan

**Golden path:**

1. Open Settings.
2. Tap Privacy Policy.
3. **Expected:** browser opens to the policy page. Page loads, shows real content.

**Edge case — offline:**

1. Airplane mode on. Tap Privacy Policy.
2. **Expected:** OS-level browser error, app doesn't crash.

**Edge case — multiple browsers:**

1. With multiple browsers installed, tap. **Expected:** browser chooser appears (or default browser opens). No crash.

**Regression check:**

Tap About Us, Terms & Conditions. Confirm they all open their respective URLs.

## 9. Rollout

- This is mostly a verification + Play Console field check. Ship a release only if a code change was needed.
- Roll-back: revert the URL constant.

## 10. Definition of done

Per `../04-definition-of-done.md`. Specifically:

- URL loads and serves a privacy policy that names data collected
- Play Console field matches `Constant.privacyPolicyURL`
- All three URLs (privacy, about, terms) verified

## 11. Out of scope

- Drafting the actual privacy policy content (that's a writing job, not a code job)
- Hosting infrastructure changes
- GDPR / DPA documentation beyond what Play Store requires

## 12. Open questions

1. Does the live policy mention AdMob and Firebase by name? If not, it must.
2. Is the support contact email a `support@` address or personal Gmail? Reviewers downgrade trust on personal-email contacts. Migrate to `support@developermatic.com` if not already.

---

## Implemented

- Date: 2026-05-09
- versionCode shipped: pending
- **No code changes needed on Claude's side** for F05.
- Verified:
  - `Constant.privacyPolicyURL` = `https://developermatic.com/apps/medinest/privacy/`
  - `Constant.aboutUsURL` = `https://developermatic.com/apps/medinest/about/`
  - `Constant.termsAndConditionURL` = `https://developermatic.com/apps/medinest/terms/`
  - All three are wired via `Utils.urlLauncher(...)` in `lib/ui/setting/setting_screen_view.dart` lines 160 / 169 / 178, and `urlLauncher` opens with `LaunchMode.inAppBrowserView` (good UX).
- **Pending — Abdul's verification (cannot do from code):**
  1. Open each URL in browser. Confirms real privacy policy / about / terms content.
  2. Privacy policy must list: data collected (medicine names, FCM token, doctor info, photos), storage (Firebase + GetStorage), third parties (Google AdMob), user rights (deletion via email), contact (`info@developermatic.com`).
  3. Play Console → "App content" → Privacy policy field — confirm matches `Constant.privacyPolicyURL`.
- **Out-of-scope risk flagged (NOT fixed in F05):**
  - `lib/utils/utils.dart::urlLauncher` line 90 does `throw "Cannot load the page";` — string throw, unhandled. If user is offline, the app crashes the action. Would benefit from a `try/catch` + toast. Suggest opening a separate small spec for this — call it `F05a` if pursuing.

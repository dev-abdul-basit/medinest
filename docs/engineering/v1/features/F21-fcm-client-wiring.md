# F21 · FCM Client Wiring (phase-2 prep)

| | |
| --- | --- |
| Roadmap ref | engagement-system.md §5 |
| Effort | ½–1 day |
| Risk | low (additive; inert without a backend sender) |
| Schema change | no |
| New package | no (`firebase_messaging` already in pubspec) |
| Premium-gated | no |
| ASO signals moved | R (phase 2) — enables remote campaigns once a sender exists |
| Status | shipped (client only) |

## 1. Why we're shipping it

Today the FCM token is fetched but nothing else is wired — no background handler, no foreground display, no token refresh, no topic. This wires the **device half** so a future backend can reach users. **HONEST LIMITATION: it is inert until a backend sends a push** — there is no Cloud Function / campaign sender yet (the server half of engagement-system.md §5, deferred until the local system proves it moves D7). Subscribing every install to a broadcast topic now means a later broadcast needs no token list.

## 2. What changes for the user

Nothing today. When a backend later sends a push: it shows in the tray (backgrounded) or as a local notification (foregrounded), and tapping opens the app to Home.

## 3. What changes in the code

- **`lib/services/fcm_service.dart`** *(new)* — `initialize()`: request permission, persist token + `onTokenRefresh`, `subscribeToTopic(Constant.fcmBroadcastTopic)`, `FirebaseMessaging.onMessage` → render via `NotificationHelper.showEngagementNotification` (FCM doesn't auto-display in foreground). Wrapped in try/catch so a messaging failure never blocks startup.
- **`lib/main.dart`** — top-level `@pragma('vm:entry-point') _firebaseMessagingBackgroundHandler` (minimal; data-only messages), registered via `FirebaseMessaging.onBackgroundMessage`; `FcmService().initialize()` after `Firebase.initializeApp()`. Added `firebase_messaging` + `debug` imports.
- **`lib/utils/constant.dart`** — `fcmNotificationId`, `fcmBroadcastTopic`.

The existing token fetch in `get_started_screen_logic.dart` is left as-is (harmless redundancy; `FcmService` is the canonical path).

## 4. Data model

No schema change. Reuses `Preference.fcmToken`.

## 5. Locale keys

`n/a` — push copy comes from the server payload.

## 6. Routing

No new route. Foreground push uses `engagementPayload` → Home-guarded tap (F18).

## 7. Implementation steps (linear)

1. Constants.
2. `FcmService`.
3. `main.dart` background handler + registration + `initialize()`.
4. `flutter analyze`.

## 8. Manual test plan

- Cold start → log shows token persisted + topic subscribed; no crash if messaging unavailable (try/catch).
- **Backend smoke (when available):** send a test push from Firebase console to topic `all` → app foregrounded shows a local notification; backgrounded shows in tray; tap → Home.
- Token refresh: trigger a refresh → `Preference.fcmToken` updates.
- Regression: app launches normally; local medicine reminders unaffected.

## 9. Rollout

No flag. Roll-back: revert the new service + `main.dart` additions + constants.

## 10. Definition of done

Token persisted + topic subscribed on launch; foreground push renders; startup never blocked by a messaging error.

## 11. Out of scope

- **The backend sender** (Cloud Function / campaign table / scheduling) — the server half, phase 2.
- A/B testing + dynamic content infra.
- Rich/data-message deep links beyond opening Home.

## 12. Open questions

What backend sends pushes (Cloud Function vs third-party) and what the first campaign is — operator decision, gated on local-system results.

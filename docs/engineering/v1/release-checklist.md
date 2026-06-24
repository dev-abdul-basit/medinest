# Pre-Release Checklist (v1)

Run before every Play Console release.

## Code
- [ ] `pubspec.yaml`: `versionCode` incremented
- [ ] `pubspec.yaml`: `versionName` follows `MAJOR.MINOR.PATCH` and reflects scope
- [ ] No new packages added without a corresponding spec entry
- [ ] `flutter analyze` clean (or only known pre-existing warnings)
- [ ] Tested on Android 9 device + Android 13/14 device
- [ ] Tested in Light AND Dark theme
- [ ] Tested in English AND Arabic (RTL)

## Listing
- [ ] "What's new" copy written (English, 100–500 chars)
- [ ] If localized listings are live: "What's new" copy translated for each locale (use the translator pipeline, NOT machine translation)
- [ ] Screenshots still match the current build (no UI regressions vs screenshots)

## Play Console
- [ ] Privacy policy URL still loads
- [ ] Data safety form still accurate (any new permissions or data collected this release?)
- [ ] Internal track tested first when feature is non-trivial; promote to production after manual smoke

## Post-release
- [ ] Watch crash-free rate for 48 h. Roll back if < 99 %.
- [ ] Reply to first 10 reviews of the new release
- [ ] Update `aso/05-aso-roadmap-90day.md` notes with release date
- [ ] Bump `versionCode` reference in any feature spec that shipped, in their `Implemented` block

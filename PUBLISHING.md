# Publishing “The Context Dictionary” to Google Play

This is the ordered, end-to-end checklist to take the app from its current state
to an approved production release. Items marked **[YOU]** must be done in your own
Google/Firebase/RevenueCat accounts — I can’t do those in code. Items marked
**[CODE ✓]** are already done on this branch (`claude/production-readiness-firebase-ai`).

> **Config values are supplied at build time via `--dart-define`, and secrets
> (keystore, `key.properties`) are git-ignored.** Nothing sensitive lives in the repo.

---

## 0. What changed on this branch (so you know the new wiring)

- **[CODE ✓] AI now runs through Firebase AI Logic** (`firebase_ai`, `FirebaseAI.vertexAI()`),
  replacing the direct `google_generative_ai` SDK. **No Gemini API key ships in the app anymore.**
- **[CODE ✓] `.env` + `flutter_dotenv` removed.** The Gemini key is gone entirely; the RevenueCat
  key now comes from `--dart-define=REVENUECAT_API_KEY=…`.
- **[CODE ✓] App Check** is initialised in both the main app and the overlay isolate — Play Integrity
  for release, debug provider for debug builds.
- **[CODE ✓] Release signing** reads `android/key.properties` (falls back to debug keys if absent).
- **[CODE ✓] AdMob rewarded unit ID** comes from `--dart-define=ADMOB_REWARDED_ID=…` (test ID fallback).
- **[CODE ✓] Legal pages** drafted in `legal/` and linked from Settings.
- **[CODE ✓]** Removed the obsolete `bin/test_api.dart` dev script.

After pulling this branch, run:
```bash
flutter pub get
# If version-solving fails on firebase_ai, run:  flutter pub add firebase_ai
```

---

## 1. Firebase (required — the app won’t do AI lookups without it)

- **[CODE ✓] Project `com-context-dict-v1` is now wired in:** real `lib/firebase_options.dart`,
  `android/app/google-services.json`, and the `com.google.gms.google-services` Gradle plugin applied.
  (If you re-provision or add iOS, re-run `flutterfire configure`.)
- **[YOU]** still required in the Firebase console:
1. In **Build → Firebase AI Logic**, enable it and choose the **Gemini Developer API** provider —
   this is **free, no billing/Blaze needed** (the app is coded for this backend via
   `FirebaseAI.googleAI()`). The free tier has rate limits; to raise them later, switch to Vertex AI
   (Blaze) and change `.googleAI()` → `.vertexAI()` in `lib/services/llm_service.dart` and
   `lib/overlay/overlay_main.dart` — no other code changes.
2. **App Check:**
   - Register **Play Integrity** for the Android app (Firebase → App Check).
   - Add your app’s **SHA-256** fingerprints (both your upload key and Google Play App Signing key —
     get the Play one from Play Console → Setup → App signing).
   - Turn **enforcement ON** for the Firebase AI Logic / Vertex AI API.
   - For local testing, run a debug build once, copy the **debug token** printed in logcat, and add it
     under App Check → Apps → Manage debug tokens.
6. Set a **budget alert / quota** on the project so AI usage can’t surprise-bill you.

> Sanity check: a release build on a real device should return AI results. If it fails, it’s almost
> always App Check (missing SHA-256 or enforcement without a registered device).

## 2. RevenueCat (subscriptions) **[YOU]**

The code already uses RevenueCat; you just need the dashboard + key.

1. Create the app in <https://app.revenuecat.com>, linked to Google Play (upload a Play service-account
   JSON so RevenueCat can validate purchases).
2. Create the two products **in Play Console first** (see §3), then add them in RevenueCat.
   - The code expects product IDs **`context_monthly_sub`** and **`context_lifetime_unlock`**
     (see `lib/services/subscription_service.dart`) and an **entitlement named `pro_fluency`**.
   - Create an **Offering** whose packages map to those products (the paywall reads
     `offerings.current.monthly` / `.annual` style packages via `products`).
3. Copy the **Android (public) API key** (`goog_…`) and pass it at build time (§6).
4. Confirm the entitlement identifier in the dashboard is exactly **`pro_fluency`** (that string is
   hard-coded as the premium check).

## 3. Google Play Console — products & app setup **[YOU]**

1. Create the app (package **`com.context.dict.v1`**), complete the store listing (title, short/full
   description, screenshots, feature graphic, icon).
2. **Subscriptions / in-app products:** create `context_monthly_sub` (subscription) and
   `context_lifetime_unlock` (one-time product) with prices in each market.
3. **AdMob:** create the app + a **Rewarded** ad unit at <https://apps.admob.com>. Then:
   - Pass the rewarded unit ID via `--dart-define=ADMOB_REWARDED_ID=…` (§6).
   - Put the real **AdMob App ID** in `android/app/src/main/AndroidManifest.xml` (replace the
     `ca-app-pub-3940256099942544~3347511713` test value in the `APPLICATION_ID` meta-data).
   - Link the AdMob app to the Play listing; complete AdMob’s app-ads.txt if you use it.

## 4. Release signing **[YOU]**

1. Create an upload keystore (keep it safe — losing it means you can’t update the app):
   ```bash
   keytool -genkey -v -keystore ~/context-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (already git-ignored):
   ```properties
   storePassword=…
   keyPassword=…
   keyAlias=upload
   storeFile=/absolute/path/to/context-upload.jks
   ```
3. Enable **Play App Signing** when you upload the first bundle (recommended).
   Remember to register **both** SHA-256 keys with Firebase App Check (§1.5).

## 5. Legal pages **[YOU + CODE ✓]**

- **[CODE ✓]** `legal/privacy-policy.html` and `legal/terms.html` are drafted and accurate to the app’s
  data flows. Settings links point to `https://neurodevlabs.com/context/privacy` and `…/context/terms`.
- **[YOU]** Host both at those URLs (or change the two URLs in `lib/screens/settings_screen.dart` to
  wherever you host them). Fill the `[CONFIRM]` placeholders (legal entity name, governing-law
  jurisdiction) and have them reviewed.
- **[YOU]** Add the Privacy Policy URL in Play Console → App content → Privacy policy.

## 6. Build commands (with the config injected)

```bash
flutter build appbundle --release \
  --dart-define=REVENUECAT_API_KEY=goog_XXXXXXXXXXXX \
  --dart-define=ADMOB_REWARDED_ID=ca-app-pub-REAL/REWARDED
```
Tip: put these in a `--dart-define-from-file=prod.json` (git-ignored) so you don’t retype them.
The output bundle is `build/app/outputs/bundle/release/app-release.aab`.

## 7. Play Console → App content (Data Safety & declarations) **[YOU]**

Answer the **Data safety** form to match how the app actually behaves:

| Question | Answer |
| --- | --- |
| Does the app collect/share data? | **Yes** (via ads + AI + purchases; no accounts) |
| Personal info | None required (no name/email/account) |
| App activity — **search history / user content** | Collected, **stored on device**; the searched term is **sent** to Google (Gemini), Wikipedia, dictionaryapi.dev to generate results |
| Device / other IDs — **advertising ID** | Collected & shared via **Google AdMob** |
| Purchase history | Processed via **Google Play + RevenueCat** |
| Data encrypted in transit | **Yes** (all endpoints HTTPS) |
| Data-deletion method | Uninstall / clear app storage (no account to delete) |

Other declarations:
- **Ads:** “Contains ads” = **Yes**.
- **Permissions justification** (Play will ask): `SYSTEM_ALERT_WINDOW` → the optional premium floating
  search bubble; `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` → the daily “Word of the Day” reminder
  (consider switching to inexact alarms if Play pushes back, since it’s cosmetic);
  `POST_NOTIFICATIONS`/`RECEIVE_BOOT_COMPLETED` → the daily reminder and rescheduling after reboot.
- **Content rating** questionnaire, **Target audience** (not children), **News** = No, **COVID** = No.
- **Ad consent (UMP):** **[CODE ✓]** the User Messaging Platform flow is implemented
  (`lib/services/consent_service.dart`) — consent is gathered at startup, ad requests are gated on
  `canRequestAds()`, and Settings shows an “Ad Privacy Options” entry when required. **[YOU]** in the
  **AdMob console → Privacy & messaging**, create a **GDPR (EEA)** consent message (and optionally a
  US-states message) and publish it — the app displays whatever you configure there.

## 8. Pre-launch test pass **[YOU]**

- Upload to the **Internal testing** track first.
- Verify on a **real device, release build**: AI search returns results (App Check working); rewarded
  ad loads with the real unit; purchase → premium unlocks → overlay enables; **cancel a sub in a test
  account and confirm premium drops** (this is the behaviour RevenueCat gives you that the old code
  didn’t); notifications fire; restore purchases works.
- Run `flutter analyze` and fix anything; test a cold start with no network (the startup fallback UI).

---

## Quick status

| Blocker from the audit | Status |
| --- | --- |
| Gemini API key shipped in APK | ✅ fixed (Firebase AI Logic; `.env` removed) |
| Release signed with debug keystore | ✅ code ready — **[YOU]** supply `key.properties` |
| Test AdMob rewarded unit ID | ✅ now a `--dart-define` — **[YOU]** supply real ID |
| Test AdMob App ID in manifest | ⚠️ **[YOU]** one-line swap in `AndroidManifest.xml` |
| No privacy policy / terms | ✅ drafted — **[YOU]** host + fill `[CONFIRM]` |
| No in-app support contact | ✅ added (Settings → Contact Support) |
| Firebase config real values | ✅ wired (project `com-context-dict-v1`) — **[YOU]** enable Gemini Developer API (free) + App Check |
| RevenueCat dashboard/products/key | ⚠️ **[YOU]** set up + supply key |
| Ad consent (UMP) for EEA | ✅ implemented — **[YOU]** publish a GDPR message in AdMob |

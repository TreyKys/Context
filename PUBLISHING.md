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
- **[CODE ✓] AdMob is wired with the real IDs** — App ID `ca-app-pub-6864344458492366~8945518466` in
  the manifest; the rewarded unit is real in release builds and Google's test unit in debug (no
  dart-define needed).
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
- **[CODE ✓] No native Gradle deps to add by hand.** The Firebase console’s "add the SDK" step shows a
  native `firebase-bom` / `firebase-ai` / `firebase-appcheck-debug` block — **skip it.** The FlutterFire
  packages (`firebase_ai`, `firebase_app_check`) already bundle those native libraries; hand-adding the
  BoM block causes version conflicts.
- **[YOU]** still required in the Firebase console:
1. In **Build → Firebase AI Logic**, enable it and choose the **Gemini Developer API** provider —
   this is **free, no billing/Blaze needed** (the app is coded for this backend via
   `FirebaseAI.googleAI()`). The free tier has rate limits; to raise them later, switch to Vertex AI
   (Blaze) and change `.googleAI()` → `.vertexAI()` in `lib/services/llm_service.dart` and
   `lib/overlay/overlay_main.dart` — no other code changes.
2. **App Check — currently DISABLED in the client (`kAppCheckEnabled` defaults to false).**

   > **Why:** activating App Check makes the AI call throw *client side* during token fetch whenever
   > attestation fails. Setting the API to **Unenforced** does **not** prevent this — "unenforced"
   > governs how the server treats an unverified request, not whether the client SDK throws. While the
   > API is unenforced, App Check therefore buys **no protection at all** (every request is accepted
   > either way) while being a hard dependency that breaks search for **every** user. Symptom seen in
   > testing: `[firebase_app_check/unknown] … 403 App attestation failed`, and **zero** requests
   > reaching the API in App Check metrics — the call dies before it leaves the device.

   **To turn it back on — in this order, verifying each step:**
   1. **App Check → Apps →** register **`com.context.dictv1`** for **Play Integrity**.
      ⚠️ The older `com.context.dict.v1` entry is a *different app*; registering it does nothing here.
   2. Add the **Play App Signing SHA-256** (Play Console → **Test and release → Setup → App signing**).
      Play strips your upload signature and re-signs with its own key, so the upload key fingerprint
      alone is **not** sufficient for anything installed from Play.
   3. Google Cloud console → **APIs & Services → Library → Play Integrity API → Enable** on
      `com-context-dict-v1`. (This is *not* the same as the "Play Integrity API" settings page in Play
      Console — those 7 toggles are optional *verdict fields* that App Check does not use. Enabling
      them does not help.)
   4. Build with `--dart-define=ENABLE_APP_CHECK=true`, install **from Play** (a sideloaded build can
      never pass Play Integrity), and confirm **App Check → APIs → Firebase AI Logic** shows
      **verified** requests.
   5. Only once verified: set the API to **Enforced** and flip the default in `lib/services/ai_config.dart`
      back to `true`.

   ### ⚠️ Enabling enforcement is a BREAKING change for installed users

   Every build shipped with App Check off sends **no token**. The moment the API is set to Enforced,
   the server starts rejecting those requests — search breaks instantly for everyone who hasn't
   updated yet, and Play rollouts take days. Never flip enforcement as a single step.

   **Safe rollout order:**

   | # | Client | API | Effect |
   | - | --- | --- | --- |
   | 1 | App Check **off** | Unenforced | Works for everyone. Ship this first. |
   | 2 | App Check **on** (`--dart-define=ENABLE_APP_CHECK=true`) | Unenforced | Tokens start flowing. **If attestation is still broken, nobody notices** — this is the free trial run. |
   | 3 | — | Unenforced | Watch **App Check → APIs → Firebase AI Logic**. Wait for *verified* requests to dominate as users update. |
   | 4 | App Check **on** | **Enforced** | Only now. Users still on step-1 builds will break, but by now they're a small tail. |

   Step 2 is the one that's easy to skip and the one that makes this safe: it proves attestation works
   against real users, on real devices, installed from Play, with zero blast radius if it doesn't.
   - **Release:** register **Play Integrity** for the Android app and add your app’s **SHA-256**
     fingerprints — both your upload key and the **Google Play App Signing** key (Play Console → Setup →
     App signing). The app already uses Play Integrity in release builds.
   - **Local testing:** the app already installs the App Check **debug provider** in debug builds. Run a
     debug build, find `Enter this debug secret into the allow list … : <token>` in logcat, then add it
     under **App Check → Apps → (your app) → ⋮ → Manage debug tokens.** Keep that token private — never
     commit it.
3. (Optional) Set a **budget alert** if you later move to the Vertex/Blaze backend.

> Sanity check: a debug build on a registered device should return AI results. A failure is almost always
> App Check — the debug token isn’t registered, or enforcement is on without a registered device/SHA-256.

## 2. RevenueCat (subscriptions) **[YOU]**

The code already uses RevenueCat; you just need the dashboard + key.

1. Create the app in <https://app.revenuecat.com>, linked to Google Play (upload a Play service-account
   JSON so RevenueCat can validate purchases).
2. Create the two products **in Play Console first** (see §3), then add them in RevenueCat.
   - The code expects product IDs **`context_monthly_sub`** and **`context_yearly_sub`**
     (see `lib/services/subscription_service.dart`) and an **entitlement named `pro_fluency`**.
   - Create an **Offering** whose packages map to those products (the paywall reads
     `offerings.current.monthly` / `.annual` style packages via `products`).
3. Copy the **Android (public) API key** (`goog_…`) and pass it at build time (§6).
4. Confirm the entitlement identifier in the dashboard is exactly **`pro_fluency`** (that string is
   hard-coded as the premium check).

## 3. Google Play Console — products & app setup **[YOU]**

1. Create the app (package **`com.context.dictv1`**), complete the store listing (title, short/full
   description, screenshots, feature graphic, icon).
2. **Subscriptions:** create `context_monthly_sub` (monthly) and `context_yearly_sub` (annual)
   subscriptions with prices in each market.
3. **AdMob:** ✅ already wired in code (App ID + real rewarded unit). Just **link the AdMob app to the
   Play listing** once published (AdMob → App settings → link), and complete app-ads.txt if you use it.

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
# AdMob is baked in. Add the RevenueCat key once you have it (until then,
# premium simply stays locked — the rest of the app works):
flutter build appbundle --release \
  --dart-define=REVENUECAT_API_KEY=goog_XXXXXXXXXXXX
```
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
  search bubble; `POST_NOTIFICATIONS`/`RECEIVE_BOOT_COMPLETED` → the daily “Word of the Day” reminder
  and rescheduling after reboot. (`SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` were removed — the reminder
  now uses inexact scheduling, since exact-alarm eligibility requires the app's core function to be an
  alarm clock or calendar, which this app isn't.)
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
| AdMob rewarded unit ID | ✅ real ID baked in (release), test unit in debug |
| AdMob App ID in manifest | ✅ real App ID set |
| No privacy policy / terms | ✅ drafted — **[YOU]** host + fill `[CONFIRM]` |
| No in-app support contact | ✅ added (Settings → Contact Support) |
| Firebase config real values | ✅ wired (project `com-context-dict-v1`) — **[YOU]** enable Gemini Developer API (free) + App Check |
| RevenueCat dashboard/products/key | ⚠️ **[YOU]** set up + supply key |
| Ad consent (UMP) for EEA | ✅ implemented — **[YOU]** publish a GDPR message in AdMob |

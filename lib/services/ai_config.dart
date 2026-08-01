/// Single source of truth for the Gemini model used across the app
/// (main search + the overlay). Change it here to update everywhere.
///
/// `gemini-2.5-flash` was retired for new projects ("no longer available to new
/// users"), so we use `gemini-3.5-flash` (the model shown in the current
/// Firebase AI Logic docs). If a lookup ever fails with a "model not found" or
/// "no longer available" error, update this to a model your Firebase console
/// currently lists.
const String kGeminiModel = 'gemini-3.5-flash';

/// Whether the client activates App Check at startup.
///
/// ⚠️ DEFAULTS TO **FALSE** — deliberately, and temporarily. Re-enable it (and
/// delete this note) once attestation is verified working. See PUBLISHING.md.
///
/// Why off: activating App Check makes the AI call fail *client side* during
/// token fetch when attestation doesn't succeed — the SDK throws before the
/// request ever leaves the device. Crucially, setting the API to UNENFORCED in
/// the Firebase console does NOT prevent this: "unenforced" governs how the
/// *server* treats an unverified request, not whether the client SDK throws.
///
/// So while the API is unenforced, leaving this ON buys no protection at all
/// (every request is accepted either way) while being a hard dependency that
/// breaks search for 100% of users. A default that bricks the core feature is
/// worse than one that's merely less locked down.
///
/// To turn it back on, in order:
///   1. Firebase console → App Check → Apps → register `com.context.dictv1`
///      for Play Integrity (the old `com.context.dict.v1` entry is a DIFFERENT
///      app — registering that one does nothing for this build).
///   2. Add the **Play App Signing** SHA-256 (Play Console → Test and release
///      → Setup → App signing). Play re-signs the AAB with its own key, so the
///      upload key's fingerprint alone is not enough.
///   3. Google Cloud console → enable the **Play Integrity API** on the project.
///   4. Ship a build with `--dart-define=ENABLE_APP_CHECK=true`, install it
///      FROM PLAY, and confirm App Check → APIs → Firebase AI Logic shows
///      *verified* requests.
///   5. Only then set the API to Enforced, and flip this default back to true.
const bool kAppCheckEnabled =
    bool.fromEnvironment('ENABLE_APP_CHECK', defaultValue: false);

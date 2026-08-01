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
/// App Check protects the Firebase AI backend, and production builds installed
/// from Google Play must keep it ON. But note it can fail the AI call *client
/// side* (during token fetch) even when the API is set to UNENFORCED in the
/// console — "unenforced" governs the server, not the SDK throwing locally.
/// So when diagnosing a failing lookup, this is the switch that isolates it:
///   --dart-define=ENABLE_APP_CHECK=false
const bool kAppCheckEnabled =
    bool.fromEnvironment('ENABLE_APP_CHECK', defaultValue: true);

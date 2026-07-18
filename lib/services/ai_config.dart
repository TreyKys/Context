/// Single source of truth for the Gemini model used across the app
/// (main search + the overlay). Change it here to update everywhere.
///
/// `gemini-2.5-flash` was retired for new projects ("no longer available to new
/// users"), so we use `gemini-3.5-flash` (the model shown in the current
/// Firebase AI Logic docs). If a lookup ever fails with a "model not found" or
/// "no longer available" error, update this to a model your Firebase console
/// currently lists.
const String kGeminiModel = 'gemini-3.5-flash';

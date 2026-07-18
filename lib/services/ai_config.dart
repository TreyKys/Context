/// Single source of truth for the Gemini model used across the app
/// (main search + the overlay). Change it here to update everywhere.
///
/// Match this to a model your Firebase AI Logic project offers. The current
/// Firebase docs example uses `gemini-3.5-flash`; this app was built and tested
/// on `gemini-2.5-flash`. If a lookup fails with a "model not found" error,
/// switch this string to the model shown in your Firebase console.
const String kGeminiModel = 'gemini-2.5-flash';

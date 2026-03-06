
# Flutter-specific rules.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.embedding.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Rules for Google AI Generative SDK and its dependencies
-keep class com.google.ai.client.generativeai.** { *; }
-keep class com.google.android.gms.tflite.** { *; }
-keep class org.tensorflow.** { *; }

# Rules for Google Mobile Ads and Play Services (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-dontwarn com.google.android.gms.internal.ads.**
-dontwarn com.google.ads.**

# Rules for other essential plugins
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# Protect AndroidX/Core Libraries
-keep class androidx.core.** { *; }
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.**

# Keep model classes (important for JSON serialization/deserialization)
-keep public class * extends java.lang.Object {
    public <init>();
}

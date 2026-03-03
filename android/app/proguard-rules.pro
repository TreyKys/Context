
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

# Keep model classes (important for JSON serialization/deserialization)
-keep public class * extends java.lang.Object {
    public <init>();
}

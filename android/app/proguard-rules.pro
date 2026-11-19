# SHUCHONA Release R8 / ProGuard Keep Rules

# Keep flutter_local_notifications classes & Gson serialization models
-keep class com.dexterous.** { *; }
-keepclassmembers class com.dexterous.** { *; }

# Keep Gson generic type metadata for scheduled notification persistence
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Keep speech_to_text and flutter_tts JNI / Android service callbacks
-keep class com.csdcorp.speech_to_text.** { *; }
-keep class com.tundralabs.fluttertts.** { *; }

# Avoid benign R8 warnings from optional Firebase / Play Services reflection
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.**


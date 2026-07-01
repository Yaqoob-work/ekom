# VLC Player
-keep class org.videolan.libvlc.** { *; }
-keep class org.videolan.vlc.** { *; }

# Flutter InAppWebView
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }

# Flutter engine & plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# HTTP / networking
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep generic signatures (Dart/Flutter needs these)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Enum fix for older Android versions
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

package com.example.mobi_tv_entertainment

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.volume"
    private var volumeReceiver: BroadcastReceiver? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        installVlcCrashGuard()
        super.onCreate(savedInstanceState)
    }

    // 🛡️ Known upstream bug guard: flutter_vlc_player ke andar libvlc ka
    // "AWindowHandler" background thread kabhi-kabhi rapid channel-switching
    // ke dauraan SurfaceTexture.detachFromGLContext() se RuntimeException
    // throw karta hai (GL/EGL surface race condition). Yeh ek known,
    // abhi tak upstream fix na hua bug hai (flutter_vlc_player GitHub
    // issues #448, #478) — humare app code ka bug nahi hai. Hum sirf is
    // EK specific harmless exception ko silently swallow karte hain taaki
    // poora app crash na ho; har doosri exception normal hi crash karegi
    // (taaki asli bugs chhup na jayein).
    //
    // NOTE: Yeh guard sirf RELEASE (non-debuggable) build mein kaam karta
    // hai. Debug build (`flutter run`) mein Android ka CheckJNI safety
    // mechanism is exception ko Java handler tak pahunchne se PEHLE hi
    // hard native abort (SIGABRT) kar deta hai, jisse yeh handler bypass
    // ho jaata hai — isliye iska asar sirf release APK testing mein
    // dikhega, debug mode mein nahi.
    private fun installVlcCrashGuard() {
        val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            if (isKnownHarmlessVlcGlException(thread, throwable)) {
                Log.w(
                    "VlcCrashGuard",
                    "Swallowed known-harmless VLC AWindowHandler/detachFromGLContext exception on thread '${thread.name}': ${throwable.message}"
                )
                // Is background thread ko khatam hone dete hain, poore app
                // ko crash nahi karte.
                return@setDefaultUncaughtExceptionHandler
            }
            defaultHandler?.uncaughtException(thread, throwable)
        }
    }

    private fun isKnownHarmlessVlcGlException(thread: Thread, throwable: Throwable): Boolean {
        val threadName = thread.name ?: ""
        val message = throwable.message ?: ""
        val stack = throwable.stackTraceToString()

        val isAWindowThread = threadName.contains("AWindowHandler", ignoreCase = true)
        val isDetachFromGLContext =
            message.contains("detachFromGLContext", ignoreCase = true) ||
                stack.contains("detachFromGLContext", ignoreCase = true)
        val isFromVlc = stack.contains("org.videolan.libvlc", ignoreCase = true)

        return isAWindowThread && isDetachFromGLContext && isFromVlc
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the MethodChannel for communication with Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getVolume" -> {
                    // Fetch current volume
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC).toDouble()
                    val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC).toDouble()
                    val normalizedVolume = currentVolume / maxVolume
                    result.success(normalizedVolume) // Return normalized volume
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        registerVolumeReceiver() // Register volume listener when app is active
    }

    override fun onPause() {
        super.onPause()
        unregisterVolumeReceiver() // Unregister volume listener when app is paused
    }

    private fun registerVolumeReceiver() {
        volumeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action == "android.media.VOLUME_CHANGED_ACTION") {
                    val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                    val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    val normalizedVolume = currentVolume.toDouble() / maxVolume

                    // Notify Flutter about volume changes
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                        MethodChannel(messenger, CHANNEL).invokeMethod("volumeChanged", normalizedVolume)
                    }
                }
            }
        }
        val filter = IntentFilter("android.media.VOLUME_CHANGED_ACTION")
        registerReceiver(volumeReceiver, filter)
    }

    private fun unregisterVolumeReceiver() {
        volumeReceiver?.let {
            unregisterReceiver(it)
        }
        volumeReceiver = null
    }
}
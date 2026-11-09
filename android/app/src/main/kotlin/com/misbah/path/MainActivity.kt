package com.misbah.path
import android.content.ContentResolver
import android.content.Context
import android.media.RingtoneManager
import io.flutter.plugin.common.MethodChannel

import com.ryanheise.audioservice.AudioServiceActivity;

class MainActivity: AudioServiceActivity() {
    // No manual ONNX class pre-loading needed — the native lib conflict is
    // resolved at the Gradle packaging level via pickFirsts in build.gradle.kts.
}

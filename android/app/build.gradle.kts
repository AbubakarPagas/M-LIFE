import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
        localProperties.load(reader)
    }
}
// def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"
// if (flutterVersionCode == null) {
//     flutterVersionCode = '1'
// }

// def flutterVersionName = localProperties.getProperty('flutter.versionName')
// if (flutterVersionName == null) {
//     flutterVersionName = '1.0'
// }

// def keystoreProperties = new Properties()
// def keystorePropertiesFile = rootProject.file('key.properties')
// if (keystorePropertiesFile.exists()) {
//     keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
// }




android {
    namespace = "com.misbah.path"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.misbah.path"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        multiDexEnabled = true
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // sherpa_onnx ships its own libonnxruntime.so for each ABI (including x86_64).
    // flutter_onnxruntime pulls onnxruntime-android:1.28.0 from Maven, which also
    // unpacks libonnxruntime.so and libonnxruntime4j_jni.so into the APK.
    // Both cannot coexist — the JNI wrapper built for one will crash against the other.
    // pickFirsts keeps the first .so encountered (sherpa_onnx's bundled copy) and
    // silently drops the duplicate from the Maven AAR.
   // packaging {
    //    jniLibs {
    //        pickFirsts += setOf(
    //            "**/libonnxruntime.so",
    //            "**/libonnxruntime4j_jni.so",
    //        )
    //    }
   // }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // implementation("androidx.window:window:1.0.0")
    // implementation("androidx.window:window-java:1.0.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Explicitly declare onnxruntime-android so its libonnxruntime.so and
    // libonnxruntime4j_jni.so are packaged before sherpa_onnx's bundled copy.
    // Combined with pickFirsts above, this ensures the JNI wrapper and the
    // core runtime are always the same version (1.28.0), preventing the
    // "cannot locate symbol OrtGetApiBase" crash on x86_64 (emulator).
    // implementation("com.microsoft.onnxruntime:onnxruntime-android:1.28.0")
    testImplementation("junit:junit:4.12")
    androidTestImplementation("androidx.test:runner:1.2.0")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.2.0")
}

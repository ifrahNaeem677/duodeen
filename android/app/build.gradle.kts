// DuoDeen V3 — Android app build file (based on Flutter 3.50 template).
// `flutter create .` will NOT overwrite this file, so the fixes below always apply.
plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.duodeen.duodeen"
    // Flutter default (36). Do NOT lower to 34: flutter_local_notifications
    // and image_picker need compileSdk 36.
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // REQUIRED by flutter_local_notifications (fixes "requires core library desugaring")
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.duodeen.duodeen"
        // flutter_local_notifications 22 needs Android 7.0+ (API 24)
        minSdk = maxOf(24, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    // Fixes "Unexpected failure during lint analysis" (image_picker_android)
    lint {
        abortOnError = false
        checkReleaseBuilds = false
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so the APK installs directly.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // REQUIRED by flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

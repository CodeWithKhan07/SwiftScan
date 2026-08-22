import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

// Uses Google's official sample AdMob app ID until you provide your production ID
// in android/gradle.properties or with -PADMOB_APP_ID=....
val admobAppId = providers.gradleProperty("ADMOB_APP_ID")
    .orElse("ca-app-pub-3940256099942544~3347511713")
    .get()

android {
    namespace = "com.techydez.fatoralens"

    // google_mlkit_document_scanner currently requires API 35. Keep Flutter's
    // configured SDK when it is newer so this remains forward-compatible.
    compileSdk = maxOf(flutter.compileSdkVersion, 35)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // google-services.json must contain a Firebase Android client registered
        // with this exact production package name.
        applicationId = "com.techydez.fatoralens"
        minSdk = 26
        targetSdk = maxOf(flutter.targetSdkVersion, 35)
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["ADMOB_APP_ID"] = admobAppId
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        debug {
            // Debug builds intentionally use the sample AdMob application ID above.
            // Firebase App Check uses the debug provider from Dart code.
        }

        release {
            // Never sign production builds with the debug key. If key.properties
            // exists, the secure release signing config is applied automatically.
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }

            // Keep shrinking disabled until the complete native/plugin stack has
            // passed a release smoke test. Enable both together before final release.
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

dependencies {
    // local_auth requires an AppCompat-based launch theme on Android.
    implementation("androidx.appcompat:appcompat:1.7.1")

    // Do not duplicate Firebase, ML Kit, Ads, Billing, Camera, or Isar native
    // dependencies here. Their Flutter plugins own the compatible Android versions.
}

flutter {
    source = "../.."
}

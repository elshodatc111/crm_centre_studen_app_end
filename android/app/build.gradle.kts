plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "uz.codestart.crm_center_studen_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Unique Application ID (package name)
        applicationId = "uz.codestart.crm_center_studen_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Manifest uchun appName o'rnatish
        manifestPlaceholders["appName"] = "MyApp" // To'g'ridan-to'g'ri defaultConfig ichida o'rnatish
    }

    buildTypes {
        release {
            // Signing with debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Configure the Android-specific settings for dependencies or other parts
    buildFeatures {
        viewBinding = true // Enable view binding if necessary
    }

    packagingOptions {
        exclude("META-INF/*")  // Exclude unnecessary files to prevent conflicts
    }
}

flutter {
    source = "../.."  // Path to your Flutter project
}

// Make sure to declare dependencies in the "dependencies" block
dependencies {
    implementation("androidx.appcompat:appcompat:1.3.1")
    implementation("androidx.constraintlayout:constraintlayout:2.0.4")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.5.21")

    // If needed for permissions:
    implementation("com.google.android.material:material:1.4.0")
}

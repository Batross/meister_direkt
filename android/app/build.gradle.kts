// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.meisterdirekt"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // تم إضافة هذا السطر بناءً على الخطأ السابق

    defaultConfig {
        applicationId = "com.example.meisterdirekt"
        minSdk = 23 // تم رفع الحد الأدنى إلى 23 بناءً على متطلبات Firebase
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
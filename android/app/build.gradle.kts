import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    // 👇 TAMBAHKAN 1 BARIS INI 👇
    id("com.google.gms.google-services")
}

// 👇 1. BACA FILE KEY.PROPERTIES 👇
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.solher_mobile"
    // compileSdk = flutter.compileSdkVersion
    compileSdk = 36
    
    // 👇 Hapus pemanggilan flutter.ndkVersion dan gunakan tanda '=' 👇
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // kotlinOptions {
    //     jvmTarget = "17"
    // }

    // 👇 2. KONFIGURASI SIGNING UNTUK RILIS 👇
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID
        applicationId = "com.solher.mobile" // 👇 Ubah nama bundle ID ini jika perlu
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode()
        versionName = flutter.versionName()
    }

    buildTypes {
        release {
            // 👇 3. TERAPKAN KONFIGURASI SIGNING KE BUILD RELEASE 👇
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true  // Mengurangi ukuran APK/AAB dan menyembunyikan kode
            isShrinkResources = true // Menghapus aset yang tidak dipakai
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}
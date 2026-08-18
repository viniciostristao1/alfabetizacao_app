plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vinyapps.alfabetizacao"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.vinyapps.alfabetizacao"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Keystore de debug ESTÁVEL, versionado (`app/android/app/debug.keystore`),
        // com as credenciais padrão do Android debug (não são segredo). É o que
        // torna a assinatura IGUAL em todo build do CI — sem isso, cada runner gera
        // uma chave de debug aleatória e o Android recusa a atualização ("conflito
        // com pacote existente"). Para a Play Store, no futuro, trocar por uma
        // keystore de upload via secrets (ver AGENTS/IDEIAS).
        getByName("debug") {
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            // Assina o release com a MESMA chave (debug estável) → instala e
            // atualiza sem conflito de assinatura.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

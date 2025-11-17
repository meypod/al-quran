import com.android.build.gradle.api.ApplicationVariant
import com.android.build.gradle.api.BaseVariantOutput
import com.android.build.gradle.internal.api.ApkVariantOutputImpl

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.github.meypod.al_quran"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.github.meypod.al_quran"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all(ApplicationVariantAction())
}

flutter {
    source = "../.."
}

class ApplicationVariantAction : Action<ApplicationVariant> {
    override fun execute(variant: ApplicationVariant) {
        variant.outputs.all(VariantOutputAction(variant))
    }

    class VariantOutputAction(private val variant: ApplicationVariant) : Action<BaseVariantOutput> {
        override fun execute(output: BaseVariantOutput) {
            if (output is ApkVariantOutputImpl) {
                val abi =
                    output.getFilter(com.android.build.api.variant.FilterConfiguration.FilterType.ABI.name)
                val abiVersionCode =
                    when (abi) {
                        "armeabi-v7a" -> 1
                        "arm64-v8a" -> 2
                        "x86" -> 3
                        "x86_64" -> 4
                        else -> 0
                    }
                val versionCode = variant.versionCode * 1000 + abiVersionCode
                output.versionCodeOverride = versionCode

                val flavor = variant.flavorName
                val builtType = variant.buildType.name
                val versionName = variant.versionName
                val architecture = abi ?: "universal"

                output.outputFileName =
                    "AlQuran-${versionName}-${architecture}-${versionCode}--${builtType}.apk"
            }
        }
    }
}

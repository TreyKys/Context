buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// firebase_ai and firebase_app_check skip applying `kotlin-android` on AGP 9+
// assuming built-in Kotlin is enabled. While `android.builtInKotlin=false` is
// required for other plugins that still apply KGP, apply `kotlin-android` here
// and align its JVM target with their Java 17 compileOptions.
subprojects {
    if (name == "firebase_ai" || name == "firebase_app_check") {
        plugins.withId("com.android.library") {
            if (findProperty("android.builtInKotlin")?.toString() == "false" &&
                !plugins.hasPlugin("org.jetbrains.kotlin.android")
            ) {
                apply(plugin = "org.jetbrains.kotlin.android")
                tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
                    compilerOptions {
                        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

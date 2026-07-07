allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Relocate the build directory to the Flutter project's build folder
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Only relocate the build directory for subprojects inside the main project folder.
    // This avoids "different roots" errors when plugins are on a different drive (e.g. C: vs D:).
    if (project.projectDir.absolutePath.startsWith(rootProject.rootDir.absolutePath)) {
        project.layout.buildDirectory.value(newBuildDir.dir(project.name))
    }
}

// Force all subprojects (plugins) to use compileSdk 36 to resolve AAR metadata conflicts
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            // Use property access or method call to set compileSdk to 36
            try {
                (android as? com.android.build.gradle.BaseExtension)?.compileSdkVersion(36)
            } catch (e: Exception) {
                // Fallback for newer AGP versions if the above cast fails
                project.extensions.configure<com.android.build.api.dsl.CommonExtension<*, *, *, *, *, *>>("android") {
                    compileSdk = 36
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

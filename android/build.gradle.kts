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
            // Use the older DSL approach since android.newDsl=false
            if (android is com.android.build.gradle.BaseExtension) {
                android.compileSdkVersion(36)
            } else {
                // For newer plugin versions that use different interfaces
                try {
                    val method = android.javaClass.methods.find {
                        it.name == "setCompileSdk" || it.name == "compileSdkVersion"
                    }
                    if (method != null) {
                        when {
                            method.name == "setCompileSdk" && method.parameterCount == 1 ->
                                method.invoke(android, 36)
                            method.name == "compileSdkVersion" && method.parameterCount == 1 ->
                                method.invoke(android, 36)
                        }
                    }
                } catch (e: Exception) {
                    println("Warning: Could not set compileSdk for project ${project.name}: ${e.message}")
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

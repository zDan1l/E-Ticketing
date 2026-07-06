allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Only relocate the build directory for subprojects inside the main project folder.
    // This avoids "different roots" errors when plugins are on a different drive (e.g. C: vs D:).
    if (project.projectDir.absolutePath.startsWith(rootProject.rootDir.absolutePath)) {
        project.layout.buildDirectory.value(newBuildDir.dir(project.name))
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

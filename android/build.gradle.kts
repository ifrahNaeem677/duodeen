// DuoDeen V3 — root Android build file (Flutter 3.50 template + lint fix).
// `flutter create .` will NOT overwrite this file.
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

// Lint fix for plugin modules (e.g. image_picker_android):
// never fail the build because of lint.
subprojects {
    plugins.withId("com.android.library") {
        try {
            extensions.findByName("android")?.withGroovyBuilder {
                "lint" {
                    "setAbortOnError"(false)
                    "setCheckReleaseBuilds"(false)
                }
            }
        } catch (e: Exception) {
            logger.warn("DuoDeen: could not set lint options for ${project.name}: ${e.message}")
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

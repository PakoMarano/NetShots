allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Force compatible androidx versions
// Keep AndroidX deps on versions compatible with AGP 8.7.3.
subprojects {
    configurations.configureEach {
        resolutionStrategy {
            force(
                "androidx.core:core:1.13.1",
                "androidx.core:core-ktx:1.13.1",
                "androidx.browser:browser:1.8.0",
            )

            // Downgrade newer androidx.* that demand AGP 8.9+.
            eachDependency {
                if (requested.group == "androidx.core" && requested.name == "core" && requested.version != null) {
                    useVersion("1.13.1")
                    because("androidx.core 1.17.0+ requires AGP 8.9+")
                }
                if (requested.group == "androidx.core" && requested.name == "core-ktx" && requested.version != null) {
                    useVersion("1.13.1")
                    because("androidx.core-ktx 1.17.0+ requires AGP 8.9+")
                }
                if (requested.group == "androidx.browser" && requested.name == "browser" && requested.version != null) {
                    useVersion("1.8.0")
                    because("androidx.browser 1.9.0+ requires AGP 8.9+")
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

import com.android.build.gradle.LibraryExtension

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

subprojects {
    pluginManager.withPlugin("com.android.library") {
        try {
            val lib = extensions.findByType(LibraryExtension::class.java)
            if (lib != null) {
                val current = lib.namespace
                if (current == null || current.isBlank()) {
                    lib.namespace = "dev.sisasaku.${project.name.replace('-', '_')}"
                }
            }
        } catch (e: Exception) {
            // ignore - best-effort only
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

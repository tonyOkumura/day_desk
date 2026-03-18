import com.android.build.api.dsl.LibraryExtension
import com.android.build.api.variant.LibraryAndroidComponentsExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

fun manifestPackageName(project: Project): String? {
    val manifestFile = project.file("src/main/AndroidManifest.xml")
    if (!manifestFile.exists()) {
        return null
    }

    return Regex("""package\s*=\s*"([^"]+)"""")
        .find(manifestFile.readText())
        ?.groupValues
        ?.getOrNull(1)
        ?.takeIf(String::isNotBlank)
}

fun configureLegacyAndroidLibraryModule(target: LibraryExtension, namespace: String) {
    if (target.namespace.isNullOrBlank()) {
        target.namespace = namespace
    }
    target.compileSdk = 35
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
    plugins.withId("com.android.library") {
        if (name != "isar_flutter_libs") {
            return@withId
        }

        val manifestPackage = manifestPackageName(project) ?: return@withId
        val androidExtension = extensions.getByType(LibraryExtension::class.java)
        val androidComponents =
            extensions.getByType(LibraryAndroidComponentsExtension::class.java)

        if (androidExtension.namespace.isNullOrBlank()) {
            androidExtension.namespace = manifestPackage
        }

        androidComponents.finalizeDsl { extension ->
            configureLegacyAndroidLibraryModule(extension, manifestPackage)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

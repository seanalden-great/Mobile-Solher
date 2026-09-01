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
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt is com.android.build.gradle.BaseExtension) {
                if (androidExt.namespace == null) {
                    androidExt.namespace = project.group.toString()
                }
            }
        }
    }
}

// Script pembersih otomatis untuk package usang yang bertentangan dengan AGP 8+
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val manifestFile = file("${project.projectDir}/src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val manifestContent = manifestFile.readText()
                if (manifestContent.contains("package=\"")) {
                    println("⚙️ Membersihkan attribute package usang di: ${project.name}")
                    val cleanedContent = manifestContent.replace(Regex("package=\"[^\"]*\""), "")
                    manifestFile.writeText(cleanedContent)
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

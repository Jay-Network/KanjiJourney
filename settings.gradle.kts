pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    @Suppress("UnstableApiUsage")
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "KanjiJourney"

include(":shared-japanese")
include(":shared-tokenizer")
include(":shared-core")
include(":android-app")
include(":data-pipeline")

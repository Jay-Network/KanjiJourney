package com.jworks.kanjijourney.core.domain.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

data class Kanji(
    val id: Int,
    val literal: String,
    val grade: Int?,
    val jlptLevel: Int?,
    val frequency: Int?,
    val strokeCount: Int,
    val meaningsEn: List<String>,
    val onReadings: List<String>,
    val kunReadings: List<String>,
    val strokeSvg: String?
) {
    val unicodeHex: String get() = "U+" + id.toString(16).uppercase().padStart(4, '0')

    val primaryMeaning: String get() = meaningsEn.firstOrNull() ?: ""

    val primaryOnReading: String get() = onReadings.firstOrNull() ?: ""

    val primaryKunReading: String get() = kunReadings.firstOrNull() ?: ""

    val jlptLabel: String? get() = jlptLevel?.let { "N$it" }

    val gradeLabel: String?
        get() = when (grade) {
            in 1..6 -> "Grade $grade"
            8 -> "Junior High"
            else -> null
        }

    /**
     * Kanken (漢検) level derived from school grade.
     * Grade 1→Kanken 10, Grade 2→9, ..., Grade 6→5, Grade 8 (junior high)→4.
     * Returns null for kanji without a grade assignment.
     */
    val kankenLevel: Int?
        get() = when (grade) {
            1 -> 10
            2 -> 9
            3 -> 8
            4 -> 7
            5 -> 6
            6 -> 5
            8 -> 4
            else -> null
        }

    val kankenLabel: String?
        get() = kankenLevel?.let { "漢検$it 級" }
}

internal val json = Json { ignoreUnknownKeys = true }

fun parseJsonStringArray(jsonStr: String): List<String> {
    return try {
        json.decodeFromString<List<String>>(jsonStr)
    } catch (_: Exception) {
        emptyList()
    }
}

package com.jworks.kanjijourney.core.domain.model

data class ReceivedKanji(
    val id: Long,
    val kanjiLiteral: String,
    val kanjiId: Int?,
    val sourceApp: String,
    val receivedAt: Long,
    val processedAt: Long?,
    val status: ReceivedKanjiStatus
)

enum class ReceivedKanjiStatus {
    PENDING, PROCESSED, FAILED;

    companion object {
        fun fromString(value: String): ReceivedKanjiStatus = when (value) {
            "processed" -> PROCESSED
            "failed" -> FAILED
            else -> PENDING
        }
    }

    fun toDbString(): String = name.lowercase()
}

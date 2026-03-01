package com.jworks.kanjijourney.core.domain.model

data class FlashcardEntry(
    val deckId: Long = 1,
    val kanjiId: Int,
    val addedAt: String,
    val lastStudiedAt: String?,
    val studyCount: Int,
    val notes: String?
)

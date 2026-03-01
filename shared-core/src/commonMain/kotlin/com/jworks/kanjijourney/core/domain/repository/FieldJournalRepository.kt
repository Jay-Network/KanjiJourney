package com.jworks.kanjijourney.core.domain.repository

import com.jworks.kanjijourney.core.domain.model.FieldJournalEntry

interface FieldJournalRepository {
    suspend fun getAll(): List<FieldJournalEntry>
    suspend fun getById(id: Long): FieldJournalEntry?
    suspend fun getRecent(limit: Int): List<FieldJournalEntry>
    suspend fun countAll(): Long
    suspend fun totalKanjiCaught(): Long
    suspend fun insert(imagePath: String, locationLabel: String, kanjiFound: List<String>, capturedAt: Long): Long
    suspend fun delete(id: Long)
}

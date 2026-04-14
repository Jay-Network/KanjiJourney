package com.jworks.kanjijourney.core.domain.repository

import com.jworks.kanjijourney.core.domain.model.ReceivedKanji

interface ReceivedKanjiRepository {
    suspend fun getPending(): List<ReceivedKanji>
    suspend fun getAll(): List<ReceivedKanji>
    suspend fun insert(kanjiLiteral: String, kanjiId: Int?, sourceApp: String, receivedAt: Long)
    suspend fun markProcessed(id: Long, kanjiId: Int, processedAt: Long)
    suspend fun markFailed(id: Long)
    suspend fun countPending(): Long
}

package com.jworks.kanjijourney.core.data

import com.jworks.kanjijourney.core.domain.model.ReceivedKanji
import com.jworks.kanjijourney.core.domain.model.ReceivedKanjiStatus
import com.jworks.kanjijourney.core.domain.repository.ReceivedKanjiRepository
import com.jworks.kanjijourney.db.KanjiJourneyDatabase

class ReceivedKanjiRepositoryImpl(
    private val db: KanjiJourneyDatabase
) : ReceivedKanjiRepository {

    override suspend fun getPending(): List<ReceivedKanji> {
        return db.receivedKanjiQueries.getPending().executeAsList().map { it.toModel() }
    }

    override suspend fun getAll(): List<ReceivedKanji> {
        return db.receivedKanjiQueries.getAll().executeAsList().map { it.toModel() }
    }

    override suspend fun insert(kanjiLiteral: String, kanjiId: Int?, sourceApp: String, receivedAt: Long) {
        db.receivedKanjiQueries.insert(
            kanji_literal = kanjiLiteral,
            kanji_id = kanjiId?.toLong(),
            source_app = sourceApp,
            received_at = receivedAt
        )
    }

    override suspend fun markProcessed(id: Long, kanjiId: Int, processedAt: Long) {
        db.receivedKanjiQueries.markProcessed(
            processed_at = processedAt,
            kanji_id = kanjiId.toLong(),
            id = id
        )
    }

    override suspend fun markFailed(id: Long) {
        db.receivedKanjiQueries.markFailed(id)
    }

    override suspend fun countPending(): Long {
        return db.receivedKanjiQueries.countPending().executeAsOne()
    }

    private fun com.jworks.kanjijourney.db.Received_kanji.toModel(): ReceivedKanji {
        return ReceivedKanji(
            id = id,
            kanjiLiteral = kanji_literal,
            kanjiId = kanji_id?.toInt(),
            sourceApp = source_app,
            receivedAt = received_at,
            processedAt = processed_at,
            status = ReceivedKanjiStatus.fromString(status)
        )
    }
}

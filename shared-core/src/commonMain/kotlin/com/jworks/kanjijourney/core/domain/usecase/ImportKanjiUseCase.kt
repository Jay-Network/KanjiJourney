package com.jworks.kanjijourney.core.domain.usecase

import com.jworks.kanjijourney.core.domain.model.ReceivedKanji
import com.jworks.kanjijourney.core.domain.repository.FlashcardRepository
import com.jworks.kanjijourney.core.domain.repository.KanjiRepository
import com.jworks.kanjijourney.core.domain.repository.ReceivedKanjiRepository
import com.jworks.kanjijourney.core.domain.repository.SrsRepository
import kotlinx.datetime.Clock

data class ImportResult(
    val imported: Int,
    val alreadyKnown: Int,
    val notFound: Int
)

class ImportKanjiUseCase(
    private val receivedKanjiRepository: ReceivedKanjiRepository,
    private val kanjiRepository: KanjiRepository,
    private val srsRepository: SrsRepository,
    private val flashcardRepository: FlashcardRepository
) {
    /**
     * Receive kanji literals from an external app (e.g. KanjiSage scan).
     * Inserts them as pending received_kanji rows.
     */
    suspend fun receiveKanji(literals: List<String>, sourceApp: String = "kanjisage") {
        val now = Clock.System.now().toEpochMilliseconds()
        for (literal in literals) {
            val kanji = kanjiRepository.getKanjiByLiteral(literal)
            receivedKanjiRepository.insert(
                kanjiLiteral = literal,
                kanjiId = kanji?.id,
                sourceApp = sourceApp,
                receivedAt = now
            )
        }
    }

    /**
     * Process all pending received kanji:
     * - Look up kanji in local database
     * - Create SRS card (ensures learning begins)
     * - Add to default flashcard deck
     */
    suspend fun processPending(): ImportResult {
        val pending = receivedKanjiRepository.getPending()
        val now = Clock.System.now().toEpochMilliseconds()
        var imported = 0
        var alreadyKnown = 0
        var notFound = 0

        flashcardRepository.ensureDefaultDeck()

        for (received in pending) {
            val kanji = kanjiRepository.getKanjiByLiteral(received.kanjiLiteral)
            if (kanji == null) {
                receivedKanjiRepository.markFailed(received.id)
                notFound++
                continue
            }

            val existingCard = srsRepository.getCard(kanji.id)
            if (existingCard != null) {
                // Already in study system — mark as processed but count as known
                receivedKanjiRepository.markProcessed(received.id, kanji.id, now)
                alreadyKnown++
                continue
            }

            // Create SRS card for this kanji
            srsRepository.ensureCardExists(kanji.id)

            // Add to default flashcard deck (deck_id = 1)
            if (!flashcardRepository.isInDeck(kanjiId = kanji.id)) {
                flashcardRepository.addToDeck(kanjiId = kanji.id)
            }

            receivedKanjiRepository.markProcessed(received.id, kanji.id, now)
            imported++
        }

        return ImportResult(imported = imported, alreadyKnown = alreadyKnown, notFound = notFound)
    }
}

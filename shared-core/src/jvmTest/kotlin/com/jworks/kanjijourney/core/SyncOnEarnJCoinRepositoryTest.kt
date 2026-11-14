package com.jworks.kanjijourney.core

import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import com.jworks.kanjijourney.core.data.JCoinRepositoryImpl
import com.jworks.kanjijourney.core.data.SyncOnEarnJCoinRepository
import com.jworks.kanjijourney.core.domain.model.LOCAL_USER_ID
import com.jworks.kanjijourney.core.domain.repository.JCoinRepository
import com.jworks.kanjijourney.db.KanjiJourneyDatabase
import kotlinx.coroutines.delay
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals

/**
 * Earns are sent a moment after they are made, while the app is open (BUG-023): one sync per burst
 * of earns, and a sync that has started is never cancelled by a later earn.
 */
class SyncOnEarnJCoinRepositoryTest {

    /** Real repository on an in-memory database; counts syncs, each taking 500 ms. */
    private class CountingRepo(
        real: JCoinRepository,
        private val fail: Boolean = false
    ) : JCoinRepository by real {
        var started = 0
        var finished = 0
        override suspend fun syncPendingEvents(): Int {
            started++
            delay(500)
            if (fail) throw IllegalStateException("server down")
            finished++
            return 0
        }
    }

    private fun realRepo(): JCoinRepository {
        val driver = JdbcSqliteDriver(JdbcSqliteDriver.IN_MEMORY)
        KanjiJourneyDatabase.Schema.create(driver)
        return JCoinRepositoryImpl(KanjiJourneyDatabase(driver))
    }

    @Test
    fun earnsCloseTogether_oneSyncAfterThePause() = runTest {
        val counting = CountingRepo(realRepo())
        val repo = SyncOnEarnJCoinRepository(counting, backgroundScope, delayMillis = 2_000)

        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 5, "one")
        advanceTimeBy(1_000)
        repo.earnCoins(LOCAL_USER_ID, "perfect_quiz", 25, "two")
        advanceTimeBy(1_999)
        runCurrent()
        assertEquals(0, counting.started, "no sync before the pause after the last earn")

        advanceTimeBy(2)
        runCurrent()
        assertEquals(1, counting.started)
        advanceTimeBy(600)
        assertEquals(1, counting.finished)
        // Both earns were recorded by the real repository
        assertEquals(30L, repo.getBalance(LOCAL_USER_ID).localBalance)
    }

    @Test
    fun earnDuringARunningSync_doesNotCancelIt() = runTest {
        val counting = CountingRepo(realRepo())
        val repo = SyncOnEarnJCoinRepository(counting, backgroundScope, delayMillis = 2_000)

        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 5, "one")
        advanceTimeBy(2_100) // first sync is now running (it takes 500 ms)
        runCurrent()
        assertEquals(1, counting.started)

        repo.earnCoins(LOCAL_USER_ID, "perfect_quiz", 25, "two")
        advanceTimeBy(600)
        assertEquals(1, counting.finished, "the running sync finished despite the later earn")

        advanceTimeBy(2_000)
        assertEquals(2, counting.finished, "the later earn got its own sync")
    }

    @Test
    fun syncSoon_withoutAnEarn_runsOneSync() = runTest {
        val counting = CountingRepo(realRepo())
        val repo = SyncOnEarnJCoinRepository(counting, backgroundScope, delayMillis = 2_000)

        repo.syncSoon()
        advanceTimeBy(2_600)

        assertEquals(1, counting.finished)
    }

    @Test
    fun failingSync_doesNotReachTheCaller() = runTest {
        val counting = CountingRepo(realRepo(), fail = true)
        val repo = SyncOnEarnJCoinRepository(counting, backgroundScope, delayMillis = 2_000)

        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 5, "one")
        advanceTimeBy(2_600)

        assertEquals(1, counting.started)
        assertEquals(0, counting.finished)
        // The scope survived: a later sync still runs
        repo.syncSoon()
        advanceTimeBy(2_600)
        assertEquals(2, counting.started)
    }
}

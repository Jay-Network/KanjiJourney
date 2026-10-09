package com.jworks.kanjijourney.core

import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import com.jworks.kanjijourney.core.data.JCoinRepositoryImpl
import com.jworks.kanjijourney.core.data.withOneTransportRetry
import com.jworks.kanjijourney.core.domain.model.CoinTier
import io.ktor.client.plugins.HttpRequestTimeoutException
import kotlin.test.assertFailsWith
import com.jworks.kanjijourney.core.domain.model.LOCAL_USER_ID
import com.jworks.kanjijourney.db.KanjiJourneyDatabase
import kotlinx.coroutines.test.runTest
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class JCoinRepositoryTest {

    private fun createTestDb(): KanjiJourneyDatabase {
        val driver = JdbcSqliteDriver(JdbcSqliteDriver.IN_MEMORY)
        KanjiJourneyDatabase.Schema.create(driver)
        return KanjiJourneyDatabase(driver)
    }

    private fun createRepo(db: KanjiJourneyDatabase = createTestDb()): JCoinRepositoryImpl {
        val fixedClock = object : Clock {
            override fun now() = Instant.fromEpochSeconds(1700000000L)
        }
        return JCoinRepositoryImpl(db, fixedClock)
    }

    @Test
    fun getBalance_initiallyEmpty() = runTest {
        val repo = createRepo()
        val balance = repo.getBalance(LOCAL_USER_ID)
        assertEquals(0L, balance.localBalance)
        assertEquals(0L, balance.lifetimeEarned)
        assertEquals(CoinTier.BRONZE, balance.tier)
        assertFalse(balance.needsSync)
    }

    @Test
    fun earnCoins_updatesBalance() = runTest {
        val repo = createRepo()
        val result = repo.earnCoins(
            userId = LOCAL_USER_ID,
            sourceType = "srs_review_complete",
            baseAmount = 10,
            description = "Test earn"
        )
        assertEquals(10, result.earned)
        assertEquals(10L, result.newBalance)
        assertTrue(result.queued)

        val balance = repo.getBalance(LOCAL_USER_ID)
        assertEquals(10L, balance.localBalance)
        assertEquals(10L, balance.lifetimeEarned)
        assertTrue(balance.needsSync)
    }

    @Test
    fun earnCoins_accumulatesBalance() = runTest {
        val repo = createRepo()
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 10, "Session 1")
        repo.earnCoins(LOCAL_USER_ID, "perfect_quiz", 25, "Perfect score")
        repo.earnCoins(LOCAL_USER_ID, "streak_7_days", 50, "7-day streak")

        val balance = repo.getBalance(LOCAL_USER_ID)
        assertEquals(85L, balance.localBalance)
        assertEquals(85L, balance.lifetimeEarned)
    }

    @Test
    fun earnCoins_queuesSyncEvents() = runTest {
        val repo = createRepo()
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 10, "Session 1")
        repo.earnCoins(LOCAL_USER_ID, "perfect_quiz", 25, "Perfect score")

        val pending = repo.getPendingSyncCount()
        assertEquals(2L, pending)
    }

    @Test
    fun earnCoins_persistsNonBlankClientEventId() = runTest {
        val db = createTestDb()
        val repo = createRepo(db)
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 10, "Session 1")

        val queued = db.jCoinQueries.getPendingEvents().executeAsList().single()
        assertTrue(queued.client_event_id?.isNotBlank() == true)
    }

    @Test
    fun earnCoins_distinctEarns_getDistinctClientEventIds() = runTest {
        // jworks:35 (2026-09-27): the server dedups on this key, so two DIFFERENT earns must
        // never collide - only a genuine retry of the SAME queued row may reuse one.
        val db = createTestDb()
        val repo = createRepo(db)
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 10, "Session 1")
        repo.earnCoins(LOCAL_USER_ID, "perfect_quiz", 25, "Perfect score")

        val ids = db.jCoinQueries.getPendingEvents().executeAsList().map { it.client_event_id }
        assertEquals(2, ids.toSet().size)
    }

    @Test
    fun earnCoins_clientEventIdSurvivesRetry_untilRowIsDeleted() = runTest {
        // The key must stay stable for as long as the row is queued/retried - it is read back
        // from the persisted row at sync time, never regenerated per send attempt.
        val db = createTestDb()
        val repo = createRepo(db)
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 10, "Session 1")

        val firstRead = db.jCoinQueries.getPendingEvents().executeAsList().single().client_event_id
        val secondRead = db.jCoinQueries.getPendingEvents().executeAsList().single().client_event_id
        assertEquals(firstRead, secondRead)
    }

    @Test
    fun transportRetry_timeoutThenSuccess_returnsSecondAttempt() = runTest {
        var calls = 0
        val result = withOneTransportRetry {
            calls++
            if (calls == 1) throw HttpRequestTimeoutException("https://j-coin.test/earn", 10_000L)
            "ok"
        }
        assertEquals("ok", result)
        assertEquals(2, calls)
    }

    @Test
    fun transportRetry_retriesOnlyOnce() = runTest {
        var calls = 0
        assertFailsWith<HttpRequestTimeoutException> {
            withOneTransportRetry<String> {
                calls++
                throw HttpRequestTimeoutException("https://j-coin.test/earn", 10_000L)
            }
        }
        assertEquals(2, calls)
    }

    @Test
    fun transportRetry_nonTransportError_notRetried() = runTest {
        var calls = 0
        assertFailsWith<IllegalStateException> {
            withOneTransportRetry<String> {
                calls++
                throw IllegalStateException("server answered")
            }
        }
        assertEquals(1, calls)
    }

    @Test
    fun getSyncStatus_reflectsPendingEvents() = runTest {
        val repo = createRepo()
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 10, "Session 1")
        repo.earnCoins(LOCAL_USER_ID, "daily_goal_met", 15, "Daily goal")

        val status = repo.getSyncStatus()
        assertEquals(2, status.pendingCount)
        assertEquals(0, status.syncedCount)
        assertEquals(0, status.failedCount)
    }

    @Test
    fun isPremiumUnlocked_falseByDefault() = runTest {
        val repo = createRepo()
        assertFalse(repo.isPremiumUnlocked(LOCAL_USER_ID, "theme", "sakura"))
    }

    @Test
    fun earnCoins_resultContainsSourceType() = runTest {
        val repo = createRepo()
        val result = repo.earnCoins(
            userId = LOCAL_USER_ID,
            sourceType = "streak_30_days",
            baseAmount = 300,
            description = "30-day streak!"
        )
        assertEquals("streak_30_days", result.sourceType)
        assertEquals(300, result.earned)
    }

    @Test
    fun earnCoins_differentUsers_separateBalances() = runTest {
        val repo = createRepo()
        repo.earnCoins("user_a", "srs_review_complete", 10, "Session A")
        repo.earnCoins("user_b", "srs_review_complete", 25, "Session B")

        assertEquals(10L, repo.getBalance("user_a").localBalance)
        assertEquals(25L, repo.getBalance("user_b").localBalance)
    }

    @Test
    fun getBalance_afterMultipleEarns_tracksSyncedSeparately() = runTest {
        val repo = createRepo()
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 10, "Session 1")
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 10, "Session 2")

        val balance = repo.getBalance(LOCAL_USER_ID)
        assertEquals(20L, balance.localBalance)
        assertEquals(0L, balance.syncedBalance) // Never synced
    }

    @Test
    fun earnCoins_zeroAmount_stillRecorded() = runTest {
        val repo = createRepo()
        val result = repo.earnCoins(LOCAL_USER_ID, "test", 0, "Zero earn")
        assertEquals(0, result.earned)
        assertEquals(0L, result.newBalance)
    }
}

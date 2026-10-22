package com.jworks.kanjijourney.core

import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import com.jworks.kanjijourney.core.data.JCoinRepositoryImpl
import com.jworks.kanjijourney.core.data.remote.SupabaseClientFactory
import com.jworks.kanjijourney.core.domain.model.LOCAL_USER_ID
import com.jworks.kanjijourney.db.KanjiJourneyDatabase
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.http.HttpStatusCode
import kotlinx.coroutines.test.runTest
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * The anonymous J Coin sign-in stays OFF until Jay decides (task #41). With the switch off the
 * sync must make no network call at all and leave queued earns untouched. The switch-on case
 * shows the test can see a signup when one happens.
 */
class JCoinSyncSwitchTest {

    private val requests = mutableListOf<String>()
    private val engine = MockEngine { request ->
        requests += request.url.encodedPath
        respond("{}", HttpStatusCode.InternalServerError)
    }

    private val fixedClock = object : Clock {
        override fun now() = Instant.fromEpochSeconds(1700000000L)
    }

    private fun createTestDb(): KanjiJourneyDatabase {
        val driver = JdbcSqliteDriver(JdbcSqliteDriver.IN_MEMORY)
        KanjiJourneyDatabase.Schema.create(driver)
        return KanjiJourneyDatabase(driver)
    }

    @BeforeTest
    fun setUp() {
        SupabaseClientFactory.reset()
        SupabaseClientFactory.anonymousSignInEnabled = false
        SupabaseClientFactory.initialize("https://example.test", "test-key", engine)
    }

    @AfterTest
    fun tearDown() {
        SupabaseClientFactory.anonymousSignInEnabled = false
        SupabaseClientFactory.reset()
    }

    @Test
    fun switchOff_noSignupNoEarnCall_queuedEarnWaits() = runTest {
        val db = createTestDb()
        val repo = JCoinRepositoryImpl(db, fixedClock)
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 5, "Test earn")

        assertEquals(0, repo.syncPendingEvents())

        assertEquals(emptyList(), requests)
        val row = db.jCoinQueries.getPendingEvents().executeAsList().single()
        assertEquals("pending", row.sync_status)
        assertEquals(0L, row.retry_count)
        assertNull(row.last_attempt_at)
        assertNull(row.error_message)
    }

    @Test
    fun switchOn_attemptsSignup_andNoEarnWithoutSession() = runTest {
        SupabaseClientFactory.anonymousSignInEnabled = true
        val db = createTestDb()
        val repo = JCoinRepositoryImpl(db, fixedClock)
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 5, "Test earn")

        assertEquals(0, repo.syncPendingEvents())

        assertTrue(requests.any { it.endsWith("/auth/v1/signup") }, "requests: $requests")
        assertTrue(requests.none { it.contains("jcoin-unified-earn") }, "requests: $requests")
    }

    @Test
    fun storedRequestHeaders_areScrubbedOnSync() = runTest {
        val db = createTestDb()
        val queries = db.jCoinQueries
        queries.insertSyncEvent(
            user_id = LOCAL_USER_ID,
            event_type = "earn",
            source_type = "srs_review_complete",
            base_amount = 5,
            description = "Test earn",
            metadata = "{}",
            created_at = 1700000000L,
            client_event_id = "test-event"
        )
        val id = queries.getPendingEvents().executeAsList().single().id
        queries.updateSyncStatus(
            sync_status = "failed",
            last_attempt_at = 1700000000L,
            error_message = "{\"error\":\"VALIDATION_ERROR\"}\nURL: https://example.test/functions/v1/x\n" +
                "Headers: [Authorization=[Bearer TOKEN_PLACEHOLDER], apikey=[KEY_PLACEHOLDER]]\nHttp Method: POST",
            id = id
        )

        JCoinRepositoryImpl(db, fixedClock).syncPendingEvents()

        val stored = queries.getPendingEvents().executeAsList().single().error_message
        assertEquals("{\"error\":\"VALIDATION_ERROR\"}", stored)
        assertFalse(stored!!.contains("Bearer"))
    }
}

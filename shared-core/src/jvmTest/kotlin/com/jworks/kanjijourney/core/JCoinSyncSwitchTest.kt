package com.jworks.kanjijourney.core

import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import com.jworks.kanjijourney.core.data.JCoinRepositoryImpl
import com.jworks.kanjijourney.core.data.remote.SupabaseClientFactory
import com.jworks.kanjijourney.core.domain.model.LOCAL_USER_ID
import com.jworks.kanjijourney.db.KanjiJourneyDatabase
import com.jworks.kanjijourney.core.data.remote.JCoinSession
import io.github.jan.supabase.gotrue.MemorySessionManager
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.headersOf
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
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
 * Anonymous J Coin sign-in switch (task #41, ON since v1.4.42). With the switch off the sync must
 * make no network call at all and leave queued earns untouched. With it on, a signup happens only
 * when an earn is queued, once per install, and spend rows are never sent (BUG-011).
 */
class JCoinSyncSwitchTest {

    // Every request path, and the Authorization header of each earn call
    private val requests = java.util.Collections.synchronizedList(mutableListOf<String>())
    private val earnAuth = java.util.Collections.synchronizedList(mutableListOf<String?>())

    // false: the server answers 500 to everything. true: signup returns a session, earns return 201.
    private var serverOk = false

    private val engine = MockEngine { request ->
        val path = request.url.encodedPath
        requests += path
        val json = headersOf(HttpHeaders.ContentType, "application/json")
        when {
            !serverOk -> respond("{}", HttpStatusCode.InternalServerError)
            path.endsWith("/auth/v1/signup") -> {
                delay(200) // a slow signup, so a second caller arrives while it is in flight
                respond(SESSION_JSON, HttpStatusCode.OK, json)
            }
            path.contains("jcoin-unified-earn") -> {
                earnAuth += request.headers[HttpHeaders.Authorization]
                respond("""{"success":true}""", HttpStatusCode.Created, json)
            }
            else -> respond("{}", HttpStatusCode.NotFound)
        }
    }

    private val defaultSwitch = SupabaseClientFactory.anonymousSignInEnabled

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
        SupabaseClientFactory.initialize("https://example.test", "test-key", engine, MemorySessionManager())
    }

    @AfterTest
    fun tearDown() {
        SupabaseClientFactory.anonymousSignInEnabled = defaultSwitch
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
    fun switchOn_onlySpendQueued_noSignupAndSpendNotSent() = runTest {
        SupabaseClientFactory.anonymousSignInEnabled = true
        val db = createTestDb()
        db.jCoinQueries.insertSyncEvent(
            user_id = LOCAL_USER_ID,
            event_type = "spend",
            source_type = "shop_purchase",
            base_amount = 50,
            description = "Test spend",
            metadata = "{}",
            created_at = 1700000000L,
            client_event_id = "test-spend"
        )
        val repo = JCoinRepositoryImpl(db, fixedClock)

        assertEquals(0, repo.syncPendingEvents())

        assertEquals(emptyList(), requests)
        assertEquals("pending", db.jCoinQueries.getPendingEvents().executeAsList().single().sync_status)
        // The worker only waits on rows the sync would send, so a lone spend does not keep it retrying
        assertEquals(0L, repo.getPendingSyncCount())
    }

    @Test
    fun switchIsOnByDefault() {
        assertTrue(defaultSwitch)
    }

    @Test
    fun switchOn_concurrentCallers_oneSignup_earnSentOnceWithToken() = runTest {
        SupabaseClientFactory.anonymousSignInEnabled = true
        serverOk = true
        val db = createTestDb()
        val repo = JCoinRepositoryImpl(db, fixedClock)
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 5, "Test earn")
        db.jCoinQueries.insertSyncEvent(
            user_id = LOCAL_USER_ID,
            event_type = "spend",
            source_type = "shop_purchase",
            base_amount = 3,
            description = "Test spend",
            metadata = "{}",
            created_at = 1700000000L,
            client_event_id = "test-spend"
        )

        val synced = coroutineScope {
            val a = async { repo.syncPendingEvents() }
            val b = async { repo.syncPendingEvents() }
            val c = async { SupabaseClientFactory.ensureAnonymousSession() }
            c.await()
            a.await() + b.await()
        }

        assertEquals(1, synced)
        assertEquals(1, requests.count { it.endsWith("/auth/v1/signup") }, "requests: $requests")
        assertEquals(listOf<String?>("Bearer test-access-token"), earnAuth.toList())
        // Only the spend is left queued, and the earn counts as synced for a later guest migration
        assertEquals(listOf("spend"), db.jCoinQueries.getPendingEvents().executeAsList().map { it.event_type })
        assertEquals(5L, db.jCoinQueries.getBalance(LOCAL_USER_ID).executeAsOne().synced_balance)
        assertEquals(JCoinSession.RESTORED, SupabaseClientFactory.ensureAnonymousSession())
    }

    @Test
    fun earnOutOfRetries_isSentAfterTheFirstSession() = runTest {
        val db = createTestDb()
        val repo = JCoinRepositoryImpl(db, fixedClock)
        repo.earnCoins(LOCAL_USER_ID, "srs_review_complete", 5, "Earned before this install had a session")
        val id = db.jCoinQueries.getPendingEvents().executeAsList().single().id
        repeat(5) { db.jCoinQueries.updateSyncStatus("failed", 1700000000L, "HTTP 401", id) }
        assertEquals(0L, repo.getPendingSyncCount())

        SupabaseClientFactory.anonymousSignInEnabled = true
        serverOk = true
        assertEquals(1, repo.syncPendingEvents())

        assertEquals(1, earnAuth.size)
        assertTrue(db.jCoinQueries.getPendingEvents().executeAsList().isEmpty())
    }

    @Test
    fun switchOff_reconcileMakesNoRequest() = runTest {
        val repo = JCoinRepositoryImpl(createTestDb(), fixedClock)

        assertFalse(repo.reconcileMigratedBalance(LOCAL_USER_ID, 100, "test-migration"))

        assertEquals(emptyList(), requests)
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

    private companion object {
        // UserSession requires user, and UserInfo requires id and aud (supabase-kt 2.0.4)
        const val SESSION_JSON =
            """{"access_token":"test-access-token","refresh_token":"test-refresh-token","expires_in":3600,"token_type":"bearer",""" +
                """"user":{"id":"00000000-0000-4000-8000-000000000001","aud":"authenticated"}}"""
    }
}

package com.jworks.kanjijourney.core.data.remote

import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.functions.Functions
import io.github.jan.supabase.gotrue.Auth
import io.github.jan.supabase.gotrue.SessionManager
import io.github.jan.supabase.gotrue.SessionStatus
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.gotrue.user.UserSession
import io.github.jan.supabase.postgrest.Postgrest
import io.ktor.client.engine.HttpClientEngine
import io.ktor.client.request.setBody
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.HttpMethod
import io.ktor.http.contentType
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.serialization.json.Json

/**
 * Supabase client factory for J Coin backend integration.
 *
 * Configuration:
 * - SUPABASE_URL: Set in local.properties or BuildConfig
 * - SUPABASE_ANON_KEY: Set in local.properties or BuildConfig
 *
 * These values should be injected via Hilt in the Android app module.
 */
object SupabaseClientFactory {

    private var _instance: SupabaseClient? = null

    private val json = Json { ignoreUnknownKeys = true }

    /** Device country (ISO 3166 alpha-2), set by the platform at startup; sent once at anonymous signup. */
    var deviceCountry: String? = null

    /**
     * Anonymous J Coin sign-in for players: each install earns under its own anonymous J Coin
     * account. ON since v1.4.42: option A on desk card desk-jworks44-kanjijourney-jcoin-earning,
     * chosen by jworks:0 on 2026-11-01 after jayhub:131 returned the card to the fleet (task #41).
     * Coins stay with the install until accounts are linked (task #31). Set to false to stop
     * signups and earn calls; queued earns then stay queued.
     */
    var anonymousSignInEnabled: Boolean = true

    private val signupMutex = Mutex()

    /**
     * Initialize the Supabase client with configuration.
     *
     * @param supabaseUrl The Supabase project URL (e.g., https://xxxxx.supabase.co)
     * @param supabaseKey The Supabase anon/public key
     */
    fun initialize(
        supabaseUrl: String,
        supabaseKey: String,
        httpEngine: HttpClientEngine? = null,
        sessionManager: SessionManager? = null
    ) {
        if (_instance != null) {
            throw IllegalStateException("SupabaseClient already initialized")
        }

        _instance = createSupabaseClient(
            supabaseUrl = supabaseUrl,
            supabaseKey = supabaseKey
        ) {
            // Tests pass a mock engine and an in-memory session manager; the app uses the defaults
            if (httpEngine != null) this.httpEngine = httpEngine
            // Auth carries the anonymous J Coin session: Functions sends its access token as Bearer.
            // Default session manager (persistent on Android), so the session survives restarts.
            install(Auth) {
                if (sessionManager != null) this.sessionManager = sessionManager
            }
            install(Postgrest)
            install(Functions)
        }
    }

    /**
     * Makes sure the J Coin client holds a project-issued user session. The function's auth layer
     * answers 401 to any call without a user token (task #41), so each install signs in anonymously
     * once, on the J Coin project, and keeps that session. Coins follow the install's session until
     * accounts are linked (task #31). Returns NONE when no session can be made; callers keep their
     * queued work and try again later.
     */
    suspend fun ensureAnonymousSession(): JCoinSession {
        if (!anonymousSignInEnabled) return JCoinSession.NONE
        val client = getInstance()
        // The saved session loads (and may refresh) in the background after start. Until that ends
        // currentSessionOrNull() is null, and signing up then would replace this install's account.
        client.auth.awaitInitialization()
        storedSessionState(client)?.let { return it }
        // One signup at a time: the coin worker and the app can both get here, and two signups
        // would make two J Coin accounts for one install
        return signupMutex.withLock {
            storedSessionState(client)?.let { return@withLock it }
            try {
                // GoTrue anonymous signup: POST /auth/v1/signup, no email or password
                // supabaseUrl is the bare host; supabaseHttpUrl carries the scheme
                val response = client.httpClient.request("${client.supabaseHttpUrl}/auth/v1/signup") {
                    method = HttpMethod.Post
                    contentType(ContentType.Application.Json)
                    setBody(anonymousSignupBody(deviceCountry))
                }
                if (response.status.value !in 200..299) {
                    println("J Coin anonymous signup failed: HTTP ${response.status.value}")
                    return@withLock JCoinSession.NONE
                }
                val session = json.decodeFromString<UserSession>(response.bodyAsText())
                client.auth.importSession(session, true)
                JCoinSession.CREATED
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                // Type only: exception messages can carry the request URL and headers (BUG-015)
                println("J Coin anonymous signup failed: ${e::class.simpleName}")
                JCoinSession.NONE
            }
        }
    }

    // RESTORED when a session is live; NONE when a saved session exists but its refresh failed on the
    // network (never sign up over it); null when there is no session and a signup is needed.
    private fun storedSessionState(client: SupabaseClient): JCoinSession? =
        when (client.auth.sessionStatus.value) {
            is SessionStatus.Authenticated -> JCoinSession.RESTORED
            SessionStatus.NotAuthenticated -> null
            else -> JCoinSession.NONE
        }

    /**
     * Get the initialized Supabase client instance.
     *
     * @throws IllegalStateException if client hasn't been initialized
     */
    fun getInstance(): SupabaseClient {
        return _instance ?: throw IllegalStateException(
            "SupabaseClient not initialized. Call initialize() first."
        )
    }

    /**
     * Check if the client has been initialized.
     */
    fun isInitialized(): Boolean = _instance != null

    /**
     * Reset the client instance (for testing).
     */
    internal fun reset() {
        _instance = null
    }
}

/** Outcome of [SupabaseClientFactory.ensureAnonymousSession]. */
enum class JCoinSession {
    /** No usable session; keep queued work for later. */
    NONE,
    /** This install already had its J Coin session. */
    RESTORED,
    /** First J Coin session for this install, made just now. */
    CREATED
}

// Body for the anonymous signup. data.country (uppercase ISO alpha-2) lands in the J Coin project's
// auth.users.raw_user_meta_data, for customers.country (S-337). Omitted when the device gives nothing usable.
internal fun anonymousSignupBody(country: String?): String {
    val code = country?.trim()?.uppercase()
    return if (code != null && code.length == 2 && code.all { it in 'A'..'Z' }) {
        """{"data":{"country":"$code"}}"""
    } else {
        "{}"
    }
}

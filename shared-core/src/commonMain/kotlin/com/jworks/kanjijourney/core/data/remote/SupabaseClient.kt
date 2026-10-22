package com.jworks.kanjijourney.core.data.remote

import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.functions.Functions
import io.github.jan.supabase.gotrue.Auth
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.gotrue.user.UserSession
import io.github.jan.supabase.postgrest.Postgrest
import io.ktor.client.engine.HttpClientEngine
import io.ktor.client.request.setBody
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.HttpMethod
import io.ktor.http.contentType
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
     * Anonymous J Coin sign-in for players. OFF until Jay decides (desk card
     * desk-jworks44-kanjijourney-jcoin-earning, task #41). While off there is no signup and no
     * J Coin earn call; queued earns stay queued.
     */
    var anonymousSignInEnabled: Boolean = false

    /**
     * Initialize the Supabase client with configuration.
     *
     * @param supabaseUrl The Supabase project URL (e.g., https://xxxxx.supabase.co)
     * @param supabaseKey The Supabase anon/public key
     */
    fun initialize(supabaseUrl: String, supabaseKey: String, httpEngine: HttpClientEngine? = null) {
        if (_instance != null) {
            throw IllegalStateException("SupabaseClient already initialized")
        }

        _instance = createSupabaseClient(
            supabaseUrl = supabaseUrl,
            supabaseKey = supabaseKey
        ) {
            // Tests pass a mock engine; the app uses the platform default
            if (httpEngine != null) this.httpEngine = httpEngine
            // Auth carries the anonymous J Coin session: Functions sends its access token as Bearer.
            // Default session manager (persistent on Android), so the session survives restarts.
            install(Auth)
            install(Postgrest)
            install(Functions)
        }
    }

    /**
     * Makes sure the J Coin client holds a project-issued user session. The function's auth layer
     * answers 401 to any call without a user token (task #41), so each install signs in anonymously
     * once, on the J Coin project, and keeps that session. Pending Jay's decision (task #41): coins
     * follow the install's session until accounts are linked (task #31). Returns false when no session can
     * be made; callers keep their queued work and try again later.
     */
    suspend fun ensureAnonymousSession(): Boolean {
        if (!anonymousSignInEnabled) return false
        val client = getInstance()
        if (client.auth.currentSessionOrNull() != null) return true
        return try {
            // GoTrue anonymous signup: POST /auth/v1/signup, no email or password
            // supabaseUrl is the bare host; supabaseHttpUrl carries the scheme
            val response = client.httpClient.request("${client.supabaseHttpUrl}/auth/v1/signup") {
                method = HttpMethod.Post
                contentType(ContentType.Application.Json)
                setBody(anonymousSignupBody(deviceCountry))
            }
            if (response.status.value !in 200..299) {
                println("J Coin anonymous signup failed: HTTP ${response.status.value}")
                return false
            }
            val session = json.decodeFromString<UserSession>(response.bodyAsText())
            client.auth.importSession(session, true)
            true
        } catch (e: Exception) {
            println("J Coin anonymous signup failed: ${e::class.simpleName}: ${e.message}")
            false
        }
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

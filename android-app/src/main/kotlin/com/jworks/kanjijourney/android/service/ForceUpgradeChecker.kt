package com.jworks.kanjijourney.android.service

import android.util.Log
import com.jworks.kanjijourney.core.data.remote.SupabaseClientFactory
import io.github.jan.supabase.postgrest.from
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

sealed class UpgradeCheckState {
    data object Checking : UpgradeCheckState()
    data object UpToDate : UpgradeCheckState()
    data class UpdateRequired(
        val message: String,
        val storeUrl: String?
    ) : UpgradeCheckState()
}

@Serializable
data class AppConfigResponse(
    @SerialName("min_version") val minVersion: String,
    @SerialName("force_upgrade_message") val forceUpgradeMessage: String? = null,
    @SerialName("store_url") val storeUrl: String? = null
)

object ForceUpgradeChecker {

    private const val TAG = "ForceUpgrade"
    private const val APP_ID = "kanjijourney"
    private const val DEFAULT_MESSAGE = "A new version of KanjiJourney is available. Please update to continue using the app."

    suspend fun check(currentVersion: String): UpgradeCheckState {
        if (!SupabaseClientFactory.isInitialized()) {
            Log.w(TAG, "Supabase not initialized, skipping version check")
            return UpgradeCheckState.UpToDate
        }

        return try {
            val client = SupabaseClientFactory.getInstance()
            val configs = client.from("app_config")
                .select {
                    filter { eq("app_id", APP_ID) }
                }
                .decodeList<AppConfigResponse>()

            val config = configs.firstOrNull()
            if (config == null) {
                Log.i(TAG, "No app_config found for $APP_ID, allowing app")
                return UpgradeCheckState.UpToDate
            }

            if (isVersionBelow(currentVersion, config.minVersion)) {
                Log.w(TAG, "Version $currentVersion below minimum ${config.minVersion}")
                UpgradeCheckState.UpdateRequired(
                    message = config.forceUpgradeMessage ?: DEFAULT_MESSAGE,
                    storeUrl = config.storeUrl
                )
            } else {
                Log.i(TAG, "Version $currentVersion meets minimum ${config.minVersion}")
                UpgradeCheckState.UpToDate
            }
        } catch (e: Exception) {
            Log.w(TAG, "Version check failed, allowing app to continue: ${e.message}")
            UpgradeCheckState.UpToDate
        }
    }

    internal fun isVersionBelow(current: String, minimum: String): Boolean {
        val currentParts = current.split(".").mapNotNull { it.toIntOrNull() }
        val minimumParts = minimum.split(".").mapNotNull { it.toIntOrNull() }

        for (i in 0 until maxOf(currentParts.size, minimumParts.size)) {
            val c = currentParts.getOrElse(i) { 0 }
            val m = minimumParts.getOrElse(i) { 0 }
            if (c < m) return true
            if (c > m) return false
        }
        return false
    }
}

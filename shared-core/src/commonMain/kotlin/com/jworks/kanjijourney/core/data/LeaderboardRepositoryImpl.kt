package com.jworks.kanjijourney.core.data

import com.jworks.kanjijourney.core.data.remote.SupabaseClientFactory
import com.jworks.kanjijourney.core.domain.UserSessionProvider
import com.jworks.kanjijourney.core.domain.model.CoinTier
import com.jworks.kanjijourney.core.domain.model.LOCAL_USER_ID
import com.jworks.kanjijourney.core.domain.model.LeaderboardEntry
import com.jworks.kanjijourney.core.domain.repository.JCoinRepository
import com.jworks.kanjijourney.core.domain.repository.LeaderboardRepository
import io.github.jan.supabase.functions.functions
import io.ktor.client.call.body
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.long
import kotlinx.serialization.json.put

class LeaderboardRepositoryImpl(
    private val jCoinRepository: JCoinRepository,
    private val userSessionProvider: UserSessionProvider
) : LeaderboardRepository {

    override suspend fun getTopUsers(limit: Int): List<LeaderboardEntry> = withContext(Dispatchers.Default) {
        try {
            fetchFromSupabase(limit)
        } catch (_: Exception) {
            buildLocalLeaderboard()
        }
    }

    override suspend fun getCurrentUserRank(userId: String): LeaderboardEntry? = withContext(Dispatchers.Default) {
        val balance = jCoinRepository.getBalance(userId)
        LeaderboardEntry(
            rank = 0,
            displayName = "You",
            lifetimeEarned = balance.lifetimeEarned,
            tier = balance.tier,
            isCurrentUser = true
        )
    }

    private suspend fun fetchFromSupabase(limit: Int): List<LeaderboardEntry> {
        if (!SupabaseClientFactory.isInitialized()) {
            return buildLocalLeaderboard()
        }

        val userId = userSessionProvider.getUserId()
        val supabase = SupabaseClientFactory.getInstance()
        val response = supabase.functions.invoke(
            function = "jcoin-leaderboard",
            body = buildJsonObject {
                put("source_business", "kanjijourney")
                put("limit", limit)
                put("user_id", userId)
            }
        )

        if (response.status.value !in 200..299) {
            return buildLocalLeaderboard()
        }

        val body = response.body<String>()
        val json = Json.parseToJsonElement(body).jsonObject
        val entries = json["leaderboard"]?.jsonArray ?: return buildLocalLeaderboard()

        return entries.mapIndexed { index, element ->
            val obj = element.jsonObject
            LeaderboardEntry(
                rank = index + 1,
                displayName = obj["display_name"]?.jsonPrimitive?.content ?: "Anonymous",
                lifetimeEarned = obj["lifetime_earned"]?.jsonPrimitive?.long ?: 0L,
                tier = CoinTier.fromString(obj["tier"]?.jsonPrimitive?.content ?: "bronze"),
                isCurrentUser = obj["is_current_user"]?.jsonPrimitive?.content == "true"
            )
        }
    }

    private suspend fun buildLocalLeaderboard(): List<LeaderboardEntry> {
        val userId = userSessionProvider.getUserId()
        val balance = jCoinRepository.getBalance(userId)
        return listOf(
            LeaderboardEntry(
                rank = 1,
                displayName = "You",
                lifetimeEarned = balance.lifetimeEarned,
                tier = balance.tier,
                isCurrentUser = true
            )
        )
    }
}

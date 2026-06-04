package com.jworks.kanjijourney.core.domain.repository

import com.jworks.kanjijourney.core.domain.model.LeaderboardEntry

interface LeaderboardRepository {
    suspend fun getTopUsers(limit: Int = 10): List<LeaderboardEntry>
    suspend fun getCurrentUserRank(userId: String): LeaderboardEntry?
}

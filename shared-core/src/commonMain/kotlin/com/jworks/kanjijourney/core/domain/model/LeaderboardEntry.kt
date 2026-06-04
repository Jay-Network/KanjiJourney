package com.jworks.kanjijourney.core.domain.model

data class LeaderboardEntry(
    val rank: Int,
    val displayName: String,
    val lifetimeEarned: Long,
    val tier: CoinTier,
    val isCurrentUser: Boolean
)

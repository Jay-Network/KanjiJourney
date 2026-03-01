package com.jworks.kanjijourney.core.domain.repository

import com.jworks.kanjijourney.core.domain.model.UserProfile

interface UserRepository {
    suspend fun getProfile(): UserProfile
    suspend fun updateXpAndLevel(totalXp: Int, level: Int)
    suspend fun updateStreak(current: Int, longest: Int, lastStudyDate: String)
    suspend fun updateDailyGoal(goal: Int)
}

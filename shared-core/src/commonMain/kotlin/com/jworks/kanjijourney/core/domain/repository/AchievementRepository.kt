package com.jworks.kanjijourney.core.domain.repository

import com.jworks.kanjijourney.core.domain.model.Achievement

interface AchievementRepository {
    suspend fun getAchievement(id: String): Achievement?
    suspend fun getAllAchievements(): List<Achievement>
    suspend fun getUnlockedAchievements(): List<Achievement>
    suspend fun getLockedAchievements(): List<Achievement>
    suspend fun updateProgress(id: String, progress: Int, unlockedAt: Long?)
    suspend fun upsertAchievement(achievement: Achievement)
}

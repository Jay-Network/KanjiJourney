package com.jworks.kanjijourney.core.data

import com.jworks.kanjijourney.core.domain.model.Achievement
import com.jworks.kanjijourney.core.domain.repository.AchievementRepository
import com.jworks.kanjijourney.db.KanjiJourneyDatabase

class AchievementRepositoryImpl(
    private val database: KanjiJourneyDatabase
) : AchievementRepository {

    override suspend fun getAchievement(id: String): Achievement? {
        return database.achievementQueries.getById(id).executeAsOneOrNull()?.let {
            Achievement(
                id = it.id,
                progress = it.progress.toInt(),
                target = it.target.toInt(),
                unlockedAt = it.unlocked_at
            )
        }
    }

    override suspend fun getAllAchievements(): List<Achievement> {
        return database.achievementQueries.getAll().executeAsList().map {
            Achievement(
                id = it.id,
                progress = it.progress.toInt(),
                target = it.target.toInt(),
                unlockedAt = it.unlocked_at
            )
        }
    }

    override suspend fun getUnlockedAchievements(): List<Achievement> {
        return database.achievementQueries.getUnlocked().executeAsList().map {
            Achievement(
                id = it.id,
                progress = it.progress.toInt(),
                target = it.target.toInt(),
                unlockedAt = it.unlocked_at
            )
        }
    }

    override suspend fun getLockedAchievements(): List<Achievement> {
        return database.achievementQueries.getLocked().executeAsList().map {
            Achievement(
                id = it.id,
                progress = it.progress.toInt(),
                target = it.target.toInt(),
                unlockedAt = it.unlocked_at
            )
        }
    }

    override suspend fun updateProgress(id: String, progress: Int, unlockedAt: Long?) {
        database.achievementQueries.updateProgress(
            progress = progress.toLong(),
            unlocked_at = unlockedAt,
            id = id
        )
    }

    override suspend fun upsertAchievement(achievement: Achievement) {
        database.achievementQueries.upsert(
            id = achievement.id,
            unlocked_at = achievement.unlockedAt,
            progress = achievement.progress.toLong(),
            target = achievement.target.toLong()
        )
    }
}

package com.jworks.kanjijourney.core.data

import com.jworks.kanjijourney.core.domain.model.UserProfile
import com.jworks.kanjijourney.core.domain.repository.UserRepository
import com.jworks.kanjijourney.db.KanjiJourneyDatabase

class UserRepositoryImpl(
    private val db: KanjiJourneyDatabase
) : UserRepository {

    override suspend fun getProfile(): UserProfile {
        db.userProfileQueries.initializeIfEmpty()
        val row = db.userProfileQueries.get().executeAsOne()
        return UserProfile(
            totalXp = row.total_xp.toInt(),
            level = row.level.toInt(),
            currentStreak = row.current_streak.toInt(),
            longestStreak = row.longest_streak.toInt(),
            lastStudyDate = row.last_study_date,
            dailyGoal = row.daily_goal.toInt()
        )
    }

    override suspend fun updateXpAndLevel(totalXp: Int, level: Int) {
        db.userProfileQueries.updateXpAndLevel(totalXp.toLong(), level.toLong())
    }

    override suspend fun updateStreak(current: Int, longest: Int, lastStudyDate: String) {
        db.userProfileQueries.updateStreak(current.toLong(), longest.toLong(), lastStudyDate)
    }

    override suspend fun updateDailyGoal(goal: Int) {
        db.userProfileQueries.updateDailyGoal(goal.toLong())
    }
}

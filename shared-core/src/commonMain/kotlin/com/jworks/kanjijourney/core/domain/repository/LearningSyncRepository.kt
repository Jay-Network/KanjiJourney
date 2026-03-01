package com.jworks.kanjijourney.core.domain.repository

import com.jworks.kanjijourney.core.data.sync.DeviceInfo
import com.jworks.kanjijourney.core.data.sync.SyncResult
import com.jworks.kanjijourney.core.data.sync.SyncTrigger
import com.jworks.kanjijourney.core.domain.model.Achievement
import com.jworks.kanjijourney.core.domain.model.CloudLearningData
import com.jworks.kanjijourney.core.domain.model.DailyStatsData
import com.jworks.kanjijourney.core.domain.model.StudySession
import com.jworks.kanjijourney.core.domain.model.UserProfile

interface LearningSyncRepository {
    // --- V2 methods ---

    suspend fun syncAll(userId: String, trigger: SyncTrigger): SyncResult

    suspend fun pushSessionData(userId: String): SyncResult

    suspend fun pullLatest(userId: String): SyncResult

    suspend fun registerDevice(userId: String, deviceInfo: DeviceInfo): String?

    // --- V1 methods (kept during migration) ---

    suspend fun queueSessionSync(
        userId: String,
        touchedKanjiIds: List<Int>,
        touchedVocabIds: List<Long>,
        profile: UserProfile,
        session: StudySession,
        dailyStats: DailyStatsData,
        achievements: List<Achievement>
    )

    suspend fun syncPendingEvents(): Int

    suspend fun getPendingSyncCount(): Long

    suspend fun pullCloudData(userId: String): CloudLearningData?

    suspend fun applyCloudData(data: CloudLearningData)
}

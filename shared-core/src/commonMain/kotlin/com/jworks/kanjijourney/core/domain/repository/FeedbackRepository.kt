package com.jworks.kanjijourney.core.domain.repository

import com.jworks.kanjijourney.core.domain.model.Feedback
import com.jworks.kanjijourney.core.domain.model.FeedbackCategory
import com.jworks.kanjijourney.core.domain.model.FeedbackWithHistory
import com.jworks.kanjijourney.core.domain.model.SubmitFeedbackResult

interface FeedbackRepository {
    /**
     * Submit new feedback
     * @param email User email
     * @param appId App identifier (e.g., "kanjijourney")
     * @param category Feedback category
     * @param feedbackText Feedback text (10-1000 chars)
     * @param deviceInfo Optional device information
     * @return Result with feedback ID or error
     */
    suspend fun submitFeedback(
        email: String,
        appId: String,
        category: FeedbackCategory,
        feedbackText: String,
        deviceInfo: Map<String, String>? = null
    ): SubmitFeedbackResult

    /**
     * Get all feedback submitted by the user for this app
     * @param email User email
     * @param appId App identifier
     * @param sinceId Optional: only return feedback with ID > sinceId (for incremental updates)
     * @return List of feedback with status history
     */
    suspend fun getFeedbackUpdates(
        email: String,
        appId: String,
        sinceId: Long? = null
    ): List<FeedbackWithHistory>

    /**
     * Register FCM token for push notifications
     * @param email User email
     * @param appId App identifier
     * @param fcmToken FCM device token
     * @param deviceInfo Optional device information
     */
    suspend fun registerFcmToken(
        email: String,
        appId: String,
        fcmToken: String,
        deviceInfo: Map<String, String>? = null
    ): Boolean
}

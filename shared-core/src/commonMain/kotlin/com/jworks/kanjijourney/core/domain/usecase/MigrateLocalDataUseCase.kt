package com.jworks.kanjijourney.core.domain.usecase

import com.jworks.kanjijourney.core.domain.model.LOCAL_USER_ID
import com.jworks.kanjijourney.db.KanjiJourneyDatabase

class MigrateLocalDataUseCase(
    private val database: KanjiJourneyDatabase
) {
    /**
     * Migrate all local data from LOCAL_USER_ID to the authenticated user's UUID.
     * Called once when user first signs in.
     */
    fun execute(authUserId: String) {
        if (authUserId == LOCAL_USER_ID) return

        val queries = database.jCoinQueries

        // Check if there's local data to migrate
        val localBalance = queries.getBalance(LOCAL_USER_ID).executeAsOneOrNull()
        if (localBalance == null) return // Nothing to migrate

        // Check if auth user already has data (don't overwrite)
        val existingBalance = queries.getBalance(authUserId).executeAsOneOrNull()
        if (existingBalance != null) return // Already has data, skip migration

        // Migrate all tables
        queries.migrateBalanceUserId(authUserId, LOCAL_USER_ID)
        queries.migrateSyncQueueUserId(authUserId, LOCAL_USER_ID)
        queries.migrateUnlocksUserId(authUserId, LOCAL_USER_ID)
        queries.migrateBoostersUserId(authUserId, LOCAL_USER_ID)
    }
}

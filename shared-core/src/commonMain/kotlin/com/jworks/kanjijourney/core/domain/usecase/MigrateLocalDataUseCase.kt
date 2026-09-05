package com.jworks.kanjijourney.core.domain.usecase

import com.jworks.kanjijourney.core.domain.model.LOCAL_USER_ID
import com.jworks.kanjijourney.core.domain.repository.JCoinRepository
import com.jworks.kanjijourney.db.KanjiJourneyDatabase

class MigrateLocalDataUseCase(
    private val database: KanjiJourneyDatabase,
    private val jCoinRepository: JCoinRepository
) {
    /**
     * Migrate all local data from LOCAL_USER_ID to the authenticated user's UUID.
     * Called once when user first signs in.
     *
     * The unsynced local coin balance is reconciled to the server as ONE aggregate event
     * (not by replaying each queued local event) before anything is migrated, so the server
     * learns about it exactly once — avoiding both double-minting (replaying events the local
     * balance already reflects) and stranding coins on-device only (deleting the queue without
     * ever telling the server). If that reconcile call fails, the whole migration aborts without
     * touching any local data, so it retries cleanly on the next sign-in. (jworks:35, 2026-07-30)
     */
    suspend fun execute(authUserId: String) {
        if (authUserId == LOCAL_USER_ID) return

        val queries = database.jCoinQueries

        // Check if there's local data to migrate
        val localBalance = queries.getBalance(LOCAL_USER_ID).executeAsOneOrNull()
        if (localBalance == null) return // Nothing to migrate

        // Check if auth user already has data (don't overwrite)
        val existingBalance = queries.getBalance(authUserId).executeAsOneOrNull()
        if (existingBalance != null) return // Already has data, skip migration

        val unsyncedAmount = localBalance.local_balance - localBalance.synced_balance
        if (unsyncedAmount > 0) {
            val reconciled = jCoinRepository.reconcileMigratedBalance(
                userId = authUserId,
                amount = unsyncedAmount,
                eventId = "migration:$authUserId"
            )
            if (!reconciled) return // abort entirely; local data untouched, retried next sign-in
        }

        // Migrate all tables
        queries.migrateBalanceUserId(authUserId, LOCAL_USER_ID)
        // Delete rather than re-stamp: the reconcile call above already told the server about
        // every coin these events represent, exactly once. Re-stamping them onto authUserId
        // would let CoinSyncWorker drain them a second time via jcoin-unified-earn, double
        // crediting the same activity (it has no server-side idempotency yet).
        queries.deleteSyncQueueForUser(LOCAL_USER_ID)
        queries.migrateUnlocksUserId(authUserId, LOCAL_USER_ID)
        queries.migrateBoostersUserId(authUserId, LOCAL_USER_ID)
    }
}

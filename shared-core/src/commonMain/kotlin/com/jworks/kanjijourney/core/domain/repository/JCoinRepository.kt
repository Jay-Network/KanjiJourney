package com.jworks.kanjijourney.core.domain.repository

import com.jworks.kanjijourney.core.domain.model.ActiveBooster
import com.jworks.kanjijourney.core.domain.model.BoosterType
import com.jworks.kanjijourney.core.domain.model.CoinBalance
import com.jworks.kanjijourney.core.domain.model.CoinEarnResult
import com.jworks.kanjijourney.core.domain.model.PurchaseResult
import com.jworks.kanjijourney.core.domain.model.ShopItem
import com.jworks.kanjijourney.core.domain.model.SyncStatus
import kotlinx.coroutines.flow.Flow

interface JCoinRepository {
    suspend fun getBalance(userId: String): CoinBalance
    fun observeBalance(userId: String): Flow<CoinBalance>

    suspend fun earnCoins(
        userId: String,
        sourceType: String,
        baseAmount: Int,
        description: String,
        metadata: String = "{}"
    ): CoinEarnResult

    suspend fun getPendingSyncCount(): Long
    suspend fun getSyncStatus(): SyncStatus

    /**
     * Sync pending coin events to the backend.
     * Returns the number of events successfully synced.
     */
    suspend fun syncPendingEvents(): Int

    /**
     * Send ONE reconciling earn event carrying an aggregate amount, tagged with a
     * deterministic [eventId] so a retry is (eventually) safe to dedupe server-side.
     * Used by guest-to-auth migration to move an unsynced local balance to the server
     * exactly once, instead of replaying every underlying local event individually.
     * Returns true only if the server confirmed the event (2xx).
     */
    suspend fun reconcileMigratedBalance(userId: String, amount: Long, eventId: String): Boolean

    // Premium content
    suspend fun isPremiumUnlocked(userId: String, contentType: String, contentId: String): Boolean

    suspend fun getUnlockedContent(userId: String, contentType: String): List<String>

    // Shop
    suspend fun getShopCatalog(): List<ShopItem>

    suspend fun purchaseItem(userId: String, item: ShopItem): PurchaseResult

    // Boosters
    suspend fun getActiveBoosters(userId: String): List<ActiveBooster>

    suspend fun activateBooster(userId: String, boosterType: BoosterType, durationHours: Int, cost: Int): PurchaseResult
}

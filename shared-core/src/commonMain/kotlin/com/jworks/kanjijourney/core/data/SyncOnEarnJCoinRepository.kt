package com.jworks.kanjijourney.core.data

import com.jworks.kanjijourney.core.domain.model.CoinEarnResult
import com.jworks.kanjijourney.core.domain.repository.JCoinRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Sends queued J Coin earns soon after they are made, while the app is open (task #46, BUG-023).
 * Android gives the background CoinSyncWorker no network while the app is in the background, so
 * earns that waited for it could sit in the queue for days. Earns made close together (one session)
 * go out in one sync. A sync that has started is never cancelled, so a J Coin signup is always
 * followed by its earn in the same run.
 */
class SyncOnEarnJCoinRepository(
    private val inner: JCoinRepository,
    private val scope: CoroutineScope,
    private val delayMillis: Long = 2_000
) : JCoinRepository by inner {

    // Unsynchronized on purpose: a lost race only means one extra sync, and syncPendingEvents
    // already runs one at a time and sends each queued earn once.
    private var scheduled: Job? = null

    override suspend fun earnCoins(
        userId: String,
        sourceType: String,
        baseAmount: Int,
        description: String,
        metadata: String
    ): CoinEarnResult = inner.earnCoins(userId, sourceType, baseAmount, description, metadata)
        .also { syncSoon() }

    /** Send queued earns after a short pause. Also called when the app comes to the front. */
    fun syncSoon() {
        // Cancels only a sync still in its pause; a running sync is NonCancellable
        scheduled?.cancel()
        scheduled = scope.launch {
            delay(delayMillis)
            withContext(NonCancellable) {
                try {
                    inner.syncPendingEvents()
                } catch (e: Exception) {
                    // Type only: messages can carry request headers (BUG-015)
                    println("J Coin sync after earn failed: ${e::class.simpleName}")
                }
            }
        }
    }
}

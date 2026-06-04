package com.jworks.kanjijourney.android.ui.leaderboard

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.jworks.kanjijourney.android.ui.theme.GlassBackground
import com.jworks.kanjijourney.android.ui.theme.GlassBorder
import com.jworks.kanjijourney.android.ui.theme.GlassBrand
import com.jworks.kanjijourney.android.ui.theme.GlassCardGradient
import com.jworks.kanjijourney.android.ui.theme.GlassSurfaceLight
import com.jworks.kanjijourney.android.ui.theme.GlassTextMuted
import com.jworks.kanjijourney.android.ui.theme.GlassTextPrimary
import com.jworks.kanjijourney.android.ui.theme.GlassTextSecondary
import com.jworks.kanjijourney.android.ui.theme.focusRingCircle
import com.jworks.kanjijourney.core.domain.model.CoinTier
import com.jworks.kanjijourney.core.domain.model.LeaderboardEntry

private val GoldAccent = Color(0xFFFFD700)
private val SilverAccent = Color(0xFFC0C0C0)
private val BronzeAccent = Color(0xFFCD7F32)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LeaderboardScreen(
    onBack: () -> Unit,
    viewModel: LeaderboardViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        containerColor = GlassBackground,
        topBar = {
            TopAppBar(
                title = { Text("Leaderboard", color = GlassTextPrimary) },
                navigationIcon = {
                    IconButton(onClick = onBack, modifier = Modifier.focusRingCircle()) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = GlassTextPrimary)
                    }
                },
                actions = {
                    IconButton(onClick = { viewModel.refresh() }, modifier = Modifier.focusRingCircle()) {
                        Icon(Icons.Default.Refresh, contentDescription = "Refresh", tint = GlassTextPrimary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = GlassBackground)
            )
        }
    ) { padding ->
        when {
            uiState.isLoading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        CircularProgressIndicator(color = GlassBrand.current)
                        Spacer(modifier = Modifier.height(16.dp))
                        Text("Loading leaderboard...", color = GlassTextSecondary)
                    }
                }
            }
            uiState.error != null -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentAlignment = Alignment.Center
                ) {
                    Text(uiState.error ?: "", color = GlassTextMuted)
                }
            }
            else -> {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding)
                        .padding(horizontal = 16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    item { Spacer(modifier = Modifier.height(8.dp)) }

                    item { LeaderboardHeader() }

                    item { Spacer(modifier = Modifier.height(8.dp)) }

                    itemsIndexed(uiState.entries) { _, entry ->
                        LeaderboardRow(entry = entry)
                    }

                    if (uiState.entries.isEmpty()) {
                        item {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(32.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "No leaderboard data yet.\nEarn J Coins to climb the ranks!",
                                    color = GlassTextMuted,
                                    textAlign = TextAlign.Center,
                                    style = MaterialTheme.typography.bodyLarge
                                )
                            }
                        }
                    }

                    item { Spacer(modifier = Modifier.height(16.dp)) }
                }
            }
        }
    }
}

@Composable
private fun LeaderboardHeader() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(GlassCardGradient)
            .border(1.dp, GlassBorder, RoundedCornerShape(12.dp))
            .padding(20.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = "🏆",
                fontSize = 48.sp
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Top Earners",
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold,
                color = GlassTextPrimary
            )
            Text(
                text = "Ranked by lifetime J Coins earned",
                style = MaterialTheme.typography.bodyMedium,
                color = GlassTextSecondary
            )
        }
    }
}

@Composable
private fun LeaderboardRow(entry: LeaderboardEntry) {
    val rankColor = when (entry.rank) {
        1 -> GoldAccent
        2 -> SilverAccent
        3 -> BronzeAccent
        else -> GlassTextMuted
    }

    val borderColor = if (entry.isCurrentUser) GlassBrand.current.copy(alpha = 0.6f) else GlassBorder

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(
                if (entry.isCurrentUser) GlassBrand.current.copy(alpha = 0.08f)
                else GlassSurfaceLight.copy(alpha = 0.6f)
            )
            .border(1.dp, borderColor, RoundedCornerShape(12.dp))
            .padding(12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Rank badge
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(rankColor.copy(alpha = 0.2f))
                    .border(1.dp, rankColor.copy(alpha = 0.5f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = if (entry.rank in 1..3) rankMedal(entry.rank) else "#${entry.rank}",
                    fontSize = if (entry.rank in 1..3) 20.sp else 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = if (entry.rank in 1..3) rankColor else GlassTextPrimary
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            // Name + tier
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = entry.displayName,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = if (entry.isCurrentUser) FontWeight.Bold else FontWeight.Medium,
                    color = if (entry.isCurrentUser) GlassBrand.current else GlassTextPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = tierLabel(entry.tier),
                    style = MaterialTheme.typography.bodySmall,
                    color = GlassTextSecondary
                )
            }

            // Coin count
            Column(horizontalAlignment = Alignment.End) {
                Text(
                    text = formatCoins(entry.lifetimeEarned),
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = GlassBrand.current
                )
                Text(
                    text = "J Coins",
                    style = MaterialTheme.typography.labelSmall,
                    color = GlassTextMuted
                )
            }
        }
    }
}

private fun rankMedal(rank: Int): String = when (rank) {
    1 -> "🥇"
    2 -> "🥈"
    3 -> "🥉"
    else -> "#$rank"
}

private fun tierLabel(tier: CoinTier): String = when (tier) {
    CoinTier.BRONZE -> "🟤 Bronze"
    CoinTier.SILVER -> "⚪ Silver"
    CoinTier.GOLD -> "🟡 Gold"
    CoinTier.PLATINUM -> "💎 Platinum"
}

private fun formatCoins(amount: Long): String = when {
    amount >= 10_000 -> "${amount / 1_000}K"
    amount >= 1_000 -> String.format("%.1fK", amount / 1_000.0)
    else -> amount.toString()
}

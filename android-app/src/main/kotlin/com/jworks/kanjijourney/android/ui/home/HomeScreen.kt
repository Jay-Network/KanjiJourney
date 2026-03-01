package com.jworks.kanjijourney.android.ui.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.shape.RoundedCornerShape
import com.jworks.kanjijourney.android.ui.components.AssetImage
import com.jworks.kanjijourney.android.ui.theme.GlassBackground
import com.jworks.kanjijourney.android.ui.theme.GlassCard
import com.jworks.kanjijourney.android.ui.theme.GlassCardGradient
import com.jworks.kanjijourney.android.ui.theme.GlassBorder
import com.jworks.kanjijourney.android.ui.theme.GlassTextMuted
import com.jworks.kanjijourney.android.ui.theme.GlassTextPrimary
import com.jworks.kanjijourney.android.ui.theme.GlassTextSecondary
import com.jworks.kanjijourney.android.ui.theme.GlassTopBar
import com.jworks.kanjijourney.core.domain.model.GradeMastery
import com.jworks.kanjijourney.core.domain.model.MasteryLevel
import com.jworks.kanjijourney.core.domain.model.UserLevel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onKanjiClick: (Int) -> Unit = {},
    onRadicalClick: (Int) -> Unit = {},
    onWordOfDayClick: (Long) -> Unit = {},
    onShopClick: () -> Unit = {},
    onSettingsClick: () -> Unit = {},
    onSubscriptionClick: () -> Unit = {},
    onProgressClick: () -> Unit = {},
    onAchievementsClick: () -> Unit = {},
    onFeedbackClick: () -> Unit = {},
    viewModel: HomeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    // Refresh profile data (XP, level, streak) when returning from a game session
    val lifecycleOwner = LocalLifecycleOwner.current
    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) {
                viewModel.refresh()
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    Scaffold(
        containerColor = GlassBackground,
        topBar = {
            GlassTopBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("KanjiJourney", color = GlassTextPrimary)
                        if (uiState.isAdmin) {
                            Spacer(modifier = Modifier.padding(start = 8.dp))
                            Text(
                                text = uiState.effectiveLevel.displayName,
                                style = MaterialTheme.typography.labelSmall,
                                fontWeight = FontWeight.Bold,
                                color = when (uiState.effectiveLevel) {
                                    UserLevel.ADMIN -> Color(0xFFFF6B6B)
                                    UserLevel.PREMIUM -> Color(0xFFFFD700)
                                    UserLevel.FREE -> GlassTextSecondary
                                },
                                modifier = Modifier
                                    .background(
                                        color = Color.White.copy(alpha = 0.10f),
                                        shape = RoundedCornerShape(4.dp)
                                    )
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            )
                        }
                    }
                },
                actions = {
                    IconButton(onClick = onFeedbackClick) {
                        Icon(
                            Icons.Default.Email,
                            contentDescription = "Send Feedback",
                            tint = GlassTextSecondary
                        )
                    }
                    IconButton(onClick = onShopClick) {
                        Text(
                            text = "J",
                            fontWeight = FontWeight.Bold,
                            fontSize = 16.sp,
                            color = Color(0xFFFFD700),
                            modifier = Modifier
                                .background(
                                    color = Color.White.copy(alpha = 0.10f),
                                    shape = RoundedCornerShape(6.dp)
                                )
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                    IconButton(onClick = onSettingsClick) {
                        Icon(
                            Icons.Default.Settings,
                            contentDescription = "Settings",
                            tint = GlassTextSecondary
                        )
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(GlassBackground)
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp)
        ) {
            // Profile summary
            GlassCard(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = uiState.tierNameJp,
                                style = MaterialTheme.typography.labelMedium,
                                color = Color(0xFFFF6B35),
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = "${uiState.tierName} - Lv.${uiState.displayLevel}",
                                style = MaterialTheme.typography.titleLarge,
                                fontWeight = FontWeight.Bold,
                                color = GlassTextPrimary
                            )
                            Text(
                                text = "${uiState.profile.totalXp} XP",
                                style = MaterialTheme.typography.bodyMedium,
                                color = Color(0xFFFFD54F)
                            )
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text(
                                text = "${uiState.coinBalance.displayBalance} J Coins",
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFFFFD700),
                                modifier = Modifier.clickable(onClick = onShopClick)
                            )
                            if (uiState.coinBalance.needsSync) {
                                Text(
                                    text = "Pending sync...",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = GlassTextMuted
                                )
                            }
                            Text(
                                text = "${uiState.kanjiCount} kanji loaded",
                                style = MaterialTheme.typography.bodySmall,
                                color = GlassTextSecondary
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    LinearProgressIndicator(
                        progress = { uiState.profile.xpProgress },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(6.dp)
                            .clip(RoundedCornerShape(3.dp)),
                        color = Color(0xFFFF6B35),
                        trackColor = Color.White.copy(alpha = 0.08f)
                    )
                    if (uiState.nextTierName != null && uiState.nextTierLevel != null) {
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Next: ${uiState.nextTierName} at Lv.${uiState.nextTierLevel}",
                            style = MaterialTheme.typography.bodySmall,
                            color = GlassTextSecondary
                        )
                    }
                }
            }

            // Upgrade banner for free users
            if (!uiState.isPremium && !uiState.isAdmin) {
                Spacer(modifier = Modifier.height(8.dp))
                GlassCard(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable(onClick = onSubscriptionClick),
                    borderColor = Color(0xFFFFD700).copy(alpha = 0.35f)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = "Upgrade to Premium",
                                style = MaterialTheme.typography.labelLarge,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFFFFD700)
                            )
                            Text(
                                text = "Unlock all modes, J Coins & more",
                                style = MaterialTheme.typography.labelSmall,
                                color = Color(0xFFFFD700).copy(alpha = 0.7f)
                            )
                        }
                        Text(
                            text = "$4.99/mo",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFFFFD700)
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Streak card
            GlassCard(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "${uiState.profile.currentStreak}",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFFFF6B35)
                        )
                        Text(
                            text = "Day Streak",
                            style = MaterialTheme.typography.labelSmall,
                            color = GlassTextSecondary
                        )
                    }
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "${uiState.collectedKanjiCount}",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFF9C27B0)
                        )
                        Text(
                            text = "Collected",
                            style = MaterialTheme.typography.labelSmall,
                            color = GlassTextSecondary
                        )
                    }
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "${uiState.flashcardDeckCount}",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFFFF6B35)
                        )
                        Text(
                            text = "Decks",
                            style = MaterialTheme.typography.labelSmall,
                            color = GlassTextSecondary
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Word of the Day
            uiState.wordOfTheDay?.let { wotd ->
                GlassCard(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { onWordOfDayClick(wotd.id) },
                    borderColor = Color(0xFFFFD54F).copy(alpha = 0.28f)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "Word of the Day",
                                style = MaterialTheme.typography.labelMedium,
                                color = Color(0xFFFFD54F)
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = wotd.reading,
                                style = MaterialTheme.typography.bodySmall,
                                color = GlassTextSecondary
                            )
                            Text(
                                text = wotd.primaryMeaning,
                                style = MaterialTheme.typography.bodyMedium,
                                color = GlassTextPrimary
                            )
                        }
                        Text(
                            text = wotd.kanjiForm,
                            fontSize = 40.sp,
                            fontWeight = FontWeight.Bold,
                            color = GlassTextPrimary
                        )
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))
            }

            // Learning Path
            Text(
                text = "Learning Path",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = GlassTextPrimary
            )
            Spacer(modifier = Modifier.height(8.dp))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                LearningPathCard(
                    title = "Hiragana",
                    subtitle = "ひらがな",
                    progress = uiState.hiraganaProgress,
                    color = Color(0xFFE91E63)
                )
                LearningPathCard(
                    title = "Katakana",
                    subtitle = "カタカナ",
                    progress = uiState.katakanaProgress,
                    color = Color(0xFF00BCD4)
                )
                LearningPathCard(
                    title = "Radicals",
                    subtitle = "部首",
                    progress = uiState.radicalProgress,
                    color = Color(0xFF795548)
                )
                uiState.gradeMasteryList.forEach { mastery ->
                    LearningPathCard(
                        title = "Grade ${mastery.grade}",
                        subtitle = "漢字",
                        progress = mastery.masteryScore,
                        color = Color(0xFFFF6B35)
                    )
                }
            }

            // Grade Mastery Badges
            if (uiState.gradeMasteryList.isNotEmpty()) {
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    text = "Grade Mastery",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = GlassTextPrimary
                )
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    uiState.gradeMasteryList.forEach { mastery ->
                        GradeMasteryBadge(mastery = mastery)
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}


@Composable
private fun LearningPathCard(
    title: String,
    subtitle: String,
    progress: Float,
    color: Color
) {
    GlassCard(
        modifier = Modifier.size(width = 100.dp, height = 80.dp),
        borderColor = color.copy(alpha = 0.25f)
    ) {
        Column(
            modifier = Modifier.fillMaxSize().padding(8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(title, style = MaterialTheme.typography.labelMedium, fontWeight = FontWeight.Bold,
                color = GlassTextPrimary)
            Text(subtitle, style = MaterialTheme.typography.labelSmall,
                color = GlassTextSecondary, fontSize = 10.sp)
            Spacer(modifier = Modifier.height(4.dp))
            LinearProgressIndicator(
                progress = { progress.coerceIn(0f, 1f) },
                modifier = Modifier.fillMaxWidth().height(4.dp).clip(RoundedCornerShape(2.dp)),
                color = color,
                trackColor = Color.White.copy(alpha = 0.08f)
            )
            Text("${(progress * 100).toInt()}%", style = MaterialTheme.typography.labelSmall,
                color = color, fontSize = 9.sp)
        }
    }
}

@Composable
private fun GradeMasteryBadge(mastery: GradeMastery) {
    val badgeAsset = when (mastery.masteryLevel) {
        MasteryLevel.BEGINNING -> "grade-beginning.png"
        MasteryLevel.DEVELOPING -> "grade-developing.png"
        MasteryLevel.PROFICIENT -> "grade-proficient.png"
        MasteryLevel.ADVANCED -> "grade-advanced.png"
    }

    val ringColor = when (mastery.masteryLevel) {
        MasteryLevel.BEGINNING -> Color(0xFFE57373)
        MasteryLevel.DEVELOPING -> Color(0xFFFFB74D)
        MasteryLevel.PROFICIENT -> Color(0xFF81C784)
        MasteryLevel.ADVANCED -> Color(0xFFFFD700)
    }

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(4.dp)
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.size(56.dp)
        ) {
            AssetImage(
                filename = badgeAsset,
                contentDescription = "${mastery.masteryLevel.label} badge",
                modifier = Modifier.size(56.dp),
                contentScale = ContentScale.Fit
            )
            Text(
                text = "G${mastery.grade}",
                style = MaterialTheme.typography.labelLarge,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
        }

        Text(
            text = mastery.masteryLevel.label,
            style = MaterialTheme.typography.labelSmall,
            color = ringColor,
            fontWeight = FontWeight.Bold,
            fontSize = 9.sp
        )
    }
}

package com.jworks.kanjijourney.android.ui.study

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.jworks.kanjijourney.android.ui.components.AssetImage
import com.jworks.kanjijourney.android.ui.theme.GlassBackground
import com.jworks.kanjijourney.android.ui.theme.GlassCard
import com.jworks.kanjijourney.android.ui.theme.GlassChip
import com.jworks.kanjijourney.android.ui.theme.GlassTextMuted
import com.jworks.kanjijourney.android.ui.theme.GlassTextPrimary
import com.jworks.kanjijourney.android.ui.theme.GlassTextSecondary
import com.jworks.kanjijourney.android.ui.theme.GlassTopBar
import com.jworks.kanjijourney.core.domain.model.GameMode
import com.jworks.kanjijourney.core.domain.model.KanaType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StudyScreen(
    onFeedbackClick: () -> Unit = {},
    onStartSession: (GameMode, KanaType?) -> Unit,
    onSubscriptionClick: () -> Unit = {},
    viewModel: StudyViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        containerColor = GlassBackground,
        topBar = {
            GlassTopBar(
                title = { Text("Study", color = GlassTextPrimary) },
                actions = {
                    IconButton(onClick = onFeedbackClick) {
                        Icon(
                            Icons.Default.Email,
                            contentDescription = "Send Feedback",
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
            // Content tabs: Kana | Radicals | Kanji
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                ContentTab.entries.forEach { tab ->
                    val isSelected = tab == uiState.selectedTab
                    GlassChip(
                        selected = isSelected,
                        selectedColor = Color(0xFFFF6B35),
                        modifier = Modifier.clickable { viewModel.selectTab(tab) }
                    ) {
                        Text(
                            text = tab.label,
                            fontSize = 14.sp,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                            color = if (isSelected) GlassTextPrimary else GlassTextSecondary
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Study Mode selector
            Text(
                text = "Study Mode",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = GlassTextPrimary
            )
            Spacer(modifier = Modifier.height(8.dp))

            val availableModes = viewModel.getAvailableModes(uiState.selectedTab)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                availableModes.forEach { mode ->
                    val isSelected = mode == uiState.selectedMode
                    val isAccessible = viewModel.isModeAccessible(mode)
                    val modeInfo = getModeInfo(mode)
                    val shape = RoundedCornerShape(12.dp)
                    val borderColor = when {
                        isSelected -> modeInfo.color.copy(alpha = 0.50f)
                        isAccessible -> Color.White.copy(alpha = 0.10f)
                        else -> Color.White.copy(alpha = 0.05f)
                    }
                    val cardGradient = Brush.linearGradient(
                        colors = when {
                            isSelected -> listOf(
                                modeInfo.color.copy(alpha = 0.25f),
                                modeInfo.color.copy(alpha = 0.10f)
                            )
                            isAccessible -> listOf(
                                Color.White.copy(alpha = 0.10f),
                                Color.White.copy(alpha = 0.04f)
                            )
                            else -> listOf(
                                Color.White.copy(alpha = 0.04f),
                                Color.White.copy(alpha = 0.02f)
                            )
                        }
                    )

                    Box(
                        modifier = Modifier
                            .size(width = 120.dp, height = 100.dp)
                            .clip(shape)
                            .background(cardGradient, shape)
                            .border(1.dp, borderColor, shape)
                            .clickable {
                                if (isAccessible) viewModel.selectMode(mode)
                                else onSubscriptionClick()
                            }
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(8.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            if (modeInfo.imageAsset != null) {
                                AssetImage(
                                    filename = modeInfo.imageAsset,
                                    contentDescription = modeInfo.label,
                                    modifier = Modifier.size(36.dp),
                                    contentScale = ContentScale.Fit
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                            }
                            Text(
                                text = modeInfo.label,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (isSelected || isAccessible) GlassTextPrimary else GlassTextMuted
                            )
                            if (!isAccessible && !uiState.isPremium) {
                                val trials = uiState.previewTrialsRemaining[mode] ?: 0
                                Text(
                                    text = if (trials > 0) "Preview ($trials)" else "Premium",
                                    fontSize = 9.sp,
                                    color = Color(0xFFFFD700)
                                )
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Source selector
            Text(
                text = "Source",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = GlassTextPrimary
            )
            Spacer(modifier = Modifier.height(8.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // "All" source
                SourceChip(
                    label = "All",
                    isSelected = uiState.selectedSource is StudySource.All,
                    onClick = { viewModel.selectSource(StudySource.All) }
                )

                // Flashcard deck source with dropdown
                var showDeckDropdown by remember { mutableStateOf(false) }
                val currentDeckSource = uiState.selectedSource as? StudySource.FromFlashcardDeck

                Column {
                    SourceChip(
                        label = if (currentDeckSource != null) "Deck: ${currentDeckSource.deckName}"
                        else "Flashcard Deck",
                        isSelected = uiState.selectedSource is StudySource.FromFlashcardDeck,
                        onClick = {
                            if (uiState.decks.isNotEmpty()) {
                                showDeckDropdown = true
                            }
                        }
                    )
                    DropdownMenu(
                        expanded = showDeckDropdown,
                        onDismissRequest = { showDeckDropdown = false }
                    ) {
                        uiState.decks.forEach { deck ->
                            DropdownMenuItem(
                                text = { Text(deck.name) },
                                onClick = {
                                    viewModel.selectSource(StudySource.FromFlashcardDeck(deck.id, deck.name))
                                    showDeckDropdown = false
                                }
                            )
                        }
                    }
                }

                // Collection source (kanji tab only)
                if (uiState.selectedTab == ContentTab.KANJI) {
                    SourceChip(
                        label = "Collection",
                        isSelected = uiState.selectedSource is StudySource.FromCollection,
                        onClick = { viewModel.selectSource(StudySource.FromCollection) }
                    )
                }
            }

            // Kana sub-filter (kana tab only)
            if (uiState.selectedTab == ContentTab.KANA) {
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "Kana Type",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = GlassTextPrimary
                )
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    KanaFilter.entries.forEach { filter ->
                        val isSelected = filter == uiState.kanaFilter
                        GlassChip(
                            selected = isSelected,
                            selectedColor = Color(0xFFE91E63),
                            modifier = Modifier.clickable { viewModel.selectKanaFilter(filter) }
                        ) {
                            Text(
                                text = filter.label,
                                fontSize = 13.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                                color = if (isSelected) GlassTextPrimary else GlassTextSecondary
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Start Session button
            val selectedMode = uiState.selectedMode
            val canStart = selectedMode != null && viewModel.isModeAccessible(selectedMode)

            Button(
                onClick = {
                    if (selectedMode != null) {
                        // For premium-gated modes, use a preview trial if not premium
                        if (!uiState.isPremium && !uiState.isAdmin) {
                            val needsTrial = selectedMode in listOf(
                                GameMode.WRITING, GameMode.VOCABULARY, GameMode.CAMERA_CHALLENGE
                            )
                            if (needsTrial) {
                                viewModel.usePreviewTrial(selectedMode)
                            }
                        }

                        val kanaType = when {
                            selectedMode == GameMode.KANA_RECOGNITION || selectedMode == GameMode.KANA_WRITING -> {
                                when (uiState.kanaFilter) {
                                    KanaFilter.HIRAGANA_ONLY -> KanaType.HIRAGANA
                                    KanaFilter.KATAKANA_ONLY -> KanaType.KATAKANA
                                    KanaFilter.MIXED -> KanaType.HIRAGANA // TODO: support mixed
                                }
                            }
                            else -> null
                        }
                        onStartSession(selectedMode, kanaType)
                    }
                },
                enabled = canStart,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFFFF6B35)
                )
            ) {
                Text(
                    text = "Start Session",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            if (!canStart && selectedMode != null && !uiState.isPremium) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Upgrade to Premium to unlock this mode",
                    fontSize = 12.sp,
                    color = Color(0xFFFFD700),
                    modifier = Modifier
                        .clickable(onClick = onSubscriptionClick)
                        .padding(4.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
private fun SourceChip(
    label: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    GlassChip(
        selected = isSelected,
        selectedColor = Color(0xFFFF6B35),
        modifier = Modifier.clickable(onClick = onClick)
    ) {
        Text(
            text = label,
            fontSize = 12.sp,
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
            color = if (isSelected) GlassTextPrimary else GlassTextSecondary
        )
    }
}

private data class ModeInfo(
    val label: String,
    val color: Color,
    val imageAsset: String?
)

private fun getModeInfo(mode: GameMode): ModeInfo {
    return when (mode) {
        GameMode.RECOGNITION -> ModeInfo("Recognition", Color(0xFF2196F3), "mode-recognition.png")
        GameMode.WRITING -> ModeInfo("Writing", Color(0xFF4CAF50), "mode-writing.png")
        GameMode.VOCABULARY -> ModeInfo("Vocabulary", Color(0xFFFF9800), "mode-vocabulary.png")
        GameMode.CAMERA_CHALLENGE -> ModeInfo("Camera", Color(0xFF9C27B0), "mode-camera.png")
        GameMode.KANA_RECOGNITION -> ModeInfo("Recognition", Color(0xFFE91E63), "mode-kana-recognition.png")
        GameMode.KANA_WRITING -> ModeInfo("Writing", Color(0xFF00BCD4), "mode-kana-writing.png")
        GameMode.RADICAL_RECOGNITION -> ModeInfo("Recognition", Color(0xFF795548), "mode-radical-recognition.png")
        GameMode.RADICAL_BUILDER -> ModeInfo("Builder", Color(0xFF795548), "mode-radical-builder.png")
    }
}

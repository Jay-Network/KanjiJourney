package com.jworks.kanjijourney.android.ui.games

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
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
import com.jworks.kanjijourney.android.ui.theme.GlassBorder
import com.jworks.kanjijourney.android.ui.theme.GlassTextPrimary
import com.jworks.kanjijourney.android.ui.theme.GlassTextSecondary
import com.jworks.kanjijourney.android.ui.theme.GlassTextMuted
import com.jworks.kanjijourney.android.ui.theme.GlassTopBar

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GamesScreen(
    onFeedbackClick: () -> Unit = {},
    onRadicalBuilder: () -> Unit,
    onTestMode: () -> Unit = {},
    onSubscriptionClick: () -> Unit = {},
    viewModel: GamesViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        containerColor = GlassBackground,
        topBar = {
            GlassTopBar(
                title = { Text("Play", color = GlassTextPrimary) },
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
            Text(
                text = "Game Modes",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = GlassTextPrimary
            )

            Spacer(modifier = Modifier.height(12.dp))

            GameCard(
                title = "Radical Builder",
                description = "Build kanji from radical parts",
                accentColor = Color(0xFF795548),
                imageAsset = "mode-radical-builder.png",
                isPlayable = true,
                onClick = onRadicalBuilder
            )

            Spacer(modifier = Modifier.height(12.dp))

            GameCard(
                title = "Test Mode",
                description = "Quiz yourself on grades, JLPT, kana, or radicals",
                accentColor = Color(0xFF2196F3),
                imageAsset = null,
                isPlayable = true,
                onClick = onTestMode
            )

            Spacer(modifier = Modifier.height(12.dp))

            GameCard(
                title = "Speed Challenge",
                description = "Answer as fast as you can before time runs out",
                accentColor = Color(0xFFFF5722),
                imageAsset = null,
                isPlayable = false,
                comingSoonLabel = "Coming Soon"
            )

            Spacer(modifier = Modifier.height(12.dp))

            GameCard(
                title = "Battle",
                description = "Challenge friends online",
                accentColor = Color(0xFF673AB7),
                imageAsset = null,
                isPlayable = false,
                comingSoonLabel = "Coming Soon"
            )

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
private fun GameCard(
    title: String,
    description: String,
    accentColor: Color,
    imageAsset: String?,
    isPlayable: Boolean,
    comingSoonLabel: String? = null,
    onClick: () -> Unit = {}
) {
    val shape = RoundedCornerShape(16.dp)
    val cardGradient = Brush.linearGradient(
        colors = if (isPlayable)
            listOf(Color.White.copy(alpha = 0.12f), Color.White.copy(alpha = 0.05f))
        else
            listOf(Color.White.copy(alpha = 0.05f), Color.White.copy(alpha = 0.02f))
    )
    val borderColor = if (isPlayable)
        accentColor.copy(alpha = 0.35f)
    else
        Color.White.copy(alpha = 0.08f)

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(100.dp)
            .clip(shape)
            .background(cardGradient, shape)
            .border(1.dp, borderColor, shape)
            .then(if (isPlayable) Modifier.clickable(onClick = onClick) else Modifier)
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Accent strip
            Box(
                modifier = Modifier
                    .width(4.dp)
                    .height(48.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(if (isPlayable) accentColor else accentColor.copy(alpha = 0.3f))
            )
            Spacer(modifier = Modifier.width(12.dp))
            if (imageAsset != null) {
                AssetImage(
                    filename = imageAsset,
                    contentDescription = title,
                    modifier = Modifier.size(56.dp),
                    contentScale = ContentScale.Fit
                )
                Spacer(modifier = Modifier.width(12.dp))
            }
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = if (isPlayable) GlassTextPrimary else GlassTextMuted
                )
                Text(
                    text = description,
                    fontSize = 12.sp,
                    color = if (isPlayable) GlassTextSecondary else GlassTextMuted
                )
            }
            if (comingSoonLabel != null) {
                Text(
                    text = comingSoonLabel,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    color = GlassTextMuted,
                    modifier = Modifier
                        .background(
                            color = Color.White.copy(alpha = 0.08f),
                            shape = RoundedCornerShape(6.dp)
                        )
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                )
            }
        }
    }
}

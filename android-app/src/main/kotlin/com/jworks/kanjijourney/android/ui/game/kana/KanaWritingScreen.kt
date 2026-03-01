package com.jworks.kanjijourney.android.ui.game.kana

import androidx.compose.runtime.Composable
import com.jworks.kanjijourney.android.ui.game.writing.WritingScreen
import com.jworks.kanjijourney.core.domain.model.GameMode
import com.jworks.kanjijourney.core.domain.model.KanaType

/**
 * Kana Writing screen — reuses the existing WritingScreen composable since the
 * writing mechanic (canvas + strokes) is identical. The GameEngine is already
 * configured to route KANA_WRITING through KanaQuestionGenerator.
 *
 */
@Composable
fun KanaWritingScreen(
    kanaType: KanaType,
    onBack: () -> Unit
) {
    WritingScreen(
        onBack = onBack,
        gameMode = GameMode.KANA_WRITING,
        kanaType = kanaType
    )
}

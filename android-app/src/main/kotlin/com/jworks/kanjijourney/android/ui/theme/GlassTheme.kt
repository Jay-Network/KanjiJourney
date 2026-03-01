package com.jworks.kanjijourney.android.ui.theme

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.jworks.kanjijourney.android.R

// ── Brand colors (per-app, used sparingly: borders, icon tints, glows) ──

object GlassBrand {
    val KanjiJourney = Color(0xFFFF6B35)   // warm orange
    val KanjiLens = Color(0xFF0D9488)    // teal
    val EigoQuest = Color(0xFF4A90D9)    // blue
    val EigoLens = Color(0xFF4F46E5)     // indigo

    // Current app brand — change this per app module
    val current = KanjiJourney
}

// ── Typography ──────────────────────────────────────────────────────

val DmSansFamily = FontFamily(
    Font(R.font.dm_sans_light, FontWeight.Light),
    Font(R.font.dm_sans_regular, FontWeight.Normal),
    Font(R.font.dm_sans_medium, FontWeight.Medium),
    Font(R.font.dm_sans_bold, FontWeight.Bold),
)

// ── Glass color palette ────────────────────────────────────────────

val GlassBackground = Color(0xFF050508)
val GlassSurfaceLight = Color(0xFF12121E)
val GlassSurfaceDark = Color(0xFF08080F)
val GlassBorder = GlassBrand.current.copy(alpha = 0.28f)
val GlassBorderHover = GlassBrand.current.copy(alpha = 0.45f)
val GlassTextPrimary = Color.White
val GlassTextSecondary = Color.White.copy(alpha = 0.65f)
val GlassTextMuted = Color.White.copy(alpha = 0.4f)

val GlassCardGradient: Brush
    get() = Brush.linearGradient(
        colors = listOf(
            Color.White.copy(alpha = 0.10f),
            Color.White.copy(alpha = 0.04f)
        )
    )

val GlassCardDisabledGradient: Brush
    get() = Brush.linearGradient(
        colors = listOf(
            Color.White.copy(alpha = 0.05f),
            Color.White.copy(alpha = 0.02f)
        )
    )

// ── Reusable glass composables ─────────────────────────────────────

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    shape: RoundedCornerShape = RoundedCornerShape(12.dp),
    borderColor: Color = GlassBorder,
    borderWidth: Dp = 1.dp,
    content: @Composable BoxScope.() -> Unit
) {
    Box(
        modifier = modifier
            .clip(shape)
            .background(GlassCardGradient, shape)
            .border(borderWidth, borderColor, shape),
        content = content
    )
}

@Composable
fun GlassChip(
    selected: Boolean,
    selectedColor: Color = Color(0xFFFF6B35),
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    val shape = RoundedCornerShape(6.dp)
    val bg = if (selected)
        selectedColor.copy(alpha = 0.30f)
    else
        Color.White.copy(alpha = 0.06f)
    val border = if (selected)
        selectedColor.copy(alpha = 0.40f)
    else
        Color.White.copy(alpha = 0.10f)

    Box(
        modifier = modifier
            .clip(shape)
            .background(bg, shape)
            .border(1.dp, border, shape)
            .padding(horizontal = 10.dp, vertical = 5.dp),
        content = content
    )
}

@Composable
fun GlassTopBar(
    title: @Composable () -> Unit,
    actions: @Composable RowScope.() -> Unit = {},
    navigationIcon: @Composable () -> Unit = {}
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color.White.copy(alpha = 0.10f),
                        Color.White.copy(alpha = 0.05f)
                    )
                )
            )
            .drawBehind {
                // Orange warmth at the top edge
                drawRect(
                    brush = Brush.verticalGradient(
                        colors = listOf(
                            GlassBrand.current.copy(alpha = 0.14f),
                            Color.Transparent
                        )
                    )
                )
                // Bottom border — orange-tinted divider
                drawLine(
                    color = GlassBrand.current.copy(alpha = 0.40f),
                    start = Offset(0f, size.height),
                    end = Offset(size.width, size.height),
                    strokeWidth = 1.dp.toPx()
                )
            }
            .padding(horizontal = 4.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
                .padding(horizontal = 4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            navigationIcon()
            Box(
                modifier = Modifier.weight(1f),
                contentAlignment = Alignment.CenterStart
            ) {
                title()
            }
            Row(content = actions)
        }
    }
}

@Composable
fun GlassNavigationBar(
    modifier: Modifier = Modifier,
    content: @Composable RowScope.() -> Unit
) {
    val navBarPadding = WindowInsets.navigationBars.asPaddingValues()
    Box(
        modifier = modifier
            .fillMaxWidth()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color.White.copy(alpha = 0.05f),
                        Color.White.copy(alpha = 0.10f)
                    )
                )
            )
            .drawBehind {
                // Subtle orange glow at the top edge
                drawRect(
                    brush = Brush.verticalGradient(
                        colors = listOf(
                            GlassBrand.current.copy(alpha = 0.06f),
                            Color.Transparent
                        )
                    )
                )
                // Top divider line — orange-tinted
                drawLine(
                    color = GlassBrand.current.copy(alpha = 0.25f),
                    start = Offset(0f, 0f),
                    end = Offset(size.width, 0f),
                    strokeWidth = 1.dp.toPx()
                )
            }
            .padding(bottom = navBarPadding.calculateBottomPadding())
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(64.dp)
                .selectableGroup()
                .padding(horizontal = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            content = content
        )
    }
}

// ── Section background for visual rhythm ────────────────────────────

/**
 * Alternating section backgrounds to break visual monotony.
 * Use [variant] = true for darker sections, false for lighter tinted sections.
 */
@Composable
fun GlassSection(
    modifier: Modifier = Modifier,
    variant: Boolean = false,
    content: @Composable BoxScope.() -> Unit
) {
    val bg = if (variant) GlassSurfaceDark else GlassSurfaceLight
    Box(
        modifier = modifier
            .fillMaxWidth()
            .drawBehind {
                drawRect(color = bg)
                // Top gradient separator line
                drawRect(
                    brush = Brush.horizontalGradient(
                        colors = listOf(
                            Color.Transparent,
                            GlassBrand.current.copy(alpha = 0.15f),
                            Color.Transparent
                        )
                    ),
                    size = androidx.compose.ui.geometry.Size(size.width, 1.dp.toPx())
                )
            },
        content = content
    )
}

// ── Utility: brand-tinted border color ──────────────────────────────

fun glassBorderColor(color: Color = GlassBrand.current, alpha: Float = 0.28f): Color =
    color.copy(alpha = alpha)

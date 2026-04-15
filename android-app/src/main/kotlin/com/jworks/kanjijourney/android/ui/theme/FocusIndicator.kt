package com.jworks.kanjijourney.android.ui.theme

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.border
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Adds a visible focus ring to any composable. When the element receives focus
 * (via keyboard, D-pad, or accessibility navigation), a colored border appears.
 *
 * @param shape The shape of the focus ring border.
 * @param ringColor The color of the focus ring. Defaults to the brand accent.
 * @param ringWidth The width of the focus ring border.
 */
fun Modifier.focusRing(
    shape: Shape = RoundedCornerShape(8.dp),
    ringColor: Color = Color.Unspecified,
    ringWidth: Dp = 2.dp
): Modifier = composed {
    var isFocused by remember { mutableStateOf(false) }
    val resolvedColor = if (ringColor == Color.Unspecified) {
        GlassBrand.current.copy(alpha = 0.7f)
    } else {
        ringColor
    }
    val borderColor by animateColorAsState(
        targetValue = if (isFocused) resolvedColor else Color.Transparent,
        animationSpec = tween(durationMillis = 150),
        label = "focusRingColor"
    )

    this
        .onFocusChanged { isFocused = it.isFocused }
        .border(ringWidth, borderColor, shape)
}

/**
 * Focus ring preset for circular elements (FABs, icon buttons).
 */
fun Modifier.focusRingCircle(
    ringColor: Color = Color.Unspecified,
    ringWidth: Dp = 2.dp
): Modifier = focusRing(
    shape = androidx.compose.foundation.shape.CircleShape,
    ringColor = ringColor,
    ringWidth = ringWidth
)

/**
 * Focus ring preset for text fields — uses a slightly wider ring.
 */
fun Modifier.focusRingTextField(
    shape: Shape = RoundedCornerShape(8.dp),
    ringColor: Color = Color.Unspecified,
    ringWidth: Dp = 2.dp
): Modifier = focusRing(
    shape = shape,
    ringColor = ringColor,
    ringWidth = ringWidth
)

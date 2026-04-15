package com.jworks.kanjijourney.android.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

// Warm, kid-friendly palette (legacy — kept for non-glass screens)
val Orange = Color(0xFFFF8C42)
val OrangeDark = Color(0xFFE07030)
val Teal = Color(0xFF26A69A)
val TealDark = Color(0xFF00897B)
val Gold = Color(0xFFFFD54F)
val GoldDark = Color(0xFFFFC107)
val Cream = Color(0xFFFFF8E1)
val CreamDark = Color(0xFF2C2C2C)

private val LightColors = lightColorScheme(
    primary = Orange,
    onPrimary = Color.White,
    secondary = Teal,
    onSecondary = Color.White,
    tertiary = Gold,
    onTertiary = Color.Black,
    background = Cream,
    onBackground = Color(0xFF1C1B1F),
    surface = Color.White,
    onSurface = Color(0xFF1C1B1F),
)

private val DarkColors = darkColorScheme(
    primary = OrangeDark,
    onPrimary = Color.White,
    secondary = TealDark,
    onSecondary = Color.White,
    tertiary = GoldDark,
    onTertiary = Color.Black,
    background = CreamDark,
    onBackground = Color(0xFFE6E1E5),
    surface = Color(0xFF1C1B1F),
    onSurface = Color(0xFFE6E1E5),
)

private val GlassDarkColors = darkColorScheme(
    primary = Color(0xFFFF6B35),
    onPrimary = Color.White,
    secondary = Color(0xFF26A69A),
    onSecondary = Color.White,
    tertiary = Color(0xFFFFD54F),
    onTertiary = Color.Black,
    background = Color(0xFF050508),
    onBackground = Color.White,
    surface = Color(0xFF12121E),
    onSurface = Color.White,
    surfaceVariant = Color(0xFF08080F),
    onSurfaceVariant = Color.White.copy(alpha = 0.65f),
)

private val GlassTypography = Typography(
    displayLarge = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Light, fontSize = 57.sp),
    displayMedium = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Light, fontSize = 45.sp),
    displaySmall = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Normal, fontSize = 36.sp),
    headlineLarge = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Normal, fontSize = 32.sp),
    headlineMedium = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Normal, fontSize = 28.sp),
    headlineSmall = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Medium, fontSize = 24.sp),
    titleLarge = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Medium, fontSize = 22.sp),
    titleMedium = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Medium, fontSize = 16.sp),
    titleSmall = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Medium, fontSize = 14.sp),
    bodyLarge = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Normal, fontSize = 16.sp),
    bodyMedium = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Normal, fontSize = 14.sp),
    bodySmall = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Normal, fontSize = 12.sp),
    labelLarge = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Medium, fontSize = 14.sp),
    labelMedium = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Medium, fontSize = 12.sp),
    labelSmall = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Medium, fontSize = 12.sp),
)

// ── Semantic color tokens (use instead of hardcoded hex values) ────────

/**
 * Game-mode accent colors. Used for category badges, card tints, and section headers.
 */
object GameColors {
    val Recognition = Color(0xFF2196F3)   // blue
    val Writing = Color(0xFFFF6B35)       // orange (matches brand)
    val Vocabulary = Color(0xFF673AB7)    // purple
    val Radical = Color(0xFF795548)       // brown
    val Hiragana = Color(0xFFE91E63)      // pink
    val Katakana = Color(0xFF00BCD4)      // cyan
    val Camera = Color(0xFF9C27B0)        // purple
    val Speed = Color(0xFFFF5722)         // deep orange
}

/**
 * Feedback/state colors for correct/incorrect, rewards, and status.
 */
object StateColors {
    val Correct = Color(0xFF4CAF50)
    val CorrectBackground = Color(0xFFE8F5E9)
    val Incorrect = Color(0xFFF44336)
    val IncorrectBackground = Color(0xFFFFEBEE)
    val Warning = Color(0xFFFF9800)
    val WarningLight = Color(0xFFFFA726)
    val Gold = Color(0xFFFFD700)
    val GoldLight = Color(0xFFFFD54F)
    val Info = Color(0xFF2196F3)
    val InfoDark = Color(0xFF1976D2)
    val InfoBrand = Color(0xFF1565C0)
}

/**
 * Mastery level colors for progress tracking.
 */
object MasteryColors {
    val Beginning = Color(0xFFE57373)
    val Developing = Color(0xFFFFB74D)
    val Proficient = Color(0xFF81C784)
    val Advanced = Color(0xFFFFD700)
}

/**
 * Shop/tutoring section colors.
 */
object ShopColors {
    val Accent = Color(0xFFE65100)           // primary orange CTA
    val AccentDark = Color(0xFFBF360C)       // AA-compliant on light backgrounds
    val GradientStart = Color(0xFFE65100)    // featured banner gradient
    val GradientEnd = Color(0xFFFF8F00)      // featured banner gradient
    val Unaffordable = Color(0xFFFF8A80)     // insufficient funds indicator
}

/**
 * Discovery/collection section colors.
 */
object DiscoveryColors {
    val CardBackground = Color(0xFF00BFA5)   // full-strength teal (use with low alpha for bg)
    val Text = Color(0xFF00695C)             // AA-compliant on light teal backgrounds
    val Badge = Color(0xFF00897B)            // NEW badge background (AA-large on white)
}

/**
 * Admin/debug UI colors.
 */
object DebugColors {
    val CardBackground = Color(0xFFFFF3E0)   // cream
    val Text = Color(0xFFBF360C)             // dark orange on cream
    val AdminBadge = Color(0xFFFF6B6B)       // admin level indicator
}

@Composable
fun KanjiJourneyTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    // Glass aesthetic is always active for now
    MaterialTheme(
        colorScheme = GlassDarkColors,
        typography = GlassTypography,
        content = content
    )
}

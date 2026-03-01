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
    labelSmall = TextStyle(fontFamily = DmSansFamily, fontWeight = FontWeight.Medium, fontSize = 11.sp),
)

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

package com.jworks.kanjijourney.android.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.unit.dp

/**
 * Centralized corner radius tokens for KanjiJourney.
 * Use these instead of ad-hoc RoundedCornerShape(N.dp) values.
 * Minimum corner radius is 8dp per L1 compliance.
 */
object KjShape {
    /** 8dp — smallest allowed radius: chips, badges, tags, list items */
    val Small = RoundedCornerShape(8.dp)

    /** 10dp — detail panels, kanji cards */
    val MediumLarge = RoundedCornerShape(10.dp)

    /** 12dp — primary cards (GlassCard), buttons, containers */
    val Large = RoundedCornerShape(12.dp)

    /** 16dp — hero cards, login form, dialog backgrounds */
    val ExtraLarge = RoundedCornerShape(16.dp)

    /** 20dp — large promotional banners */
    val XXL = RoundedCornerShape(20.dp)

    /** 24dp — chat bubbles, pill-shaped inputs */
    val Pill = RoundedCornerShape(24.dp)
}

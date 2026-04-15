package com.jworks.kanjijourney.android.ui.theme

import androidx.compose.ui.unit.dp

/**
 * Centralized spacing tokens for KanjiJourney.
 * Use these instead of ad-hoc N.dp padding/margin values.
 */
object KjSpacing {
    /** 2dp — tight inline spacing (icon-to-label in status rows) */
    val XXS = 2.dp

    /** 4dp — minimal gaps (chip padding, inner badge spacing) */
    val XS = 4.dp

    /** 6dp — small gaps (tab padding, chip rows) */
    val SM = 6.dp

    /** 8dp — standard inner padding (list item gaps, section spacing) */
    val MD = 8.dp

    /** 10dp — comfortable padding (chip horizontal padding) */
    val MDPlus = 10.dp

    /** 12dp — card inner padding, row padding, input bar padding */
    val LG = 12.dp

    /** 16dp — section padding, dialog padding, standard screen margins */
    val XL = 16.dp

    /** 20dp — form inner padding, generous card padding */
    val XXL = 20.dp

    /** 24dp — screen-edge padding, major section spacing */
    val XXXL = 24.dp

    /** 32dp — large vertical spacing between major screen sections */
    val Huge = 32.dp
}

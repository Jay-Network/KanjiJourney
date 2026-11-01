package com.jworks.kanjijourney.core

import com.jworks.kanjijourney.core.domain.model.LevelProgression
import kotlin.test.Test
import kotlin.test.assertEquals

class LevelProgressionTest {

    // New players who skip the placement test start at level 1 and need a kanji pool
    // (desk card desk-jworks44-kanjijourney-new-player-pool, option a; BUG-007)
    @Test
    fun levelsOneToThree_unlockGradeOne() {
        for (level in 1..3) {
            assertEquals(listOf(1), LevelProgression.getUnlockedGrades(level), "level $level")
        }
    }

    @Test
    fun levelFour_stillUnlocksGradeOne() {
        assertEquals(listOf(1), LevelProgression.getUnlockedGrades(4))
    }
}

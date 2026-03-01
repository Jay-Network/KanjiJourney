package com.jworks.kanjijourney.core.engine

import com.jworks.kanjijourney.core.domain.model.GradeMastery

fun interface GradeMasteryProvider {
    suspend fun getGradeMastery(grade: Int): GradeMastery
}

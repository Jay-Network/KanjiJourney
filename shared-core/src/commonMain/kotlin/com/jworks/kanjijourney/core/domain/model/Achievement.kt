package com.jworks.kanjijourney.core.domain.model

data class Achievement(
    val id: String,
    val progress: Int,
    val target: Int,
    val unlockedAt: Long? = null
)

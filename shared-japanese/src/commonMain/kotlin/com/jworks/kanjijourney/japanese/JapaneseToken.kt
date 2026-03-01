package com.jworks.kanjijourney.japanese

data class JapaneseToken(
    val surface: String,
    val reading: String,
    val startIndex: Int,
    val containsKanji: Boolean
)

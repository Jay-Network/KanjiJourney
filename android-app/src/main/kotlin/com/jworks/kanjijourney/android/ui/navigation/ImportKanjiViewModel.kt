package com.jworks.kanjijourney.android.ui.navigation

import androidx.lifecycle.ViewModel
import com.jworks.kanjijourney.core.domain.usecase.ImportKanjiUseCase
import com.jworks.kanjijourney.core.domain.usecase.ImportResult
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class ImportKanjiViewModel @Inject constructor(
    private val importKanjiUseCase: ImportKanjiUseCase
) : ViewModel() {

    /**
     * Receive kanji literals from deep link and immediately process them.
     * Returns import result summary.
     */
    suspend fun importFromDeepLink(kanjiLiterals: List<String>, source: String): ImportResult {
        importKanjiUseCase.receiveKanji(kanjiLiterals, source)
        return importKanjiUseCase.processPending()
    }
}

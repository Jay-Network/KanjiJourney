package com.jworks.kanjijourney.android.ui.leaderboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jworks.kanjijourney.core.domain.model.LeaderboardEntry
import com.jworks.kanjijourney.core.domain.repository.LeaderboardRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class LeaderboardUiState(
    val entries: List<LeaderboardEntry> = emptyList(),
    val currentUserEntry: LeaderboardEntry? = null,
    val isLoading: Boolean = true,
    val error: String? = null
)

@HiltViewModel
class LeaderboardViewModel @Inject constructor(
    private val leaderboardRepository: LeaderboardRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(LeaderboardUiState())
    val uiState: StateFlow<LeaderboardUiState> = _uiState.asStateFlow()

    init {
        loadLeaderboard()
    }

    fun refresh() {
        _uiState.value = _uiState.value.copy(isLoading = true, error = null)
        loadLeaderboard()
    }

    private fun loadLeaderboard() {
        viewModelScope.launch {
            try {
                val entries = leaderboardRepository.getTopUsers(10)
                val currentUser = entries.find { it.isCurrentUser }

                _uiState.value = LeaderboardUiState(
                    entries = entries,
                    currentUserEntry = currentUser,
                    isLoading = false
                )
            } catch (e: Exception) {
                _uiState.value = LeaderboardUiState(
                    isLoading = false,
                    error = "Could not load leaderboard"
                )
            }
        }
    }
}

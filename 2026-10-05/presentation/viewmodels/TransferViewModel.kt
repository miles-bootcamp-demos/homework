package com.pnc.miles.jetpackcomposedemos.features.transfer.presentation.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.pnc.miles.jetpackcomposedemos.features.artists.presentation.state.ArtistDirectoryState
import com.pnc.miles.jetpackcomposedemos.features.authentication.presentation.LoginUiState
import com.pnc.miles.jetpackcomposedemos.features.transfer.domain.Account
import com.pnc.miles.jetpackcomposedemos.features.transfer.domain.TransferFundsUseCase
import com.pnc.miles.jetpackcomposedemos.features.transfer.presentation.state.TransferUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class TransferViewModel @Inject constructor(
    private val transferFunds: TransferFundsUseCase
): ViewModel() {
    // TODO: no Android framework import anywhere in this file below this
    // point, other than androidx.lifecycle. Annotate the class with
    // @HiltViewModel and inject TransferFundsUseCase via an @Inject
    // constructor. Expose a StateFlow<TransferUiState>. Implement
    // attemptTransfer(amount, from, to) that launches a coroutine in
    // viewModelScope, calls the use case, and updates the state.

    private val _uiState = MutableStateFlow<TransferUiState>(TransferUiState.Idle)
    val uiState: StateFlow<TransferUiState> = _uiState.asStateFlow()

    fun attemptTransfer(
        amount: Double,
        from: Account,
        to: Account
    ) {
        viewModelScope.launch {
            // execute our use case
            transferFunds(
                amount = amount,
                from = from,
                to = to
            )
                .onSuccess {
                    _uiState.value = TransferUiState.Success
                }
                .onFailure { error ->
                    _uiState.value = TransferUiState.Error(error.message ?: "Unknown error")
                }
        }
    }
}
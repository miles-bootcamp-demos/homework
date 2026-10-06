package com.pnc.miles.jetpackcomposedemos.features.transfer.presentation.state

sealed class TransferUiState {
    object Idle : TransferUiState()
    object Success : TransferUiState()
    data class Error(val message: String) : TransferUiState()
}
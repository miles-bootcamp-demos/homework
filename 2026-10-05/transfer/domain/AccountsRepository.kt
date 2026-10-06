package com.pnc.miles.jetpackcomposedemos.features.transfer.domain

interface AccountsRepository {
    // TODO: declare a suspend function to perform a transfer between two
    // accounts for a given amount. Think about what parameters and return
    // type make sense given how it will be called from the UseCase.
    suspend fun transfer(fromAccount: Account, toAccount: Account, amount: Double): Result<Unit>
}
package com.pnc.miles.jetpackcomposedemos.features.transfer.domain

import com.pnc.miles.jetpackcomposedemos.features.transfer.data.TransferEligibilityService
import javax.inject.Inject

class TransferFundsUseCase @Inject constructor(
    private val accountsRepository: AccountsRepository,
    private val eligibilityService: TransferEligibilityService
) {
    // TODO: inject AccountsRepository and TransferEligibilityService via
    // an @Inject constructor. Implement operator fun invoke(amount, from, to)
    // as a suspend function returning Result<Unit> — check eligibility
    // first, then call the repository if eligible.
    suspend operator fun invoke(
        amount: Double,
        from: Account,
        to: Account
    ): Result<Unit> {
        if (!eligibilityService.canTransfer(
                amount = amount,
                from = from
            )) {
            return Result.failure(
                IllegalArgumentException("Invalid Amount")
            )
        }

        return accountsRepository.transfer(
            fromAccount = from,
            toAccount = to,
            amount = amount
        )
    }
}
package com.pnc.miles.jetpackcomposedemos.features.transfer.data

import com.pnc.miles.jetpackcomposedemos.features.transfer.domain.Account

class TransferEligibilityService {
    fun canTransfer(amount: Double, from: Account): Boolean {
        return amount > 0 && from.balance >= amount
    }
}
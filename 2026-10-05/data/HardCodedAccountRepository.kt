package com.pnc.miles.jetpackcomposedemos.features.transfer.data

import com.pnc.miles.jetpackcomposedemos.features.transfer.domain.Account
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class HardCodedArtistDataSource @Inject constructor() {
    suspend fun getAccounts(): List<Account> {
        return listOf(
            Account("a1", "Everyday Checking", "\u2022\u2022\u2022\u2022 4471", 4281.16),
            Account("a2", "High Yield Savings", "\u2022\u2022\u2022\u2022 9902", 18340.50),
            Account("a3", "Rewards Credit Card", "\u2022\u2022\u2022\u2022 2216", -612.44)
        )
    }
}
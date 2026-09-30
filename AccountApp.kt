package com.pnc.miles.jetpackcomposedemos

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute
import com.pnc.miles.jetpackcomposedemos.ui.theme.Account
import com.pnc.miles.jetpackcomposedemos.ui.theme.AccountListScreen

@Composable
fun AccountApp() {
    val navController = rememberNavController()
    val sampleAccounts = listOf(
        Account("a1", "Everyday Checking", "\u2022\u2022\u2022\u2022 4471", 4281.16),
        Account("a2", "High Yield Savings", "\u2022\u2022\u2022\u2022 9902", 18340.50),
        Account("a3", "Rewards Credit Card", "\u2022\u2022\u2022\u2022 2216", -612.44)
    )

    NavHost(
        navController = navController,
        startDestination = AccountRoute
    ) {
        composable<AccountRoute> {
            AccountListScreen(
                accounts = sampleAccounts,
                onAccountClick = {
                    navController.navigate(AccountDetailsRoute)
                }
            )
        }

        composable<AccountDetailsRoute> { backStackEntry ->
            val route = backStackEntry.toRoute<AccountDetailsRoute>()
            val accountId = route.id
            val account = sampleAccounts.find { it.id == accountId }

            if (account != null) {
                AccountDetails(account = account)
            }
            else {
                Text("Account not found")
                // TODO: create a NotFound composable
            }
        }
    }
}
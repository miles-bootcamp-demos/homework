package com.pnc.miles.jetpackcomposedemos

import kotlinx.serialization.Serializable

sealed interface AccountPlannerRoute

@Serializable
data object AccountRoute: AccountPlannerRoute

@Serializable
data class AccountDetailsRoute(
    val id: String
): AccountPlannerRoute
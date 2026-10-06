package com.pnc.miles.jetpackcomposedemos.features.transfer.domain

data class Account(
    val id: String,
    val name: String,
    val maskedNumber: String,
    val balance: Double
)

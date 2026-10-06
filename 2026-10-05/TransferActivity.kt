package com.pnc.miles.jetpackcomposedemos.features.transfer

//
// TransferActivity_Starter.kt
// Module 13 — Android Architecture Patterns
// Lab Exercise: Refactor TransferActivity
//
// SCENARIO
// The Activity below is a Massive Activity: it mixes networking, validation,
// and UI update logic in one class. Your task is to refactor it using the
// patterns from this module.
//
// REQUIREMENTS
// 1. Extract a TransferViewModel with ZERO Android framework imports beyond
//    androidx.lifecycle.
// 2. Extract a TransferFundsUseCase encapsulating the eligibility check and
//    the transfer call.
// 3. Inject the Repository and UseCase via Hilt (@Inject constructor,
//    @HiltViewModel) — no manual construction, no singletons.
// 4. The refactored ViewModel must be unit-testable using a fake repository,
//    with no real network or Hilt container required.
//
// Read through BeforeMassiveTransferActivity below first — really read it,
// don't skim. Naming what's wrong with it is part of the exercise. Then
// fill in the TODOs in the scaffolding beneath it.
//

import android.app.Activity
import android.widget.Toast
import com.pnc.miles.jetpackcomposedemos.features.transfer.domain.Account
import javax.inject.Inject
import kotlin.String

// MARK: - BEFORE: the Massive Activity (do not edit — refactor FROM this)

class BeforeMassiveTransferActivity : Activity() {
    lateinit var fromAccount: Account
    lateinit var toAccount: Account

    fun onTransferButtonClicked(amountText: String) {
        val amount = amountText.toDoubleOrNull()
        if (amount == null || amount <= 0) {
            Toast.makeText(this, "Please enter a valid amount", Toast.LENGTH_SHORT).show()
            return
        }
        if (fromAccount.balance < amount) {
            Toast.makeText(this, "Insufficient funds", Toast.LENGTH_SHORT).show()
            return
        }

        // Imagine a raw HTTP call inline here:
        // httpClient.post("/transfer", body = ...)
        // followed by manually updating a TextView, dismissing a dialog,
        // and navigating back — all mixed into this one function.
    }
}


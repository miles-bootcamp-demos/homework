@file:DependsOn("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.11.0")
import kotlinx.coroutines.*
    
data class Account(
    val id: String,
    val name: String,
    val balance: Double
)

sealed class TransferResult {
    data class Success(val confirmationId: String): TransferResult()
    data class Failure(val reason: String): TransferResult()
}

fun describe(result: TransferResult): String =
    when (result) {
        is TransferResult.Success -> "Transfer ${result.confirmationId} was successful!"
        is TransferResult.Failure -> "There was an issue with the transfer because ${result.reason}"
    }
    
fun Double.asCurrency(): String = String.format("$%.2f", this)

suspend fun fetchAccounts(): List<Account> {
    delay(500)
    val accounts = listOf(
        Account("001", "Savings-1", 6120.68),
        Account("002", "Savings-2", 1135.35),
        Account("003", "Checking-1", 436.79),
        Account("004", "Secret", -224.52)
    )
    return accounts
}

fun main() = runBlocking {
    fetchAccounts()
    
    val filteredAccounts = fetchAccounts()
        .filter { it.balance < 0 }
        
    val summedAccounts = fetchAccounts()
        .sumOf { it.balance }
    
    println(filteredAccounts)
    println(summedAccounts.asCurrency())
}


main()
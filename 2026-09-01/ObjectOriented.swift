
// ============================================================
// EXERCISE: Structs — Value Types
// Estimated time: 20 minutes
//
// Structs in Swift are MUCH more powerful than in C.
// They can have methods, computed properties, and protocol conformance.
// The key rule: assignment COPIES a struct. Two variables never
// share the same struct instance.
// ============================================================

import Foundation

// TODO 3a: Define a struct named Transaction with these stored properties:
//   id: String
//   date: Date
//   amount: Double
//   description: String
//   isDebit: Bool
//
// Add these computed properties:
//   formattedAmount: String
//     → returns "-$250.00" if isDebit, "+$250.00" if credit
//     → use String(format: "%.2f", abs(amount))
//
//   formattedDate: String
//     → use DateFormatter with dateStyle: .medium, timeStyle: .none
//
// Add a memberwise initializer (Swift gives you this FREE for structs —
// you do not need to write init() unless you want custom behavior).

struct Transaction {
    let id: String
    let date: Date
    let amount: Double
    var description: String
    let isDebit: Bool
    var isPending: Bool
    
    func formattedAmount(accountType: String) -> String {
        let formattedAmt = isDebit ? "-" : "+" + "\(String(format: "%.2f", abs(amount)))"
        return formattedAmt
    }
    
    // used code from dateFormatter() documentation
    func formattedDate(someDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: someDate)
    }
    
    mutating func markAsPending() {
        isPending = true
    }
    
}


// TODO 3b: Create two Transaction instances:
//   t1: a credit of $2,500.00 described as "Direct Deposit"
//   t2: a debit of $45.67 described as "Starbucks"
// Print their formattedAmount and description.

var t1 = Transaction(id: "001", date: Date(), amount: 2_500.00, description: "Direct Deposit", isDebit: false, isPending: false)
var t2 = Transaction(id: "002", date: Date(), amount: 45.67, description: "Starbucks", isDebit: true, isPending: false)
print(t1.formattedAmount(accountType: "checking"))
print(t1.description)

// TODO 3c: Prove value semantics
// Assign t1 to a new variable t3.
// Try to change t3.description to "Modified".
// What happens? Why?
// Fix it by declaring t3 with var instead of let.
// Then change t3.description and print both t1.description and t3.description.
// Observe that t1 is unchanged. This is the key difference from classes.

var t3 = t1
t3.description = "Modified"
print(t3.description)
print(t1.description)


// TODO 3d: Add a mutating method to Transaction named markAsPending
// that sets a new stored property isPending: Bool = false to true.
// Call it on t2 and verify.

print(t2.isPending)
t2.markAsPending()
print(t2.isPending)

// ============================================================
// EXERCISE: Classes — Reference Types
// Estimated time: 20 minutes
//
// Classes add: inheritance, reference semantics (assignment shares
// the same object), and deinitializers.
// Use classes for: managers, services, view controllers — things
// that have IDENTITY and LIFECYCLE, not just data.
// ============================================================

// TODO 4a: Define a class named BankAccount with:
//   Stored properties:
//     id: String
//     accountNumber: String
//     balance: Double
//     owner: String
//
//   A designated initializer: init(id:accountNumber:owner:initialBalance:)
//   where initialBalance has a default of 0.0
//
//   Methods:
//     deposit(amount: Double) — adds to balance if amount > 0
//     withdraw(amount: Double) -> Bool — subtracts if amount > 0 and <= balance; returns success
//     printSummary() — prints "Account [accountNumber] | Owner: [owner] | Balance: $X.XX"

class BankAccount {
    let id: String
    let accountNumber: String
    var balance: Double
    let owner: String
    
    init(id: String, accountNumber: String, balance: Double = 0.0, owner: String) {
        self.id = id
        self.accountNumber = accountNumber
        self.balance = balance
        self.owner = owner
    }
    
    func deposit(amount: Double) {
        guard amount > 0 else {
            return
        }
        balance += amount
    }
    
    func withdraw(amount: Double) -> Bool {
        guard amount > 0 && amount <= balance else {
            return false
        }
        balance -= amount
        return true
    }
    
    func printSummary() {
        let summary = "Account \(accountNumber) | Owner: \(owner) | Balance: $\(String(format: "%.2f", abs(balance)))"
        print(summary)
    }
    
}

// TODO 4b: Create two BankAccount instances:
//   checking: id "acc_001", accountNumber "1234567890", owner "Jane Smith", balance 1_000.00
//   savings:  id "acc_002", accountNumber "0987654321", owner "Jane Smith", balance 5_000.00
// Call deposit and withdraw on checking. Print summaries for both.

let checking = BankAccount(id: "acc_001", accountNumber: "1234567890", balance: 1_000.00, owner: "Jane Smith")
let savings = BankAccount(id: "acc_002", accountNumber: "0987654321", balance: 5_000.00, owner: "Jane Smith")
//checking.printSummary()
checking.deposit(amount: 500)
//checking.printSummary()
checking.withdraw(amount: 200)
checking.printSummary()
savings.printSummary()

// TODO 4c: Prove reference semantics
// Assign checking to a new variable checkingRef.
// Call checkingRef.deposit(amount: 500)
// Print checking.balance and checkingRef.balance.
// Observe they are THE SAME object — both show the updated balance.
// Write a comment explaining why this is different from the struct in 3c.

let checkingRef = checking
checkingRef.deposit(amount: 500)
print(checking.balance)
print(checkingRef.balance)
// the checkingRef variable is pointing to the same object as checking
// this is because variables to class objects are a reference type
// so when I update the object from the new variable I created
// it's also updating the same object from the previous variable as well

// TODO 4d: Inheritance
// Define a class PremiumBankAccount that inherits from BankAccount.
// Add a stored property overdraftLimit: Double
// Override withdraw(amount:) so that withdrawal succeeds if
// amount <= balance + overdraftLimit (draws from overdraft if needed).
// Add a convenience initializer that takes the same params as BankAccount
// plus overdraftLimit.
//
// Test it: create a premium account with balance 100 and overdraftLimit 500.
// Withdraw 400 — should succeed (draws on overdraft).
// Withdraw 800 — should fail (exceeds balance + overdraftLimit).

class PremiumBankAccount: BankAccount {
    let overdraftLimit: Double
    
    init(id: String, accountNumber: String, balance: Double, owner: String, overdraftLimit: Double) {
        self.overdraftLimit = overdraftLimit
        super.init(id: id, accountNumber: accountNumber, balance: balance, owner: owner)
    }
    
    convenience override init(id: String, accountNumber: String, balance: Double, owner: String) {
        self.init(id: id, accountNumber: accountNumber, balance: balance, owner: owner, overdraftLimit: 0.0)
    }
    
    override func withdraw(amount: Double) -> Bool {
        return amount <= balance + overdraftLimit
    }
}

let premiumAccount = PremiumBankAccount(id: "0004", accountNumber: "1234-5678-90", balance: 100, owner: "Jane Doe", overdraftLimit: 500)
print(premiumAccount.withdraw(amount: 400))
print(premiumAccount.withdraw(amount: 800))

// ============================================================
// EXERCISE: Enumerations
// Estimated time: 15 minutes
//
// Swift enums are the richest in any mainstream language.
// They can carry associated values — meaning each case can
// store different data. This replaces many patterns where
// Python/JS developers would use a dict or tuple.
// ============================================================

// TODO 5a: Define an enum TransactionType with cases:
//   credit, debit, transfer, fee
// Make it conform to String and CaseIterable:
//   enum TransactionType: String, CaseIterable

enum TransactionType: String, CaseIterable {
    case credit = "credit"
    case debit = "debit"
    case transfer = "transfer"
    case fee = "fee"
    
    func displayName() -> String {
        switch self {
        case .credit:
            return "Credit"
        case .debit:
            return "Debit"
        case .transfer:
            return "Transfer"
        case .fee:
            return "Fee"
        }
    }
}

// TODO 5b: Add a computed property displayName: String to TransactionType
// using a switch that returns:
//   credit   → "Credit"
//   debit    → "Debit"
//   transfer → "Transfer"
//   fee      → "Fee"


// TODO 5c: Enum with associated values
// Define an enum AccountError with these cases:
//   insufficientFunds(available: Double, requested: Double)
//   accountInactive
//   dailyLimitExceeded(limit: Double)
//   invalidAmount
//
// Write a function describeError(_ error: AccountError) -> String
// that uses a switch with associated value binding to return
// a user-friendly message for each case.
// Test it with all four cases.

enum AccountError {
    case insufficientFunds(available: Double, requested: Double)
    case accountInactive
    case dailyLimitExceeded(limit: Double)
    case invalidAmount
}

func describeError(_ error: AccountError) -> String {
    switch error {
    case .insufficientFunds(available: let available, requested: let requested):
        return "You have insufficient funds for the transaction (available: \(available), requested: \(requested))"
    case .accountInactive:
        return "Account is inactive"
    case .dailyLimitExceeded(limit: let limit):
        return "Daily limit exceeded: \(limit)"
    case .invalidAmount:
        return "Invalid amount"
    }
}

// TODO 5d: Iterate over all cases
// Using CaseIterable on TransactionType, print all transaction types
// and their raw values:
// for type in TransactionType.allCases { print(...) }
// Expected:
//   credit → "credit"
//   debit → "debit"
//   etc.

for transaction in TransactionType.allCases {
    print("\(transaction) → \(transaction.rawValue)")
}

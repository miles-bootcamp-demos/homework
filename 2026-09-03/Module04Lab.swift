// ============================================================
// MODULE 4: Swift Programming Fundamentals
// LAB — PNC Banking Domain Model
// Enterprise Mobile Application Development Bootcamp
// ============================================================
//
// OVERVIEW
// You are building the Swift data model layer for the PNC Mobile
// Banking application. This layer will be carried forward into
// Modules 6, 7, and 8 as the foundation of the real application.
//
// Every type you define here uses the Swift features from all
// three days of this module. Take time to read the full spec
// before writing any code.
//
// ESTIMATED TIME: 90–120 minutes
//
// ============================================================
// LAB SPEC
// ============================================================
//
// You will build five interconnected Swift types:
//
//   1. TransactionType enum
//   2. TransactionStatus enum
//   3. Transaction struct
//   4. Account class
//   5. AccountAnalytics struct
//
// And three protocols:
//
//   A. Summarizable       — any type that can produce a summary string
//   B. AccountOperations  — deposit, withdraw, transfer
//   C. AnalyticsProvider  — compute basic financial metrics
//
// The lab ends with an error handling system and a generic
// result reporting function that ties everything together.
//
// Read each section completely before implementing it.
// ============================================================

import Foundation

// ============================================================
// SECTION 1: Enumerations
// ============================================================

// TODO 1A: TransactionType
// Conform to: String, CaseIterable, Codable
// Cases:     credit, debit, transfer, fee
// Add computed property: isExpense: Bool
//   → true for .debit and .fee, false otherwise

enum TransactionType: String, CaseIterable, Codable {
    case credit, debit, transfer, fee
    
    var isExpense: Bool {
        switch self {
        case .debit, .fee:
            return true
        case .credit, .transfer:
            return false
        }
    }
}

// TODO 1B: TransactionStatus
// Conform to: String, Codable
// Cases:     pending, completed, failed, cancelled
// Add computed property: isTerminal: Bool
//   → true for .completed, .failed, .cancelled
//   → false for .pending (can still change)

enum TransactionStatus: String, Codable {
    case pending, completed, failed, cancelled
    
    var isTerminal: Bool {
        switch self{
        case .completed, .failed, .cancelled:
            return true
        case .pending:
            return false
        }
    }
}

// ============================================================
// SECTION 2: Transaction Struct
// ============================================================

// TODO 2: Define struct Transaction conforming to:
//   Identifiable, Codable, Equatable, Hashable, Summarizable (see Section 4A)
//
// Stored properties:
//   id: String                (unique identifier, default to UUID().uuidString)
//   date: Date
//   amount: Double            (always positive — type determines direction)
//   description: String
//   type: TransactionType
//   status: TransactionStatus (default: .completed)
//   category: String?
//   merchantName: String?
//
// Computed properties:
//   formattedAmount: String
//     → "-$X.XX" for expenses (type.isExpense == true)
//     → "+$X.XX" for income/credit
//
//   formattedDate: String
//     → Use DateFormatter with dateStyle: .medium, timeStyle: .short
//
//   resolvedCategory: String
//     → Returns category if non-nil, "Uncategorized" otherwise
//
// Custom initializer (all params except id, status, category, merchantName
// should be required; the rest should have defaults):
//   init(date:amount:description:type:status:category:merchantName:)

struct Transaction: Identifiable, Codable, Equatable, Hashable, Summarizable {
    var id: String = UUID().uuidString
    let date: Date
    let amount: Double
    var description: String
    let type: TransactionType
    var status: TransactionStatus
    let category: String?
    let merchantName: String?
    
    var summary: String {
        let isExpense = type.isExpense ? "" : " not"
        return "\(formattedDate) - \(formattedAmount) is\(isExpense) an expense - \(description)"
    }
    
    var formattedAmount: String {
        let prefix = type.isExpense ? "-" : "+"
        return "\(prefix)$\(String(format: "%.2f", amount))"
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    var resolvedCategory: String {
        if let category = category {
            return category
        } else {
            return "Uncategorized"
        }
    }
    
    init(date: Date, amount: Double, description: String, type: TransactionType, status: TransactionStatus = .completed, category: String?, merchantName: String?) {
        self.date = date
        precondition(amount >= 0)
        self.amount = amount
        self.description = description
        self.type = type
        self.status = status
        self.category = category
        self.merchantName = merchantName
    }
}

// ============================================================
// SECTION 3: Account Class
// ============================================================

// TODO 3A: Define protocol AccountOperations (see Section 4B)
// before defining Account, because Account will conform to it.
// (Define the protocol in Section 4B, then add conformance to Account here)

protocol AccountOperations {
    func deposit(amount: Double) throws
    func withdraw(amount: Double) throws
    func transfer(amount: Double, to destination: BankAccount) throws
}


// TODO 3B: Define class BankAccount conforming to:
//   Identifiable, AccountOperations, Summarizable
//
// Stored properties:
//   id: String
//   accountNumber: String
//   accountType: String          (e.g., "CHECKING", "SAVINGS")
//   nickname: String?
//   var balance: Double
//   var availableBalance: Double
//   let currency: String         (default "USD")
//   let isActive: Bool           (default true)
//   var transactions: [Transaction]
//
// Computed properties:
//   displayName: String          → nickname if non-nil, else accountType.capitalized
//   maskedAccountNumber: String  → "****" + last 4 digits
//   formattedBalance: String     → "$X.XX"
//   recentTransactions: [Transaction]  → last 5, sorted by date descending
//   pendingCount: Int            → count of transactions with status .pending
//
// Designated initializer:
//   init(id:accountNumber:accountType:nickname:initialBalance:currency:isActive:)
//
// Implement AccountOperations (see Section 4B for the protocol requirements).
// Use the AccountError enum from Section 4C.
//
// Also add:
//   func addTransaction(_ transaction: Transaction)
//     → appends to transactions AND updates balance:
//       if transaction.type.isExpense: balance -= transaction.amount
//       else:                          balance += transaction.amount
//       Update availableBalance to match balance.

class BankAccount: Identifiable, AccountOperations, Summarizable {
    let id: String
    let accountNumber: String
    let accountType: String
    let nickname: String?
    var balance: Double
    var availableBalance: Double
    let currency: String
    let isActive: Bool
    var transactions: [Transaction]
    
    var summary: String {
        return "\(displayName) \(maskedAccountNumber) has a balance of $\(String(format: "%.2f", balance))"
    }
    
    var displayName: String {
        if let nickname = nickname {
            return nickname
        } else {
            return accountType.capitalized
        }
    }
    
    var maskedAccountNumber: String {
        return "****\(String(accountNumber.suffix(4)))"
    }
    
    var formattedBalance: String {
        return "$\(String(format: "%.2f", balance))"
    }
    
    var recentTransactions: [Transaction] {
        let sortedTransactions = transactions.sorted { $0.date > $1.date }
        return sortedTransactions.suffix(5)
    }
    
    var pendingCount: Int {
        return transactions.filter { $0.status == .pending }.count
    }
    
    init(id: String, accountNumber: String, accountType: String, nickname: String?, initialBalance: Double, currency: String = "USD", isActive: Bool = true, transactions: [Transaction]) {
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.nickname = nickname
        balance = initialBalance
        availableBalance = initialBalance
        self.currency = currency
        self.isActive = isActive
        self.transactions = transactions
    }
    
    func deposit(amount: Double) throws {
        // amount needs to be greater than 0
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        
        let transaction = Transaction(date: Date(), amount: amount, description: "Deposit", type: .credit, status: .completed, category: "Deposit", merchantName: nil)
        transactions.append(transaction)

        balance += amount
        availableBalance = balance
    }
    
    func withdraw(amount: Double) throws {
        // amount needs to be greater than 0
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        
        // balance needs to be greater than or equal to amount
        guard balance >= amount else {
            throw AccountOperationsError.insufficientFunds(available: balance, required: amount)
        }
        
        let transaction = Transaction(date: Date(), amount: amount, description: "Withdraw", type: .debit, status: .completed, category: "Withdraw", merchantName: nil)
        transactions.append(transaction)

        balance -= amount
        availableBalance = balance
    }
    
    func transfer(amount: Double, to destination: BankAccount) throws {
        
        // amount needs to be greater than 0
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        
        // balance needs to be greater than or equal to amount
        guard balance >= amount else {
            throw AccountOperationsError.insufficientFunds(available: balance, required: amount)
        }
        
        // account needs to be active
        guard isActive else {
            throw AccountOperationsError.accountInactive
        }
        
        // destination account can't be the same as the current account
        guard self.id != destination.id else {
            throw AccountOperationsError.transferToSameAccount
        }
        
        let transaction = Transaction(date: Date(), amount: amount, description: "Transfer", type: .transfer, status: .completed, category: "Transfer", merchantName: nil)
        transactions.append(transaction)
        destination.transactions.append(transaction)
        
        balance -= amount
        availableBalance = balance
        
        destination.balance += amount
        destination.availableBalance = balance
        
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        
        if transaction.type.isExpense {
            balance -= transaction.amount
        } else {
            balance += transaction.amount
        }
        
        availableBalance = balance
    }
    
    func getTransactions() -> [Transaction] {
        return transactions
    }
}

// ============================================================
// SECTION 4: Protocols
// ============================================================

// TODO 4A: Summarizable protocol
//   Required: var summary: String { get }
//   Default implementation via extension: func printSummary() — prints summary

protocol Summarizable {
    var summary: String { get }
}

extension Summarizable {
    func printSummary() {
        print(summary)
    }
}

// TODO 4B: AccountOperations protocol
//   func deposit(amount: Double) throws
//   func withdraw(amount: Double) throws
//   func transfer(amount: Double, to destination: BankAccount) throws
//
// These methods throw AccountOperationsError (define in Section 4C).


// TODO 4C: AccountOperationsError enum conforming to LocalizedError
// Cases:
//   invalidAmount
//   insufficientFunds(available: Double, required: Double)
//   accountInactive
//   transferToSameAccount
//   dailyLimitExceeded(limit: Double)
//
// Each case should have a meaningful errorDescription.

enum AccountOperationsError: LocalizedError {
    case invalidAmount
    case insufficientFunds(available: Double, required: Double)
    case accountInactive
    case transferToSameAccount
    case dailyLimitExceeded(limit: Double)
    
    var errorDescription: String? {
        switch self{
        case .invalidAmount:
            return "The amount must be greater than zero"
        case .insufficientFunds(available: let av, required: let req):
            return "Insufficient funds available: $\(String(format: "%.2f", av)), required: $\(String(format: "%.2f", req))"
        case .accountInactive:
            return "Account is inactive"
        case .transferToSameAccount:
            return "Transfer to the same account is not allowed"
        case .dailyLimitExceeded(limit: let lim):
            return "Daily limit exceeded. Limit: $\(String(format: "%.2f", lim))"
        }
    }
}

// ============================================================
// SECTION 5: Analytics
// ============================================================

// TODO 5A: AnalyticsProvider protocol
//   var totalCredits: Double { get }
//   var totalDebits: Double { get }
//   var netFlow: Double { get }         // credits - debits
//   var largestTransaction: Transaction? { get }
//   func monthlyTotal(month: Int, year: Int) -> Double
//   func transactionsByCategory() -> [String: [Transaction]]

protocol AnalyticsProvideer {
    var totalCredits: Double { get }
    var totalDebits: Double { get }
    var netFlow: Double { get }
    var largestTransaction: Transaction? { get }
    func monthlyTotal(month: Int, year: Int) -> Double
    func transactionsByCategory() -> [String: [Transaction]]
}

// TODO 5B: AccountAnalytics struct
// Stored property: transactions: [Transaction]
// Conform to AnalyticsProvider.
// Implement each requirement.
//
// Tips:
//   totalCredits: use .filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
//   transactionsByCategory: group by resolvedCategory using a Dictionary
//     (hint: use Dictionary(grouping:by:))
//   monthlyTotal: filter by Calendar.current month/year components and sum expense amounts

struct AccountAnalytics: AnalyticsProvideer {
    let transactions: [Transaction]
    
    var totalCredits: Double {
        return transactions.filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    var totalDebits: Double {
        return transactions.filter { $0.type.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    var netFlow: Double {
        return totalCredits - totalDebits
    }
    
    var largestTransaction: Transaction? {
        return transactions.max { $0.amount < $1.amount }
    }
    
    func monthlyTotal(month: Int, year: Int) -> Double {
        let calendar = Calendar.current
        
        var expense = 0.0
        for transaction in transactions {
            let components = calendar.dateComponents([.year, .month], from: transaction.date)
            
            guard let transactionYear = components.year, let transactionMonth = components.month else {
                continue
            }
            
            guard transactionYear == year, transactionMonth == month else {
                continue
            }
            
            expense += transaction.amount
        }
        return expense
        
    }
    
    func transactionsByCategory() -> [String: [Transaction]] {
        return Dictionary(grouping: transactions) { $0.resolvedCategory }
    }
}

// ============================================================
// SECTION 6: Generic Result Reporter
// ============================================================

// TODO 6: Write a generic function:
//   func reportResults<T: Summarizable>(_ items: [T], title: String)
//
// It should:
//   1. Print a header line: "=== [title] ==="
//   2. Print the item count: "[N] items"
//   3. Call printSummary() on each item
//   4. Print a footer: "=== End of [title] ==="
//
// The function must work for any type conforming to Summarizable —
// including both Transaction and BankAccount.

func reportResults<T: Summarizable>(_ items: [T], title: String) {
    var summary: String {
        var sum = "=== \(title) ===\n"
        
        sum += "\(items.count) items\n"
        
        for item in items {
            sum += "\(item.summary)\n"
        }
        
        sum += "=== End of \(title) ==="
        return sum
    }
    
    print(summary)
}

// ============================================================
// SECTION 7: INTEGRATION TEST — Tie it all together
// ============================================================

// TODO 7: Write a function named runlabDemo() that does the following:

func runlabDemo() {
    
    // 7A: Create at least two BankAccount instances:
    //   - A checking account with $3,500 initial balance
    //   - A savings account with $12,000 initial balance
    
    // TRANSACTIONS
    
    //    var id: String = UUID().uuidString
    //    let date: Date
    //    let amount: Double
    //    let description: String
    //    let type: TransactionType
    //    var status: TransactionStatus
    //    let category: String?
    //    let merchantName: String?
    
    // TRANSACTION TYPES: credit, debit, transfer, fee
    
    // TRANSACTION STATUS': pending, completed, failed, cancelled
    
    let transaction1 = Transaction(date: Date(timeIntervalSinceNow: -7_000_000), amount: 1_000.00, description: "Salary", type: .credit, status: .completed, category: "Income", merchantName: nil)
    let transaction2 = Transaction(date: Date(timeIntervalSinceNow: -6_000_000), amount: 1_000.00, description: "Salary", type: .credit, status: .completed, category: "Income", merchantName: nil)
    let transaction3 = Transaction(date: Date(timeIntervalSinceNow: -5_000_000), amount: 1_000.00, description: "Salary", type: .credit, status: .completed, category: "Income", merchantName: nil)
    let transaction4 = Transaction(date: Date(timeIntervalSinceNow: -4_000_000), amount: 1_000.00, description: "Salary", type: .credit, status: .completed, category: "Income", merchantName: nil)
    let transaction5 = Transaction(date: Date(timeIntervalSinceNow: -3_001_000), amount: 500.00, description: "Groceries", type: .debit, status: .completed, category: "Groceries", merchantName: "Tesco")
    let transaction6 = Transaction(date: Date(timeIntervalSinceNow: -3_900_000), amount: 10_000.00, description: "Lottery", type: .credit, status: .completed, category: "Lottery", merchantName: "Lottery")
    let transaction7 = Transaction(date: Date(timeIntervalSinceNow: -3_000_000), amount: 1_000.00, description: "Salary", type: .credit, status: .completed, category: "Income", merchantName: nil)
    let transaction8 = Transaction(date: Date(timeIntervalSinceNow: -4_200_000), amount: 50.00, description: "Youtube membership", type: .fee, status: .completed, category: "Entertainment", merchantName: "Youtube")
    
    // BANK ACCOUNTS
    
    //    id: String, accountNumber: String, accountType: String, nickname: String?, initialBalance: Double, currency: String = "USD", isActive: Bool = true, transactions: [Transaction]
        
    //    let id: String
    //    let accountNumber: String
    //    let accountType: String
    //    let nickname: String?
    //    var balance: Double
    //    var availableBalance: Double
    //    let currency: String
    //    let isActive: Bool
    //    var transactions: [Transaction]
    
    let transactions1: [Transaction] = [transaction1, transaction2, transaction3, transaction4, transaction5]
    let transacitons2: [Transaction] = [transaction1, transaction2, transaction6]
    
    
    let bankAccount1 = BankAccount(id: "ACC-001", accountNumber: "0001", accountType: "checking", nickname: "Checking", initialBalance: 3_500.00, transactions: transactions1)
   let bankAccount2 = BankAccount(id: "ACC-002", accountNumber: "0002", accountType: "savings", nickname: "Savings", initialBalance: 12_000.00, transactions: transacitons2)

    
    // 7B: Create at least five Transaction instances across different types
    //   and add them to the checking account using addTransaction(_:)
    //   Include: one credit, two debits, one fee, one transfer
    //   Verify the balance updates correctly after each addition.
    
    print(bankAccount1.summary)
    print(bankAccount2.summary)
    
    bankAccount1.addTransaction(transaction7)
    
    print(bankAccount1.summary)
    
    bankAccount1.addTransaction(transaction8)
    
    print(bankAccount1.summary)
    
    let _ = try? bankAccount1.withdraw(amount: 300.00)
    
    print(bankAccount1.summary)
    
    let _ = try? bankAccount2.withdraw(amount: 3_000.00)
    
    print(bankAccount2.summary)
    
    let _ = try? bankAccount2.transfer(amount: 1_000.00, to: bankAccount1)
    
    print(bankAccount1.summary)
    print(bankAccount2.summary)
    
    
    // 7C: Demonstrate error handling:
    //   - Try to withdraw more than the available balance → catch insufficientFunds
    //   - Try to deposit a negative amount → catch invalidAmount
    //   - Try to transfer to the same account → catch transferToSameAccount
    //   Print the localized error description for each caught error.
    do {
        _ = try bankAccount1.withdraw(amount: 10_000.00)
    } catch let error as AccountOperationsError {
            print(error.localizedDescription)
    } catch {
        print(error.localizedDescription)
    }

    do {
        _ = try bankAccount1.deposit(amount: -300.00)
    } catch let error as AccountOperationsError {
            print(error.localizedDescription)
    } catch {
        print(error.localizedDescription)
    }
    
    do {
        _ = try bankAccount1.transfer(amount: 1_000.00, to: bankAccount1)
    } catch let error as AccountOperationsError {
            print(error.localizedDescription)
    } catch {
        print(error.localizedDescription)
    }
    
    // 7D: Create an AccountAnalytics instance with the checking account's transactions.
    //   Print:
    //   - Total credits
    //   - Total debits
    //   - Net flow
    //   - The description and amount of the largest transaction
    //   - The transactions grouped by category (print each category and count)
    
    let analytics = AccountAnalytics(transactions: bankAccount1.getTransactions())
    print(analytics.totalCredits)
    print(analytics.totalDebits)
    print(analytics.netFlow)
    print(analytics.largestTransaction?.description ?? "empty")
    print(analytics.largestTransaction?.amount ?? 0)
    
    // 7E: Call reportResults with the checking account's transactions, title: "Checking Transactions"
    //   Call reportResults with [checkingAccount, savingsAccount], title: "All Accounts"
    
    reportResults(bankAccount1.getTransactions(), title: "Checking Transactions")
    
    let accounts: [BankAccount] = [bankAccount1, bankAccount2]
    reportResults(accounts , title: "All Accounts")
    
    // 7F: Demonstrate value vs. reference semantics:
    //   Copy one Transaction (struct) into a new variable. Modify the copy's description.
    //   Show the original is unchanged.
    //   Assign the checking account (class) to a new variable. Deposit $100 through the alias.
    //   Show both variables reflect the updated balance.
    
    var transaction9 = transaction8
    transaction9.description = "Twitch membership"
    reportResults(bankAccount1.getTransactions(), title: "Checking Transactions")
    
    let bankAccount3 = bankAccount1
    let _ = try? bankAccount3.deposit(amount: 100.00)
    reportResults(bankAccount1.getTransactions(), title: "Checking Transactions")
    reportResults(bankAccount3.getTransactions(), title: "Checking Transactions")

}

// TODO: Call runlabDemo() at the bottom of the file.


// ============================================================
// END OF LAB
// ============================================================
//
// SELF-ASSESSMENT CHECKLIST
// Before submitting, verify:
//   [ ] All five types compile without warnings
//   [ ] runlabDemo() runs to completion with no crashes
//   [ ] Each error case in 7C is handled and prints a clear message
//   [ ] Struct copy semantics are correctly demonstrated in 7F
//   [ ] Class reference semantics are correctly demonstrated in 7F
//   [ ] reportResults works for both Transaction and BankAccount
//   [ ] Analytics produce correct totals matching your transactions
// ============================================================

runlabDemo()

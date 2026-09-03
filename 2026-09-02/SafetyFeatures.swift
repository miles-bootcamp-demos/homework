// ============================================================
// MODULE 4: Swift Programming Fundamentals
// Day 3 Exercises — Protocols, ARC, Optionals, Error Handling
// Enterprise Mobile Application Development Bootcamp
// ============================================================
//
// Day 3 covers Swift's safety features — the ones that make
// iOS code reliable at enterprise scale. These concepts also
// directly underpin everything you will build in Modules 7–9.
//
// Part A: Protocols and Protocol-Oriented Programming
// Part B: Automatic Reference Counting (ARC) and memory safety
// Part C: Optionals — deep dive beyond the Day 1 preview
// Part D: Typed error handling
// Part E: Generics introduction
// ============================================================

import Foundation


// ============================================================
// PART A: PROTOCOLS
// ============================================================

// ============================================================
// EXERCISE 1: Defining and Adopting Protocols
// Estimated time: 20 minutes
//
// A protocol is a contract. Any type that says it conforms to
// a protocol MUST implement everything the protocol requires.
// This is Swift's primary mechanism for polymorphism —
// preferred over inheritance for most use cases.
//
// Python equivalent: Abstract Base Classes (abc.ABC)
// JS equivalent: TypeScript interfaces (but enforced at compile time)
// ============================================================

// TODO 1a: Define a protocol named Displayable with:
//   - A computed property: displayDescription: String  (get only)
//   - A method: printDetails()

protocol Displayable {
    var displayDescription: String { get }
    func printDetails()
}

// TODO 1b: Add a default implementation of printDetails() via a
// protocol extension. The default should just print displayDescription.
// This means conforming types do NOT need to implement printDetails()
// unless they want custom behavior.

extension Displayable {
    func printDetails() {
        print(displayDescription)
    }
}

// TODO 1c: Make Transaction (from ObjectOriented.swift) conform to Displayable.
// Paste your Transaction struct below and add ": Displayable".
// Implement displayDescription to return:
//   "[date] [description]: [formattedAmount]"
// e.g. "Jan 15, 2024 Direct Deposit: +$2500.00"
//
// Test it: create a transaction and call printDetails().

struct Transaction: Displayable {
    let id: String
    let date: Date
    let amount: Double
    var description: String
    let isDebit: Bool
    var isPending: Bool = false
    var displayDescription: String
    
    var formattedAmount: String {
        let prefix = isDebit ? "-" : "+"
        return "\(prefix)$\(String(format: "%.2f", abs(amount)))"
    }
    
    // used code from dateFormatter() documentation
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    mutating func markAsPending() {
        isPending = true
    }
    
    func printDetails() {
        print("\(formattedDate) \(description): \(formattedAmount)")
    }
    
}

let t1 = Transaction(id: "001", date: Date(), amount: 2_500.00, description: "Direct Deposit", isDebit: false, displayDescription: "iPhone 22 Max")
let t2 = Transaction(id: "002", date: Date(), amount: 500.00, description: "Costco", isDebit: true, displayDescription: "Groceries")
t1.printDetails()
t2.printDetails()

// TODO 1d: Protocol as a type
// Write a function named printAll(items: [Displayable]) that iterates
// the array and calls printDetails() on each item.
// Create an array containing at least two Transaction instances and
// pass it to printAll().
//
// The power: printAll doesn't know or care that the items are Transactions.
// Any future type that conforms to Displayable works automatically.

func printAll(items: [Displayable]) {
    items.forEach { $0.printDetails() }
}
let items: [Displayable] = [t1, t2]
printAll(items: items)

// ============================================================
// EXERCISE 2: Protocol-Oriented Design with Dependency Injection
// Estimated time: 20 minutes
//
// This pattern will appear in EVERY module from here forward.
// A protocol defines what a dependency does.
// Concrete types implement how it does it.
// The caller only knows about the protocol — never the concrete type.
// This is how we make code testable without a network.
// ============================================================

// TODO 2a: Define a protocol named AccountDataSource with:
//   func fetchBalance(for accountId: String) -> Double
//   func fetchTransactionCount(for accountId: String) -> Int

protocol AccountDataSource {
    func fetchBalance(for accountId: String) -> Double
    func fetchTransactionCount(for accountId: String) -> Int
}

// TODO 2b: Create a struct MockAccountDataSource that conforms to
// AccountDataSource and returns hardcoded values:
//   fetchBalance: always returns 4_250.75
//   fetchTransactionCount: always returns 47

struct MockAccountDataSource: AccountDataSource {
    @discardableResult
    func fetchBalance(for accountId: String) -> Double {
        return 4_250.75
    }
    @discardableResult
    func fetchTransactionCount(for accountId: String) -> Int {
        return 47
    }
}

// TODO 2c: Create a struct LiveAccountDataSource that conforms to
// AccountDataSource and simulates real behavior:
//   fetchBalance: returns a random Double between 100 and 50_000
//   fetchTransactionCount: returns a random Int between 1 and 500
//   Hint: Double.random(in: 100...50_000)

struct LiveAccountDataSource: AccountDataSource {
    @discardableResult
    func fetchBalance(for accountId: String) -> Double {
        return .random(in: 100.00...50_000.00)
    }
    @discardableResult
    func fetchTransactionCount(for accountId: String) -> Int {
        return .random(in: 1...500)
    }
}

// TODO 2d: Write a class AccountDashboard that:
//   - Has a stored property dataSource: AccountDataSource (the PROTOCOL — not a concrete type)
//   - Has an init(dataSource: AccountDataSource)
//   - Has a method showSummary(for accountId: String) that prints:
//       "Account [accountId]: Balance $X.XX | Transactions: N"
//
// Create two AccountDashboard instances — one with MockAccountDataSource,
// one with LiveAccountDataSource. Call showSummary on both.
// The showSummary method is IDENTICAL for both — only the data source differs.
// This is the dependency injection pattern you'll use throughout the bootcamp.

class AccountDashboard {
    let dataSource: AccountDataSource
    
    init(dataSource: AccountDataSource) {
        self.dataSource = dataSource
    }
    
    func showSummary(for accountId: String) {
        print("Account \(accountId): Balance $\(String(format: "%.2f", dataSource.fetchBalance(for: accountId))) | Transactions: \(dataSource.fetchTransactionCount(for: accountId))")
    }
}

let dashboard1 = AccountDashboard(dataSource: MockAccountDataSource())
dashboard1.showSummary(for: "123")
let dashboard2 = AccountDashboard(dataSource: LiveAccountDataSource())
dashboard2.showSummary(for: "456")

// ============================================================
// PART B: AUTOMATIC REFERENCE COUNTING
// ============================================================

// ============================================================
// EXERCISE 3: Retain Cycles and weak References
// Estimated time: 20 minutes
//
// ARC tracks how many things are pointing to each object.
// When the count reaches 0, Swift deallocates the memory.
// A retain cycle occurs when two objects hold STRONG references
// to each other — neither ever reaches 0, so neither is freed.
// This is a memory leak.
// ============================================================

// TODO 3a: Create a retain cycle, then fix it.
// Define two classes:
//
//   class Customer {
//       let name: String
//       var account: Account?    // optional — set after initialization
//       init(name: String) { ... }
//       deinit { print("Customer \(name) deallocated") }
//   }
//
//   class Account {
//       let number: String
//       var owner: Customer?     // THIS CREATES THE CYCLE
//       init(number: String) { ... }
//       deinit { print("Account \(number) deallocated") }
//   }
//
// Create instances in a do {} block (so they go out of scope):
//   do {
//       let customer = Customer(name: "Jane")
//       let account = Account(number: "ACC-001")
//       customer.account = account
//       account.owner = customer
//   }
// Run this. Do you see the deinit messages? You should NOT —
// because neither object is ever deallocated (retain cycle).
//
// TODO: Fix the cycle by making Account.owner a WEAK reference:
//   weak var owner: Customer?
// Run again. Now you should see both deinit messages.

class Customer {
    let name: String
    var account: Account?    // optional — set after initialization
    init(name: String) {
        self.name = name
        print("Customer \(name) allocated")
    }
    deinit { print("Customer \(name) deallocated") }
}

class Account {
    let number: String
    weak var owner: Customer?     // THIS CREATES THE CYCLE
    init(number: String) {
        self.number = number
        print("Account \(number) allocated")
    }
    deinit { print("Account \(number) deallocated") }
}

do {
    let customer = Customer(name: "Jane")
    let account = Account(number: "ACC-001")
    customer.account = account
    account.owner = customer
}

// TODO 3b: Capture lists in closures
// Closures can also create retain cycles when they capture self strongly.
// Complete this class:

class TransactionProcessor {
    let accountId: String
    var onComplete: (() -> Void)?

    init(accountId: String) {
        self.accountId = accountId
    }

    deinit {
        print("TransactionProcessor \(accountId) deallocated")
    }

    func startProcessing() {
        // TODO: Assign a closure to onComplete that captures self WEAKLY.
        // The closure should print "Processing complete for [accountId]"
        // Use [weak self] capture list and guard let self = self inside.
        //
        // Syntax:
        //   onComplete = { [weak self] in
        //       guard let self = self else { return }
        //       print("Processing complete for \(self.accountId)")
        //   }
        onComplete = { [weak self] in
            guard let self = self else { return }
            print("Processing complete for \(self.accountId)")
        }
    }

    func complete() {
        onComplete?()
    }
}

// TODO: Test in a do {} block:
//   do {
//       let processor = TransactionProcessor(accountId: "ACC-001")
//       processor.startProcessing()
//       processor.complete()
//   }
// You should see "Processing complete for ACC-001" followed by the deinit message.

do {
    let processor = TransactionProcessor(accountId: "ACC-001")
    processor.startProcessing()
    processor.complete()
}

// ============================================================
// PART C: OPTIONALS — DEEP DIVE
// ============================================================

// ============================================================
// EXERCISE 4: Safe Unwrapping Patterns
// Estimated time: 20 minutes
//
// Day 1 introduced optionals briefly. Now we go deep.
// Optional<T> is an enum: either .some(value) or .none
// Every unwrapping pattern is just sugar over this enum.
// ============================================================

// TODO 4a: Optional chaining
// You have this nested optional structure:
struct Address {
    let street: String
    let city: String
    let zip: String?    // zip can be absent
}

struct UserProfile {
    let name: String
    var address: Address?   // address can be absent
}

let user = UserProfile(name: "Jane Smith", address: Address(
    street: "123 Main St", city: "Columbus", zip: "43001"))
let userNoAddress = UserProfile(name: "Bob", address: nil)

// TODO: Use optional chaining to safely access the zip code.
// If the zip exists, print "ZIP: [zip]"
// If any step in the chain is nil, print "No ZIP available"
// Use nil coalescing ?? for the fallback.
//
// Hint: user.address?.zip ?? "No ZIP available"

if let zip = user.address?.zip {
    print("ZIP: \(zip)")
} else {
    print("No ZIP available")
}

// TODO 4b: if let with multiple bindings
// Write a function named transfer(from sourceId: String?, to destId: String?, amount: Double?)
// Use a SINGLE if let to unwrap all three optionals at once.
// (Swift lets you chain multiple bindings with commas in one if let)
// If all are present and amount > 0, print:
//   "Transfer $X.XX from [sourceId] to [destId] approved"
// Otherwise print: "Transfer failed: missing required fields"

func transfer(from sourceId: String?, to destId: String?, amount: Double?) {
    // TODO: implement with a single multi-binding if let
    if let sourceId, let destId, let amount, amount > 0 {
        print("Transfer $\(String(format: "%.2f", amount)) from \(sourceId) to \(destId) approved")
    } else {
        print("Transfer failed: missing required fields")
    }
}

transfer(from: "ACC-001", to: "ACC-002", amount: 500.0)     // approved
transfer(from: nil, to: "ACC-002", amount: 500.0)           // failed
transfer(from: "ACC-001", to: "ACC-002", amount: nil)       // failed


// TODO 4c: Optional map and flatMap
// Optionals have .map and .flatMap just like arrays.
// They apply a transformation only if the optional has a value.
let rawBalanceString: String? = "4250.75"
let rawInvalidString: String? = "abc"
let nilString: String? = nil

// TODO: Use optional .map to convert rawBalanceString to a formatted
// currency string IF it is non-nil AND parseable as a Double.
// Chain: rawBalanceString → Double? → formatted String?
// Hint: rawBalanceString.flatMap { Double($0) }.map { String(format: "$%.2f", $0) }
// Print the result for all three strings.
// Expected:
//   rawBalanceString → Optional("$4250.75")
//   rawInvalidString → nil
//   nilString → nil

let rawBalanceStringFormatted: String? = rawBalanceString.flatMap { Double($0) }.map { String(format: "$%.2f", $0) }
let rawInvalidStringFormatted: String? = rawInvalidString.flatMap { Double($0) }.map { String(format: "$%.2f", $0) }
let nilStringFormatted: String? = nilString.flatMap { Double($0) }.map { String(format: "$%.2f", $0) }

print("rawBalanceString → \(rawBalanceStringFormatted)")
print("rawInvalidString → \(rawInvalidStringFormatted)")
print("nilString → \(nilStringFormatted)")

// TODO 4d: Force unwrap — when and ONLY when it's safe
// There are exactly two situations where ! is acceptable:
//   1. URL literals you typed yourself (you KNOW they're valid)
//   2. IBOutlets (the storyboard guarantees they exist)
//
// Demonstrate the first:
let apiURL = URL(string: "https://api.pnc.com/v1")!
// This is safe because you WROTE the string. If it were user input, use if let.

// TODO: Write a comment explaining why you would NEVER write:
//   let userURL = URL(string: userInputString)!
// and what you would do instead.

// if the user were to give a blank value for their input
// then the program would crash, ideally the programmer
// shouldn't allow the user to input a URL, but if it
// were safe, then the programmer should use a if-let or
// guard-let to unwrap the optional in my opinional

// ============================================================
// PART D: TYPED ERROR HANDLING
// ============================================================

// ============================================================
// EXERCISE 5: Throwing Functions and Error Types
// Estimated time: 20 minutes
//
// Swift does NOT use exceptions like Python/Java.
// Instead: functions that can fail are marked throws.
// Callers MUST handle errors with do-catch or propagate with try?.
// The error types are DEFINED BY YOU — not the framework.
// This forces you to think about every failure mode up front.
// ============================================================

// TODO 5a: Define a comprehensive error enum for a transfer operation.
// Name it TransferError and conform to LocalizedError.
// Cases (with associated values where noted):
//   invalidAmount                    — amount <= 0
//   insufficientFunds(available: Double)
//   accountNotFound(id: String)
//   dailyLimitExceeded(limit: Double, attempted: Double)
//   networkUnavailable
//
// Implement var errorDescription: String? using a switch to return
// a user-facing message for each case.

enum TransferError: LocalizedError {
    case invalidAmount
    case insufficientFunds(available: Double)
    case accountNotFound(id: String)
    case dailyLimitExceeded(limit: Double, attempted: Double)
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "The amount must be greater than zero"
        case .insufficientFunds(available: let av):
            return "Insufficient funds available: $\(String(format: "%.2f", av))"
        case .accountNotFound(id: let id):
            return "Account with id: \(id) not found"
        case .dailyLimitExceeded(limit: let lim, attempted: let att):
            return "Daily limit exceeded. Limit: $\(String(format: "%.2f", lim)), attempted: $\(String(format: "%.2f", att))"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
}

// TODO 5b: Write a throwing function:
// func executeTransfer(amount: Double, fromBalance: Double, toAccountId: String,
//                      dailyUsed: Double, dailyLimit: Double) throws -> String
//
// Throw the appropriate TransferError for each condition:
//   amount <= 0                           → .invalidAmount
//   toAccountId.isEmpty                   → .accountNotFound(id: toAccountId)
//   amount > fromBalance                  → .insufficientFunds(available: fromBalance)
//   dailyUsed + amount > dailyLimit       → .dailyLimitExceeded(limit: dailyLimit, attempted: dailyUsed + amount)
//   (simulate network issue for a specific account id "ERR_NET") → .networkUnavailable
//
// On success, return: "Transfer of $X.XX to account [id] complete"

func executeTransfer(amount: Double, fromBalance: Double, toAccountId: String, dailyUsed: Double, dailyLimit: Double) throws -> String {
    
    guard amount > 0 else {
        throw TransferError.invalidAmount
    }
    
    guard !toAccountId.isEmpty else {
        throw TransferError.accountNotFound(id: toAccountId)
    }
    
    guard amount <= fromBalance else {
        throw TransferError.insufficientFunds(available: fromBalance)
    }
    
    guard dailyUsed + amount <= dailyLimit else {
        throw TransferError.dailyLimitExceeded(limit: dailyLimit, attempted: dailyUsed + amount)
    }
    
    if toAccountId == "ERR_NET" {
        throw TransferError.networkUnavailable
    }
    
    let success = "Transfer of $\(amount) to account \(toAccountId) complete"
    print(success)
    return success
}

// TODO 5c: Handle all error cases
// Call executeTransfer five times — once for each error case and once for success.
// Use a do-catch block that handles each specific TransferError case.
// For each case, print the localized error description.

do {
    let _ = try executeTransfer(amount: -100, fromBalance: 100, toAccountId: "123", dailyUsed: 100, dailyLimit: 200)
} catch let e as TransferError {
    print(e.localizedDescription)
}

do {
    let _ = try executeTransfer(amount: 100, fromBalance: 200, toAccountId: "", dailyUsed: 300, dailyLimit: 500)
} catch let e as TransferError {
    print(e.localizedDescription)
}

do {
    let _ = try executeTransfer(amount: 200, fromBalance: 100, toAccountId: "456", dailyUsed: 300, dailyLimit: 400)
} catch let e as TransferError {
    print(e.localizedDescription)
}

do {
    let _ = try executeTransfer(amount: 200, fromBalance: 200, toAccountId: "789", dailyUsed: 100, dailyLimit: 200)
} catch let e as TransferError {
    print(e.localizedDescription)
}

do {
    let _ = try executeTransfer(amount: 100, fromBalance: 200, toAccountId: "ERR_NET", dailyUsed: 300, dailyLimit: 500)
} catch let e as TransferError {
    print(e.localizedDescription)
}

do {
    let _ = try executeTransfer(amount: 100, fromBalance: 200, toAccountId: "012", dailyUsed: 300, dailyLimit: 500)
} catch let e as TransferError {
    print(e.localizedDescription)
}

// TODO 5d: try? — silently converting failure to nil
// Sometimes you don't need to know WHY something failed.
// Convert a throwing call to an optional with try?
//
// let result = try? executeTransfer(amount: -100, ...)
// result will be nil if it threw, or the String value if it succeeded.
// Print result using nil coalescing: result ?? "Transfer failed"
//
// Demonstrate both outcomes (success and failure).

let resultThrow = try? executeTransfer(amount: -100, fromBalance: 200, toAccountId: "345", dailyUsed: 300, dailyLimit: 500)
print(resultThrow ?? "Transfer failed")

let resultSuccess = try? executeTransfer(amount: 100, fromBalance: 200, toAccountId: "678", dailyUsed: 300, dailyLimit: 500)


// ============================================================
// PART E: GENERICS — INTRODUCTION
// ============================================================

// ============================================================
// EXERCISE 6: Writing Generic Functions and Types
// Estimated time: 15 minutes
//
// Generics let you write one function or type that works with
// ANY type satisfying certain requirements. The alternative —
// writing separate versions for Int, Double, String, etc. —
// violates the DRY principle at the language level.
// ============================================================

// TODO 6a: Write a generic function named printFirst<T>
// that takes an array of any type T and prints the first element,
// or "Array is empty" if it has no elements.
// Test with: [Int], [String], [Double]

func printFirst<T>(_ arr: [T]) {
    print(!arr.isEmpty ? "\(arr.first!)" : "Array is empty")
}

printFirst([1, 2, 3])
printFirst(["a", "b", "c"])
printFirst([1.00, 2.00, 3.00])
printFirst([])

// TODO 6b: Generic Stack
// Implement a generic value type Stack<Element>:
//   - Private stored property: items: [Element] = []
//   - mutating func push(_ item: Element)
//   - mutating func pop() -> Element?   (returns nil if empty)
//   - var top: Element?                  (returns last element without removing)
//   - var isEmpty: Bool
//   - var count: Int
//
// Test with a Stack<Double> (a transaction amount history):
//   Push: 250.00, 45.67, 1200.00
//   Pop one off: should return 1200.00
//   Print top: should be 45.67
//   Print count: should be 2

struct Stack<Element> {
    private var items: [Element] = []
    
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    mutating func pop() -> Element? {
        return items.popLast()
    }
    
    var top: Element? {
        return items.last
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var count: Int {
        return items.count
    }
    
}

var stack = Stack<Double>()
stack.push(250.00)
stack.push(45.67)
stack.push(1200.00)
stack.pop()
print(stack.top!)
print(stack.count)

// TODO 6c: Generic function with constraint
// Write a function named findLargest<T: Comparable>
// that takes [T] and returns the largest element, or nil if empty.
// Test with: [Int], [Double], [String]
// Hint: collection.max()

func findLargest<T: Comparable>(_ arr: [T]) -> T? {
    return arr.max()
}

let input1 = [1, 2, 3]
let input2 = [1.00, 2.00, 3.00]
let input3 = ["a", "b", "c"]

print(findLargest(input1)!)
print(findLargest(input2)!)
print(findLargest(input3)!)

// ============================================================
// END OF DAY 3 EXERCISES
// ============================================================
//
// YOU HAVE NOW COVERED ALL FIVE CONTENT BLOCKS OF MODULE 4.
// The capstone exercise ties everything together.
// Open Capstone/Capstone_Starter.swift to begin.
//
// FINAL REFLECTION:
// 1. What is a retain cycle? Draw it. How do you break one?
// 2. What is the difference between try, try?, and try!?
// 3. When would you use a protocol instead of a base class?
// 4. What constraint do you add to a generic type parameter
//    when you need to compare or sort elements?
// ============================================================

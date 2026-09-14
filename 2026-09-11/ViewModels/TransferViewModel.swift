//
//  TransferViewModel.swift
//  TransferViewControllerHW
//
//  Created by Miles Eidson on 9/13/26.
//

import SwiftUI
import Combine

final class TransferViewModel: ObservableObject {
    
    // TODO: no UIKit import anywhere in this file below this point.
    // Store an AccountsRepository and a TransferEligibilityService,
    // injected via the initializer. Expose onError and onSuccess
    // closures the View can observe. Implement
    // attemptTransfer(amount:from:to:) that checks eligibility first,
    // then calls the repository if eligible.
    
    let repository: any AccountsRepository
    let eligibilityService: TransferEligibilityService
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var state: ResultState = .waiting
    
    init(repository: AccountsRepository, eligibilityService: TransferEligibilityService) {
        self.repository = repository
        self.eligibilityService = eligibilityService
    }
    
    func attemptTransfer(amount: Double, from: Account, to: Account) async {
        self.state = .waiting
        
        do {
            try await repository.transfer(amount: amount, from: from, to: to)
        } catch {
            self.state = .failed(error: error)
        }
        
        self.state = .success
        
    }
    
}

struct TransferEligibilityService {
    // TODO: implement canTransfer(amount:from:) -> Result<Void, TransferError>
    // covering the same two rules as the BEFORE version above: amount must
    // be greater than zero, and the source account must have sufficient
    // balance.
    
    func canTransfer(amount: Decimal, from account: Account) -> (Void, TransferError?) {
        guard amount > 0 else {
            return (print("Please enter a valid amount"), TransferError.invalidAmount)
        }
        guard account.balance >= amount else {
            return (print("Insufficient funds"), TransferError.insufficientFunds)
        }
        return (print("Transfer successful"), nil as TransferError?)
    }

}

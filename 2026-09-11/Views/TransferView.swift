//
//  TransferView.swift
//  TransferViewControllerHW
//
//  Created by Miles Eidson on 9/13/26.
//

import SwiftUI

struct TransferView: View {
    
    @State var viewModel: TransferViewModel
    
    init(repository: AccountsRepository) {
        viewModel = TransferViewModel(repository: repository, eligibilityService: TransferEligibilityService())
    }
    
    @State var fromAccountName: String = ""
    @State var fromAccountNumber: String = ""
    @State var toAccountName: String = ""
    @State var toAccountNumber: String = ""
    @State var amount: Double = 0.0
    
    var body: some View {
        
        VStack {
            
            TextField("Enter the from Account name", text: $fromAccountName)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .font(.system(size: 15, weight: .heavy))
                .cornerRadius(10)
            TextField("Enter the from Account number", text: $fromAccountNumber)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .font(.system(size: 15, weight: .heavy))
                .cornerRadius(10)
            TextField("Enter the to Account name", text: $toAccountName)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .font(.system(size: 15, weight: .heavy))
                .cornerRadius(10)
            TextField("Enter the to Account number", text: $toAccountNumber)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .font(.system(size: 15, weight: .heavy))
                .cornerRadius(10)
            TextField("Enter the Transfer Amount", value: $amount, format: .number)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .font(.system(size: 15, weight: .heavy))
                .cornerRadius(10)
                .keyboardType(.decimalPad)
            
            Group {
                
                switch viewModel.state {
                    
                case .waiting:
                    
                    Button(action: {
                        let fromAccount = Account(name: fromAccountName, maskedNumber: fromAccountNumber, balance: Decimal(1_000.0))
                        let toAccount = Account(name: toAccountName, maskedNumber: toAccountNumber, balance: Decimal(50.0))
                        Task {
                            await viewModel.attemptTransfer(amount: amount, from: fromAccount, to: toAccount)
                        }
                    }, label: {
                        Text("Submit")
                    })
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .heavy))
                        .cornerRadius(10)
                    
                case .failed(error: let error):
                    
                    Button(action: {
                        let fromAccount = Account(name: fromAccountName, maskedNumber: fromAccountNumber, balance: Decimal(1_000.0))
                        let toAccount = Account(name: toAccountName, maskedNumber: toAccountNumber, balance: Decimal(50.0))
                        Task {
                            await viewModel.attemptTransfer(amount: amount, from: fromAccount, to: toAccount)
                        }
                    }, label: {
                        Text("Retry")
                        })
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .heavy))
                        .cornerRadius(10)
                    ErrorView(error: error)
                    
                case .success:
                    
                    Button(action: {
                        let fromAccount = Account(name: fromAccountName, maskedNumber: fromAccountNumber, balance: Decimal(1_000.0))
                        let toAccount = Account(name: toAccountName, maskedNumber: toAccountNumber, balance: Decimal(50.0))
                        Task {
                            await viewModel.attemptTransfer(amount: amount, from: fromAccount, to: toAccount)
                        }
                    }, label: {
                        Text("Submit")
                    })
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .heavy))
                        .cornerRadius(10)
                    Text("SUCCESS!")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 4)
                    
                    
                }
                
            }
            
        }

    }
    
}

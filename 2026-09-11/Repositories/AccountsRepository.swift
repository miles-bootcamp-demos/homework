//
//  AccountsRepository.swift
//  TransferViewControllerHW
//
//  Created by Miles Eidson on 9/13/26.
//

import SwiftUI

protocol AccountsRepository {
    // TODO: declare an async throws method to perform a transfer between
    // two accounts for a given amount. Think about what parameters and
    // return type make sense given how it will be called from the
    // ViewModel.
    func transfer(amount: Double, from: Account, to: Account) async throws
}

class AccountsRepositoryImpl: UIViewController, AccountsRepository {
    func transfer(amount: Double, from: Account, to: Account) async throws {
        var request = URLRequest(url: URL(string: "https://api.pncmobile.com/transfer")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode([
            "from": from.id.uuidString,
            "to": to.id.uuidString,
            "amount": "\(amount)",
        ])
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.showAlert(message: "Transfer failed. Please try again.")
                } else {
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }.resume()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Transfer", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

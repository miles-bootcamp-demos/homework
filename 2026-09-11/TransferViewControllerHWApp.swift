//
//  TransferViewControllerHWApp.swift
//  TransferViewControllerHW
//
//  Created by Miles Eidson on 9/13/26.
//

import SwiftUI

@main
struct TransferViewControllerHWApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.transferRepository, AccountsRepositoryImpl())
        }
    }
}

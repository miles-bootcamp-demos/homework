//
//  RepositoryInjectionKey.swift
//  TransferViewControllerHW
//
//  Created by Miles Eidson on 9/13/26.
//

import SwiftUI

struct AccountsRepositoryKey: EnvironmentKey {
    static let defaultValue: any AccountsRepository = AccountsRepositoryImpl()
}

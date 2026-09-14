//
//  EnvironmentExtensions.swift
//  TransferViewControllerHW
//
//  Created by Miles Eidson on 9/13/26.
//

import SwiftUI

extension EnvironmentValues {
    var transferRepository: any AccountsRepository {
        get { self[AccountsRepositoryKey.self] }
        set { self[AccountsRepositoryKey.self] = newValue }
    }
}

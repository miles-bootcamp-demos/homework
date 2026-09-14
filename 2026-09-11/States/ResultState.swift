//
//  ResultState.swift
//  TransferViewControllerHW
//
//  Created by Miles Eidson on 9/13/26.
//

import Foundation

enum ResultState {
    case waiting
    case success
    case failed(error: Error)
}

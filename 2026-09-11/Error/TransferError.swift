//
//  TransferError.swift
//  TransferViewControllerHW
//
//  Created by Miles Eidson on 9/13/26.
//

import SwiftUI

enum TransferError: Error, Equatable {
    case invalidAmount
    case insufficientFunds
}

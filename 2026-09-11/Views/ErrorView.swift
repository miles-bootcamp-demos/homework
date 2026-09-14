//
//  ErrorView.swift
//  TransferViewControllerHW
//
//  Created by Miles Eidson on 9/13/26.
//

import SwiftUI

struct ErrorView: View {
    
    let error: Error
    
    internal init(error: Error) {
        self.error = error
    }
    
    var body: some View {
        VStack {
            Text(error.localizedDescription)
                .foregroundColor(.gray)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .padding(.vertical, 4)
        }
    }
}

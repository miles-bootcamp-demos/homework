//
//  ContentView.swift
//  TransferViewControllerHW
//
//  Created by Miles Eidson on 9/13/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.transferRepository) private var transferRepository
    
    var body: some View {
        TransferView(repository: transferRepository)
    }
}

#Preview {
    ContentView()
}

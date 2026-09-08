//
//  ProductDetails.swift
//  SwiftUIViews
//
//  Created by Miles Eidson on 9/8/26.
//

import SwiftUI

struct ProductDetails: View {
    
    var product: Product
    
    var body: some View {
        @Bindable var prodBinding = product
        
        VStack {
            Text("\(product.id) - \(product.name)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Product #\(product.productNumber)")
                .font(.title)
            Text("Color: \(product.color)")
                .font(.title)
            Text("Price: $\(String(format: "%.2f", product.listPrice))")
                .font(.title)
        }
        .padding()
    }
    
}

#Preview {
    ContentView()
}

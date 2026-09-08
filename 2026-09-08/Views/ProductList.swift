//
//  ProductList.swift
//  SwiftUIViews
//
//  Created by Miles Eidson on 9/8/26.
//

import SwiftUI

struct ProductList: View {
    
    @State private var products: [Product] = []
    
    var body: some View {
        NavigationStack {
            List(products) { product in
                NavigationLink(product.name, value: product)
            }
            .navigationTitle("Products")
            .navigationDestination(for: Product.self) {
                selectedItem in
                ProductDetails(product: selectedItem)
            }
        }
        .task {
            loadData()
        }
    }
    
    func loadData() {
        products = [
            Product(id: 001, name: "Whole Milk", productNumber: "MLK-01", color: "White", listPrice: 5.99),
            Product(id: 002, name: "Skim Milk", productNumber: "MLK-02", color: "White", listPrice: 5.49),
            Product(id: 003, name: "2% Milk", productNumber: "MLK-03", color: "White", listPrice: 5.49),
            Product(id: 004, name: "Lactose Free Milk", productNumber: "MLK-04", color: "White", listPrice: 6.99)
        ]
    }
    
}

#Preview {
    ProductList()
}

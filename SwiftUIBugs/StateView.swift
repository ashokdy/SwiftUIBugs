//
//  StateView.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-01.
//

import SwiftUI

struct StateView: View {
    @State var count = 0
    @StateObject var leakyViewModel = DataViewModel()//LeakyViewModel()
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment \(leakyViewModel.message)") {
                count += 1
                leakyViewModel.loadData()
            }
        }
    }
}

#Preview {
    StateView()
}

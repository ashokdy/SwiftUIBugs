//
//  SpinnerAsync.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-01.
//

import Foundation

class AsyncViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var data: String?

    func fetchData() async {
        await MainActor.run {
            isLoading = true
        }
//        do {
//            let result = try await URLSession.shared.data(from: URL(string: "https://api.quotable.io/random")!)
                data = "Loaded!"            
//        }
//        catch {
//            
//        }
//        await MainActor.run {
//            isLoading = false// ❌ Forgot to set isLoading = false
//        }
    }
    
    deinit {
        print("AsyncViewModel deinitialized")
    }
}

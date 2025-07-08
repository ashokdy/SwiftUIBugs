//
//  MemoryViewModel.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-03.
//

import Foundation

class MemoryViewModel: ObservableObject {
    @Published var value = 0

    func load() {
        Task {
            await longRunning()
        }
    }

    func longRunning() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        print("Value: \(value)")
    }
    deinit {
        print("MemoryViewModel deinitialized")
    }
}

//
//  MemoryLeak.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-01.
//

import Foundation
class LeakyViewModel1: ObservableObject {
    @Published var time = 0

    init() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] _ in
            self?.time += 1
        }
    }

    deinit {
        print("LeakyViewModel - Deinit called")
    }
}

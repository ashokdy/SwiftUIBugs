//
//  BugUIThread.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-01.
//

import Foundation
class DataViewModel: ObservableObject {
    
    @Published var message = ""

    func loadData() {
        DispatchQueue.global().async {
            // Simulated delay
            sleep(1)
            DispatchQueue.main.async {
                self.message = "Hello, world!"  // 🔥 This crashes
            }
        }
    }
}

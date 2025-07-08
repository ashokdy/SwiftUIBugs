//
//  RaceCondition.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-05.
//

import Foundation
import Combine
import SwiftUI

class RaceViewModel: ObservableObject {
    var counter = 0

    func runRace() {
        for _ in 0..<5000 {
            Task.detached {
                self.counter += 1
            }
        }

        for _ in 0..<5000 {
            Task.detached {
                self.counter -= 1
            }
        }
    }
}

struct RaceScenario2: View {
    @StateObject var vm = RaceViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Button("Start Race") {
                vm.runRace()
            }
            Text("Counter: \(vm.counter)")
        }
        .padding()
    }
}

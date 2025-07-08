//
//  TimerViewmodel.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-03.
//

import Foundation

class TimerViewModel: ObservableObject {
    var count = 0
    var timer: Timer?

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] _ in
            self?.count += 1
            print("Count: \(self?.count ?? 0)")
        }
    }

    deinit {
        timer?.invalidate()
        print("TimerViewModel deinit")
    }
}

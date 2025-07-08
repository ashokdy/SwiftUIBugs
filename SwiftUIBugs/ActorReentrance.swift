//
//  ActorReentrance.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-06.
//

// SwiftUI Actor Reentrancy Race Condition Simulation
import SwiftUI

actor BankAccount {
    private var balance: Int = 100

    func withdraw(amount: Int) async -> Bool {
        if balance >= amount {
            balance -= amount
            print("✅ Sufficient balance: \(balance), preparing to withdraw \(amount)")
            await upload(amount: amount)
            print("💸 Withdrawal complete: \(amount), remaining: \(balance)")
            return true
        } else {
            print("❌ Insufficient funds for \(amount), current: \(balance)")
            return false
        }
    }

    nonisolated func upload(amount: Int) async {
        try? await Task.sleep(nanoseconds: 2_000_000_000) // Simulate delay
        print("[SAFE] 📤 Uploaded receipt for: \(amount)")
    }
    
    func getBalance() -> Int {
        return balance
    }
}

class ViewModel: ObservableObject {
    @Published var log: [String] = []
    private let account = BankAccount()

    func simulateRaceCondition() {
        log.removeAll()

        Task {
            let success = await account.withdraw(amount: 80)
            await MainActor.run {
                log.append("Task 1: Withdraw 80 - \(success ? "✅ Success" : "❌ Failed")")
            }
        }

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // Start slightly later
            let success = await account.withdraw(amount: 80)
            await MainActor.run {
                log.append("Task 2: Withdraw 80 - \(success ? "✅ Success" : "❌ Failed")")
            }
        }

        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            let balance = await account.getBalance()
            await MainActor.run {
                log.append("🏦 Final balance: \(balance)")
            }
        }
        
        nonisolated func logData(_ string: String, value: Int) async {
            await MainActor.run {
                log.append("\(string): \(value)")
            }
        }
    }
}

struct ActorReentrancyDemo: View {
    @StateObject var vm = ViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("💥 Actor Reentrancy Demo")
                .font(.title)

            Button("Simulate Race Condition") {
                vm.simulateRaceCondition()
            }
            .buttonStyle(.borderedProminent)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(vm.log, id: \ .self) { entry in
                        Text(entry)
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .padding(.horizontal)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding()
    }
}

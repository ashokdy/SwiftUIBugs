//
//  FixedActorReentrance.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-06.
//

// SwiftUI Actor Reentrancy Race Condition Simulation - Buggy vs Safe
import SwiftUI

// MARK: - Buggy Actor (suspends inside critical logic)
actor BuggyBankAccount {
    private var balance: Int = 100

    func withdraw(amount: Int) async -> Bool {
        if balance >= amount {
            print("[BUGGY] ✅ Sufficient balance: \(balance), preparing to withdraw \(amount)")
            try? await Task.sleep(nanoseconds: 2_000_000_000) // Simulate delay
            balance -= amount
            print("[BUGGY] 💸 Withdrawal complete: \(amount), remaining: \(balance)")
            return true
        } else {
            print("[BUGGY] ❌ Insufficient funds for \(amount), current: \(balance)")
            return false
        }
    }

    func getBalance() -> Int {
        return balance
    }
}

// MARK: - Safe Actor (isolates suspendable part)
actor SafeBankAccount {
    private var balance: Int = 100

    func withdraw(amount: Int) async -> Bool {
        guard balance >= amount else {
            print("[SAFE] ❌ Insufficient funds for \(amount), current: \(balance)")
            return false
        }
        balance -= amount
        print("[SAFE] ✅ Withdrawn \(amount), new balance: \(balance). Uploading receipt...")
        await uploadReceipt(amount)
        return true
    }

    nonisolated func uploadReceipt(_ amount: Int) async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        print("[SAFE] 📤 Uploaded receipt for: \(amount)")
    }

    func getBalance() -> Int {
        return balance
    }
}

class FixedViewModel: ObservableObject {
    @Published var buggyLog: [String] = []
    @Published var safeLog: [String] = []

    private let buggy = BuggyBankAccount()
    private let safe = SafeBankAccount()

    func runBuggySimulation() {
        buggyLog.removeAll()

        Task {
            let success = await buggy.withdraw(amount: 80)
            await MainActor.run {
                buggyLog.append("Task 1: Withdraw 80 - \(success ? "✅ Success" : "❌ Failed")")
            }
        }

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            let success = await buggy.withdraw(amount: 80)
            await MainActor.run {
                buggyLog.append("Task 2: Withdraw 80 - \(success ? "✅ Success" : "❌ Failed")")
            }
        }

        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            let balance = await buggy.getBalance()
            await MainActor.run {
                buggyLog.append("🏦 Final balance: \(balance)")
            }
        }
    }

    func runSafeSimulation() {
        safeLog.removeAll()

        Task {
            let success = await safe.withdraw(amount: 80)
            await MainActor.run {
                safeLog.append("Task 1: Withdraw 80 - \(success ? "✅ Success" : "❌ Failed")")
            }
        }

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            let success = await safe.withdraw(amount: 80)
            await MainActor.run {
                safeLog.append("Task 2: Withdraw 80 - \(success ? "✅ Success" : "❌ Failed")")
            }
        }

        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            let balance = await safe.getBalance()
            await MainActor.run {
                safeLog.append("🏦 Final balance: \(balance)")
            }
        }
    }
}

struct FixedActorReentrancyDemo: View {
    @StateObject var vm = FixedViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("🧪 Actor Reentrancy: Buggy vs Safe")
                .font(.title2)
                .padding(.top)

            HStack(spacing: 20) {
                Button("Run Buggy") {
                    vm.runBuggySimulation()
                }
                .buttonStyle(.borderedProminent)

                Button("Run Safe") {
                    vm.runSafeSimulation()
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("🐞 Buggy Actor")
                        .font(.headline)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(vm.buggyLog, id: \ .self) { entry in
                                Text(entry)
                                    .font(.system(size: 14, design: .monospaced))
                            }
                        }
                    }
                }

                VStack(alignment: .leading) {
                    Text("🛡️ Safe Actor")
                        .font(.headline)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(vm.safeLog, id: \ .self) { entry in
                                Text(entry)
                                    .font(.system(size: 14, design: .monospaced))
                            }
                        }
                    }
                }
            }
            .frame(height: 300)
            .padding(.horizontal)
        }
        .padding()
    }
}

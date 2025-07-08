//
//  RetainCycle.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-03.
//

// RetainCycleDemoApp.swift
import SwiftUI

// ContentView.swift
struct ContentView: View {
    var body: some View {
        NavigationLink("Go to Detail View", destination: LeakyDetailView())
    }
}

// LeakyDetailView.swift
struct LeakyDetailView: View {
    @StateObject private var viewModel = LeakyViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(viewModel.count)")
                .font(.largeTitle)

            Button("Stop Timer") {
                viewModel.stopTimer()
            }
        }
        .onDisappear {
            print("LeakyDetailView disappeared")
        }
        .navigationTitle("Leaky View")
    }
}

// LeakyViewModel.swift
import Combine

class LeakyViewModel: ObservableObject {
    @Published var count = 0
    private var timer: Timer?

    init() {
        print("LeakyViewModel initialized")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] _ in
            self?.count += 1  // 🔁 Strong capture of self
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        print("LeakyViewModel deinitialized")
    }
}

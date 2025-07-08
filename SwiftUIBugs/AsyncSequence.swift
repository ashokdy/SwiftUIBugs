//
//  AsyncSequence.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-06.
//

import SwiftUI

// MARK: - Countdown AsyncSequence

struct Countdown: AsyncSequence {
    let start: Int

    struct CountdownIterator: AsyncIteratorProtocol {
        var current: Int

        mutating func next() async -> Int? {
            guard current >= 0 else { return nil }
            let value = current
            current -= 1
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            return value
        }
    }

    func makeAsyncIterator() -> CountdownIterator {
        CountdownIterator(current: start)
    }
}

// MARK: - TimerStream using AsyncStream

func makeTimerStream() -> AsyncStream<Int> {
    AsyncStream { continuation in
        var counter = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            continuation.yield(counter)
            counter += 1
            if counter > 5 {
                continuation.finish()
            }
        }

        continuation.onTermination = { @Sendable _ in
            timer.invalidate()
        }
    }
}

struct TimerStreamView: View {
    @State private var values: [Int] = []
    
    var body: some View {
        VStack {
            Text("Timer Stream").font(.title)
            List(values, id: \.self) { val in
                Text("🔄 \(val)")
            }
        }
        .task {
            for await number in makeTimerStream() {
                values.append(number)
            }
        }
    }
}

struct CountdownView: View {
    @State private var values: [Int] = []
    
    var body: some View {
        VStack {
            Text("Countdown").font(.title)
            List(values, id: \.self) { val in
                Text("⏳ \(val)")
            }
        }
        .task {
            for await number in Countdown(start: 5) {
                values.append(number)
            }
        }
    }
}

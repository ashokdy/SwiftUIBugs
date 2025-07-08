//
//  ToggleView.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-01.
//

import SwiftUI

struct ToggleView: View {
    @State var isOn = false
    @StateObject var asyncViewModel = AsyncViewModel()
    @StateObject var memoryViewModel = MemoryViewModel()
    @StateObject var timerViewModel = TimerViewModel()
    @StateObject var viewModel = QuoteViewModel()
    @StateObject var dataViewModel = DataViewModel3()
    
    var body: some View {
        VStack {
            Toggle("Toggle Me", isOn: $isOn)
            Text(isOn ? "It's On" : "It's Off")
            Text(asyncViewModel.data ?? "")
            Text(viewModel.errorMessage ?? "No Error")

            if asyncViewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
        .onAppear(perform: {
            Task {
                await asyncViewModel.fetchData()
            }
            Task {
                memoryViewModel.load()
            }
            
            timerViewModel.startTimer()
            viewModel.fetchQuote()
        })
    }
}


#Preview {
    ToggleView()
}

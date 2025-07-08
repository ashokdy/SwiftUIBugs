//
//  ContentView.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-01.
//

import SwiftUI

import SwiftUI

struct Quote: Decodable, Identifiable {
    let id: String
    let content: String
    let author: String
}
@MainActor
class QuoteViewModel1: ObservableObject {
    @Published var quote: Quote? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchQuote() async {
        isLoading = true
        errorMessage = nil
        guard let url = URL(string: "https://api.quotable.io/random") else {
            errorMessage = "Invalid URL"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let quote = try JSONDecoder().decode(Quote.self, from: data)
            self.quote = quote
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

import Foundation

@MainActor
class QuoteViewModel: ObservableObject {
    @Published var quote: Quote? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // Keep a reference to the current fetch Task so we can cancel it
    private var fetchTask: Task<Void, Never>? = nil
    
    func fetchQuote() {
        // Cancel any ongoing fetch before starting a new one
        fetchTask?.cancel()
        
        fetchTask = Task {
            isLoading = true
            errorMessage = nil
            quote = nil
            
            do {
                guard let url = URL(string: "https://api.quotable.io/random") else {
                    errorMessage = "Invalid URL"
                    isLoading = false
                    return
                }
                
                // Fetch with cancellation support
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Simulate 2-second suspense delay
                try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                
                let fetchedQuote = try JSONDecoder().decode(Quote.self, from: data)
                quote = fetchedQuote
            } catch is CancellationError {
                // Task was cancelled, do nothing
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func refresh() {
        fetchQuote()
    }
    
    deinit {
        fetchTask?.cancel()
        print("QuoteViewModel deinit called")
    }
}


struct ContentView1: View {
//    @StateObject var viewModel = QuoteViewModel()
    @State var showContent = false
    
    var body: some View {
        VStack(spacing: 16) {
//            if viewModel.isLoading {
//                ProgressView()
//            } else if let quote = viewModel.quote {
//                Text("“\(quote.content)”")
//                    .font(.title2)
//                    .multilineTextAlignment(.center)
//                Text("- \(quote.author)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            } else if let error = viewModel.errorMessage {
//                Text("Error: \(error)")
//                    .foregroundColor(.red)
//            }
            
            Button("Fetch Quote") {
                showContent = true
//                viewModel.fetchQuote()
            }
        }
        .sheet(isPresented: $showContent, content: {
            ToggleView()
        })
        .padding()
    }
}

#Preview {
    ContentView1()
}

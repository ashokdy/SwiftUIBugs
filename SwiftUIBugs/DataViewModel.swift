//
//  DataViewModel.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-03.
//

import Foundation

class DataViewModel3: ObservableObject {
    @Published var data: String?
    
    init() {
        Task {
            await load()
        }
    }
    
    func load() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        data = "Done"
    }
    
    deinit {
        print("DataViewModel deinit")
    }
}

struct Person {
    let firstName: String
    let lastName: String
    
    var fullName: String {
        firstName + " " + lastName
    }
    
    init?(firstName: String, lastName: String) {
        guard !lastName.isEmpty else {
            return nil
        }
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func sampleFunction() async {
        let task1 = Task { () -> [Int] in
            (0..<50).map(fibonacci(of:))
        }
        let result1 = await task1.value
        print(result1)
        
        let task2 = Task {
            try await getWeatherReadings(for: "Rome")
        }
        let result2 = await task2.result
        
        print(result2)
    }
    
    func printMessages() async {
        let string = await withTaskGroup { group -> String in
            group.addTask {
                "Hello"
            }
            group.addTask { "From" }
            group.addTask { "A" }
            group.addTask { "Task" }
            group.addTask { "Group" }
            
            var collected = [String]()
            
            for await value in group {
                collected.append(value)
            }
            
            return collected.joined(separator: " ")
        }
    }
    
    enum LocationError: Error {
        case unknown
    }
    
    func getWeatherReadings(for location: String) async throws -> [Double] {
        switch location {
        case "London":
            return (1...100).map { _ in Double.random(in: 6...26) }
        case "Rome":
            return (1...100).map { _ in Double.random(in: 10...32) }
        case "San Francisco":
            return (1...100).map { _ in Double.random(in: 12...20) }
        default:
            throw LocationError.unknown
        }
    }
    
    func fibonacci(of number: Int) -> Int {
        var first = 0
        var second = 1
        
        for _ in 0..<number {
            let previous = first
            first = second
            second = previous + first
        }
        
        return first
    }
}

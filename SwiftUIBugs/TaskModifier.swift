//
//  TaskModifier.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-05.
//

import Foundation
import SwiftUI

struct Message: Decodable, Identifiable {
    let id: Int
    let user: String
    let text: String
}

// Our content view is able to handle two kinds of message box now.
struct TaskModifier: View {
    @State private var messages = [Message]()
    @State private var selectedBox = "Inbox"
    let messageBoxes = ["Inbox", "Sent", "Spam"]

    var body: some View {
        NavigationStack {
            List(messages) { message in
                VStack(alignment: .leading) {
                    Text(message.user)
                        .font(.headline)

                    Text(message.text)
                }
            }
            .navigationTitle(selectedBox)

            // Our task modifier will recreate its fetchData() task whenever selectedBox changes
            .task(id: selectedBox) {
                await fetchData()
            }
            .toolbar {
                // Switch between our two message boxes
                Picker("Select a message box", selection: $selectedBox) {
                    ForEach(messageBoxes, id: \.self, content: Text.init)
                }
                .pickerStyle(.segmented)
            }
        }
    }

    // This is almost the same as before, but now loads the selectedBox JSON file rather than always loading the inbox.
    func fetchData() async {
        do {
            let url = URL(string: "https://hws.dev/\(selectedBox.lowercased()).json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            messages = try JSONDecoder().decode([Message].self, from: data)
        } catch {
            print(error)
            messages = [
                Message(id: 0, user: "Failed to load message box.", text: "Please try again later.")
            ]
        }
    }
}

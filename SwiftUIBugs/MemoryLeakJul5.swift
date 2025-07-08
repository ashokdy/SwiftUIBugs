//
//  MemoryLeakJul5.swift
//  SwiftUIBugs
//
//  Created by ASHOK DY on 2025-07-05.
//

import SwiftUI
import SwiftData

@Model
class Note {
    var title: String

    init(title: String) {
        self.title = title
    }
}

class LeakyNoteViewModel: ObservableObject {
    @Published var note: Note

    init(note: Note) {
        self.note = note
    }

    deinit {
        print("LeakyNoteViewModel deinit")
    }
}

struct LeakScenario1: View {
    @State private var show = true

    var body: some View {
        VStack {
            Button("Toggle") { show.toggle() }
            if show {
                NoteDetailView()
            }
        }
    }
}

struct NoteDetailView: View {
    @StateObject var vm = LeakyNoteViewModel(note: Note(title: "Test"))

    var body: some View {
        Text("Note: \(vm.note.title)")
    }
}

#Preview {
    LeakScenario1()
}

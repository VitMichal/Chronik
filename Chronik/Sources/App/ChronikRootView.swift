//
//  ChronikRootView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI

struct ChronikRootView: View {
    @StateObject private var navigator: NavigatorImpl<EntryScreen>
    @State private var workLogViewModel: WorkLogViewModel
    @State private var addEntryViewModel: AddEntryViewModel

    init(service: EntryService) {
        let navigator = NavigatorImpl<EntryScreen>()
        _navigator = StateObject(wrappedValue: navigator)
        _workLogViewModel = State(initialValue: WorkLogViewModel(service: service, navigator: navigator))
        _addEntryViewModel = State(initialValue: AddEntryViewModel(service: service, navigator: navigator))
    }

    var body: some View {
        NavigationStack(path: $navigator.navigationPath) {
            WorkLogView(viewModel: workLogViewModel)
                .navigationDestination(for: EntryScreen.self) { route in
                    switch route {
                    case .addEntry:
                        AddEntryView(viewModel: addEntryViewModel)
                    case .entryDetail:
                        EntryDetailPlaceholderView()
                    }
                }
        }
    }
}

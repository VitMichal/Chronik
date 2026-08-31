//
//  ChronikRootView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI
import Generic
import Entries

struct ChronikRootView<EntriesVM: EntriesViewModel>: View {
    @StateObject private var navigator: NavigatorImpl<EntryScreen>
    private let entriesViewModel: EntriesVM
    private let makeEntryFormViewModel: (UUID?) -> EntryFormViewModelImpl

    init(
        navigator: NavigatorImpl<EntryScreen>,
        entriesViewModel: EntriesVM,
        makeEntryFormViewModel: @escaping (UUID?) -> EntryFormViewModelImpl
    ) {
        _navigator = StateObject(wrappedValue: navigator)
        self.entriesViewModel = entriesViewModel
        self.makeEntryFormViewModel = makeEntryFormViewModel
    }

    var body: some View {
        NavigationStack(path: $navigator.navigationPath) {
            EntriesView(viewModel: entriesViewModel)
                .navigationDestination(for: EntryScreen.self) { route in
                    switch route {
                    case .addEntry:
                        EntryFormView(viewModel: makeEntryFormViewModel(nil))
                    case .entryDetail(let id):
                        EntryFormView(viewModel: makeEntryFormViewModel(id))
                    }
                }
        }
    }
}

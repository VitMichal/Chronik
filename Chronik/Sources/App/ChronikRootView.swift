//
//  ChronikRootView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI

struct ChronikRootView: View {
    @StateObject private var navigator: NavigatorImpl<EntryScreen>
        let service: EntryService
    
    init(service: EntryService) {
        self.service = service
        let navigator = NavigatorImpl<EntryScreen>()
        _navigator = StateObject(wrappedValue: navigator)
    }

    var body: some View {
        NavigationStack(path: $navigator.navigationPath) {
            EntriesView(viewModel: EntriesViewModelImpl(service: service, navigator: navigator))
                .navigationDestination(for: EntryScreen.self) { route in
                    switch route {
                    case .addEntry:
                        EntryFormDestination(service: service, navigator: navigator)
                    case .entryDetail(let id):
                        EntryFormDestination(entryID: id, service: service, navigator: navigator)
                    }
                }
        }
    }
}

private struct EntryFormDestination: View {
    @State private var viewModel: EntryFormViewModelImpl

    init(
        entryID: UUID? = nil,
        service: EntryService,
        navigator: any Navigator<EntryScreen>
    ) {
        _viewModel = State(
            initialValue: EntryFormViewModelImpl(
                entryID: entryID,
                service: service,
                navigator: navigator
            )
        )
    }

    var body: some View {
        EntryFormView(viewModel: viewModel)
    }
}

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
            WorkLogView(viewModel: WorkLogViewModelImpl(service: service, navigator: navigator))
                .navigationDestination(for: EntryScreen.self) { route in
                    switch route {
                    case .addEntry:
                        AddEntryView(viewModel: AddEntryViewModelImpl(service: service, navigator: navigator))
                    case .entryDetail(let id):
                        EntryDetailView(
                            viewModel: EntryDetailViewModelImpl(
                                id: id,
                                service: service,
                                navigator: navigator
                            )
                        )
                    }
                }
        }
    }
}

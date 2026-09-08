//
//  ChronikRootView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI
import Generic

public struct EntriesLaunchView: View {
    @StateObject private var navigator: StackNavigatorImpl<EntryScreen>

    public init() {
        _navigator = StateObject(
            wrappedValue: ApplicationScope.resolve(StackNavigatorImpl<EntryScreen>.self)
        )
    }
    
    public var body: some View {
        NavigationStack(path: $navigator.navigationPath) {
            EntriesView(viewModel: workLogViewModel)
                .navigationDestination(for: EntryScreen.self) { route in
                    switch route {
                    case .addEntry:
                        EntryFormView(
                            viewModel: ApplicationScope.resolve(
                                EntryFormViewModelImpl.self,
                                argument: UUID?.none
                            )
                        )
                    case .entryDetail(let id):
                        EntryFormView(
                            viewModel:  ApplicationScope.resolve(
                                EntryFormViewModelImpl.self,
                                argument: UUID?.some(id)
                            )
                        )
                    }
                }
        }
        // `EntriesView` loads the Work log from its own `onAppear`. That fires
        // again on iOS when a pushed screen is popped, but not on macOS, so a
        // saved Entry never reached the list there. Refreshing whenever the
        // stack returns to its root is deterministic on both platforms.
        .onChange(of: navigator.navigationPath.isEmpty) { _, isAtRoot in
            if isAtRoot {
                Task { await workLogViewModel.load() }
            }
        }
    }

    /// Container-scoped, so this resolves to the very instance `EntriesView`
    /// is rendering — not a second view model with its own state.
    private var workLogViewModel: EntriesViewModelImpl {
        ApplicationScope.resolve(EntriesViewModelImpl.self)
    }
}

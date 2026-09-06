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
            EntriesView(viewModel: ApplicationScope.resolve(EntriesViewModelImpl.self))
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
    }
}

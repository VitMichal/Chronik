//
//  ChronikRootView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI

struct ChronikRootView: View {
    @StateObject private var navigator: NavigatorImpl<EntryScreen>
    @State private var viewModel: WorkLogViewModel

    init(service: EntryService) {
        let navigator = NavigatorImpl<EntryScreen>()
        _navigator = StateObject(wrappedValue: navigator)
        _viewModel = State(initialValue: WorkLogViewModel(service: service, navigator: navigator))
    }

    var body: some View {
        NavigationStack(path: $navigator.navigationPath) {
            WorkLogView(viewModel: viewModel)
                .navigationDestination(for: EntryScreen.self) { route in
                    switch route {
                    case .entryDetail:
                        EntryDetailPlaceholderView()
                    }
                }
        }
    }
}

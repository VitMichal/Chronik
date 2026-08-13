//
//  StartView.swift
//  Chronik
//
//  Created by Vít Míchal on 24.07.2026.
//

import SwiftUI

struct AccomodationsNavigationView: View {
    @StateObject private var navigator = NavigatorImpl<AccommodationScreen>()

    func accommodationsViewModel() -> AccommodationsViewModelImpl {
        return AccommodationsViewModelImpl(
            accommodationsService: AccommodationsServiceImpl(
                client: supabaseClient
            ),
            accommodationImagesService: AccommodationImagesServiceImpl(
                client: supabaseClient,
            ),
            navigator: navigator
        )
    }

    var body: some View {
        NavigationStack(path: $navigator.navigationPath) {
            AccommodationsView(viewModel: accommodationsViewModel())
                .navigationDestination(for: AccommodationScreen.self) { route in
                    switch route {
                    case .accommodationDetail(let id): EmptyView()
                    }
                }
        }
    }
}

//
//  AccommodationsView.swift
//  Chronik
//
//  Created by Vít Míchal on 23.07.2026.
//

import SwiftUI

struct AccommodationsView<ViewModel: AccommodationsViewModel>: View {
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            LoadableCollectionView(viewModel.state, retryAction: { Task { await viewModel.fetch() } } ) { accommodations in
                ScrollView {
                    LazyVStack(spacing: Theme.dimensions.padding.l) {
                        ForEach(accommodations) { accommodation in
                            AccommodationCardView(
                                state: accommodation,
                                openDetail: viewModel.openDetail
                            )
                        }
                    }
                    .padding(Theme.dimensions.padding.l)
                }
            }
        }
        .toolbar { RangeSelectionView(viewModel: viewModel) }
        .navigationTitle("Accommodations")
        .onAppear().task { await viewModel.fetch() }
        .refreshable { Task { await viewModel.fetch() } }
    }
}

struct AccommodationCardView: View {
    let state: AccommodationState
    let openDetail: (_ id: UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AccommodationCardImageView(state: state)
            VStack(alignment: .leading, spacing: 4) {
                Text(state.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(state.location)
                    .font(.subheadline)
                    .foregroundColor(Theme.pallete.onSurfaceColor)
                
                HStack {
                    Text(state.price)
                        .font(.headline)
                        .foregroundColor(Theme.pallete.onSurfaceColor)
                    
                    Spacer()
                    
                    HStack(spacing: Theme.dimensions.padding.s) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(state.rating)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.top, Theme.dimensions.padding.m)
            }
            .padding(.horizontal, Theme.dimensions.padding.m)
            .padding(.bottom, Theme.dimensions.padding.m)
        }
        .padding(Theme.dimensions.padding.m)
        .background(Theme.pallete.surfaceColor)
        .cornerRadius(Theme.dimensions.radius.m)
        .shadow(color: .black.opacity(0.08), radius: Theme.dimensions.radius.m, x: 0, y: Theme.dimensions.padding.m)
        .onTapGesture { openDetail(state.id) }
    }
}

struct AccommodationCardImageView: View {
    let state: AccommodationState
    
    var body: some View {
        ZStack {
            Theme.pallete.surfaceColorVariant
            AsyncImage(url: URL(string: (try? state.imageUrl?.get()) ?? "")) { phase in
                switch phase {
                case .empty: DefaultLoadingView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()

                case .failure(let error): DefaultErrorView(error: error, retryAction: {})
                @unknown default: EmptyView()
                }
            }
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: Theme.dimensions.radius.m))
    }
}

class ViewModelMock: AccommodationsViewModel {
    var rangeSelectionState = RangeSelectionState(
        lower: RangeSelectionValue(value: 0.0, text: "0.0"),
        upper: RangeSelectionValue(value: 1.0, text: "1.0"),
        rangeBorders: RangeBorders(min: 0.0, max: 1.0)
    )
    var state: LoadableCollection<AccommodationState>

    init(state: LoadableCollection<AccommodationState>) {
        self.state = state
    }

    func fetch() async { }
    func openDetail(id: UUID) { }
    func update(upper value: Double) { }
    func update(lower value: Double) { }
}

#Preview("Accommodations Success") {
    AccommodationsView(viewModel: ViewModelMock(state: .success([
        AccommodationState(
            title: "Grand Plaza Hotel",
            location: "New York City, NY",
            price: "$350/night",
            rating: "4.8",
            imageUrl: nil
        ),
        AccommodationState(
            title: "Whispering Pines Cabin",
            location: "Aspen, CO",
            price: "$150/night",
            rating: "4.9",
            imageUrl: nil
        ),
        AccommodationState(
            title: "Oceanfront Villa",
            location: "Maui, HI",
            price: "$450/night",
            rating: "5.0",
            imageUrl: nil
        ),
        AccommodationState(
            title: "Downtown Studio Apartment",
            location: "London, UK",
            price: "£120/night",
            rating: "4.5",
            imageUrl: nil
        ),
        AccommodationState(
            title: "Backpackers Haven Hostel",
            location: "Berlin, Germany",
            price: "€30/night",
            rating: "4.2",
            imageUrl: nil
        ),
        AccommodationState(
            title: "Desert Mirage Resort",
            location: "Dubai, UAE",
            price: "$800/night",
            rating: "4.7",
            imageUrl: nil
        )
    ])))
}

#Preview("Accommodations Loading") {
    AccommodationsView(viewModel: ViewModelMock(state: .loading))
}

#Preview("Accommodations Error") {
    AccommodationsView(viewModel: ViewModelMock(state: .error(StateError.general)))
}

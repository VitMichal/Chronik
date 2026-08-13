//
//  AccommodationsViewModel.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation
import Observation

public struct AccommodationState: Identifiable {
    public let id: UUID
    public let title: String
    public let location: String
    public let price: String
    public let rating: String
    public let imageUrl: Result<String, Error>?

    public init(id: UUID = UUID(), title: String, location: String, price: String, rating: String, imageUrl: Result<String, Error>?) {
        self.id = id
        self.title = title
        self.location = location
        self.price = price
        self.rating = rating
        self.imageUrl = imageUrl
    }
    
    func set(imageUrl: Result<String, Error>) -> AccommodationState {
        AccommodationState(id: id, title: title, location: location, price: price, rating: rating, imageUrl: imageUrl)
    }
}

public protocol AccommodationsViewModel: RangeSelectionViewModel, LoadableCollectionViewModel where State == AccommodationState {
    func fetch() async
    func openDetail(id: UUID)
}

@Observable
public class AccommodationsViewModelImpl: LoadableCollectionViewModelImpl<AccommodationState>, AccommodationsViewModel {

    public var rangeSelectionState = RangeSelectionState(
        lower: RangeSelectionValue(value: 0.0, text: ""),
        upper: RangeSelectionValue(value: 1.0, text: ""),
        rangeBorders: RangeBorders(min: 0.0, max: 1.0)
    )
    private let accommodationsService: AccommodationsService
    private let accommodationImagesService: AccommodationImagesService
    private let navigator: any Navigator<AccommodationScreen>
    private var originalRangeBorders: RangeBorders?
    
    public init(accommodationsService: AccommodationsService, accommodationImagesService: AccommodationImagesService, navigator: any Navigator<AccommodationScreen>) {
        self.accommodationsService = accommodationsService
        self.accommodationImagesService = accommodationImagesService
        self.navigator = navigator
    }
    
    public func fetch() async {
        do {
            let accommodations = try await accommodationsService.fetch(using: nil)
            setFilterRange(according: accommodations)
            state = .success(accommodations.compactMap(accommodationState))
            await fetchImages(for: accommodations)
        } catch {
            self.state = .error(error)
        }
    }

    public func openDetail(id: UUID) {
        navigator.navigateTo(AccommodationScreen.accommodationDetail(accommodationId: id))
    }

    public func update(upper value: Double) {
        rangeSelectionState = RangeSelectionState(
            lower: rangeSelectionState.lower,
            upper: RangeSelectionValue(value: value, text:  formatRangeText(value)),
            rangeBorders: rangeSelectionState.rangeBorders
        )
    }
    
    public func update(lower value: Double) {
        rangeSelectionState = RangeSelectionState(
            lower: RangeSelectionValue(value: value, text:  formatRangeText(value)),
            upper: rangeSelectionState.upper,
            rangeBorders: rangeSelectionState.rangeBorders
        )
    }

    private func formatRangeText(_ value: Double) -> String {
        "€" + value.formatted(.number.precision(.fractionLength(0)))
    }

    private func setFilterRange(according accommodations: [Accommodation]) {
        guard originalRangeBorders == nil else { return }
        let minPrice = accommodations.min(by: { $0.price < $1.price })?.price.toDouble() ?? 0.0
        let maxPrice = accommodations.max(by: { $0.price < $1.price })?.price.toDouble() ?? 1.0
            
        rangeSelectionState = RangeSelectionState(
            lower: RangeSelectionValue(value: minPrice, text:  formatRangeText(minPrice)),
            upper: RangeSelectionValue(value: maxPrice, text:  formatRangeText(maxPrice)),
            rangeBorders: RangeBorders(min: minPrice, max: maxPrice)
        )
        originalRangeBorders = rangeSelectionState.rangeBorders
    }
    
    private func accommodationState(_ accommodation: Accommodation) -> AccommodationState {
        return AccommodationState(
            id: accommodation.id,
            title: accommodation.title,
            location: "\(accommodation.city), \(accommodation.country)",
            price: "€\(accommodation.price) / night",
            rating: "\(accommodation.ratingAvg)",
            imageUrl: nil
        )
    }
    
    private func fetchImages(for accommodations: [Accommodation]) async {
        for accommodation in accommodations {
            let filter = AccommodationImagesServiceFilter(
                accommodationId: accommodation.id,
                limit: 1
            )
            
            do {
                if let image = try await accommodationImagesService.fetch(using: filter).first {
                    updateState(with: .success(image.url), at: accommodation.id)
                }
            } catch {
                updateState(with: .failure(error), at: accommodation.id)
            }
        }
    }
    
    private func updateState(with imageUrl: Result<String, Error>, at accommodationId: UUID) {
        switch state {
        case .success(var collection):
            if let index = collection.firstIndex(where: {
                return $0.id == accommodationId
            }) {
                collection[index] = collection[index].set(imageUrl: imageUrl)
                state = .success(collection)
            }
            
        default: break
        }
    }
}


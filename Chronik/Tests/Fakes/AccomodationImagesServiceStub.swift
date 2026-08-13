//
//  AccommodationImagesServiceStub.swift
//  Chronik
//
//  Created by Vít Míchal on 24.07.2026.
//

import Chronik

final class AccommodationImagesServiceStub: AccommodationImagesService {
    var fetchResult: Result<[AccommodationImage], Error> = .success([])

    init() { }

    init(fetchResult: Result<[AccommodationImage], Error>) {
        self.fetchResult = fetchResult
    }

    func fetch(using filter: AccommodationImagesServiceFilter) async throws -> [AccommodationImage] {
        switch fetchResult {
        case .success(let images):
            return images
        case .failure(let error):
            throw error
        }
    }
}

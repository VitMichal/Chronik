//
//  AccommodationServiceStub.swift
//  Chronik
//
//  Created by Vít Míchal on 23.07.2026.
//

import Chronik

final class AccommodationsServiceStub: AccommodationsService {
    var fetchResult: Result<[Accommodation], Error> = .success([])

    init() { }
    
    init(fetchResult: Result<[Accommodation], Error>) {
        self.fetchResult = fetchResult
    }
    
    func fetch(using filter: AccommodationsServiceFilter?) async throws -> [Accommodation] {
        switch fetchResult {
        case .success(let accommodations):
            return accommodations
        case .failure(let error):
            throw error
        }
    }
}

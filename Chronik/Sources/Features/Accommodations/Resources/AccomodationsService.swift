//
//  AccommodationsService.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation

public struct AccommodationsServiceFilter {
    public let price: Range<Decimal>
}

public protocol AccommodationsService {
    func fetch(using filter: AccommodationsServiceFilter?) async throws -> [Accommodation]
}

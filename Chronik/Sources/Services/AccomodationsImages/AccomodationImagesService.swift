//
//  AccommodationsService.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation

public struct AccommodationImagesServiceFilter {
    public let accommodationId: UUID
    public let limit: Int?
}

public protocol AccommodationImagesService {
    func fetch(using filter: AccommodationImagesServiceFilter) async throws -> [AccommodationImage]
}

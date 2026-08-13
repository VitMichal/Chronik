//
//  Amenity.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation

struct AmenityDto: Identifiable, Codable {
    let id: UUID
    let name: String
    let iconUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconUrl = "icon_url"
    }
}

struct AccommodationAmenityDto: Codable {
    let accommodationId: UUID
    let amenityId: UUID

    enum CodingKeys: String, CodingKey {
        case accommodationId = "accommodation_id"
        case amenityId = "amenity_id"
    }
}

//
//  AccommodationImage.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation

struct AccommodationImageDto: Identifiable, Codable {
    let id: UUID
    let accommodationId: UUID
    let imageUrl: URL
    let displayOrder: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case accommodationId = "accommodation_id"
        case imageUrl = "image_url"
        case displayOrder = "display_order"
        case createdAt = "created_at"
    }
}


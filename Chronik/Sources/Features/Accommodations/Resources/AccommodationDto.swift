//
//  Accommodation.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation

struct AccommodationDto: Identifiable, Codable {
    let id: UUID
    let hostId: UUID
    let title: String
    let description: String
    let city: String
    let country: String
    let pricePerNight: Decimal
    let maxGuests: Int
    let bedrooms: Int
    let bathrooms: Int
    let ratingAvg: Double
    let ratingCount: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case hostId = "host_id"
        case title
        case description
        case city
        case country
        case pricePerNight = "price_per_night"
        case maxGuests = "max_guests"
        case bedrooms
        case bathrooms
        case ratingAvg = "rating_avg"
        case ratingCount = "rating_count"
        case createdAt = "created_at"
    }
}

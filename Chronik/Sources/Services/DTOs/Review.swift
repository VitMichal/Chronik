//
//  Review.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation

struct ReviewDto: Identifiable, Codable {
    let id: UUID
    let accommodationId: UUID
    let authorId: UUID
    let rating: Int
    let comment: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case accommodationId = "accommodation_id"
        case authorId = "author_id"
        case rating
        case comment
        case createdAt = "created_at"
    }
}

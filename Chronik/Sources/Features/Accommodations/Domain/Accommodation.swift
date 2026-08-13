//
//  Accommodation.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation

public struct Accommodation: Identifiable {
    public let id: UUID
    public let title: String
    public let city: String
    public let country: String
    public let price: Decimal
    public let ratingAvg: Double
    public let imageUrl: String?
    
    public init(id: UUID, title: String, city: String, country: String, price: Decimal, ratingAvg: Double, imageUrl: String?) {
        self.id = id
        self.title = title
        self.city = city
        self.country = country
        self.price = price
        self.ratingAvg = ratingAvg
        self.imageUrl = imageUrl
    }
}

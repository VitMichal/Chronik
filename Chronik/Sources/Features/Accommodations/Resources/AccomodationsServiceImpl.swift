//
//  Untitled.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation
import Supabase

class AccommodationsServiceImpl: AccommodationsService {
    
    let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func fetch(using filter: AccommodationsServiceFilter?) async throws -> [Accommodation] {
    
        var query = client
            .from("accommodations")
            .select("*")

        if let filter = filter {
            query = query
                .gte("price_per_night", value: filter.price.lowerBound.toDouble())
                .lte("price_per_night", value: filter.price.upperBound.toDouble())
        }
        
        let accommodationsDtos: [AccommodationDto] = try await query
            .order("created_at", ascending: false)
            .execute()
            .value

        return accommodationsDtos.compactMap { dto in
            Accommodation(
                id: dto.id,
                title: dto.title,
                city: dto.city,
                country: dto.country,
                price: dto.pricePerNight,
                ratingAvg: dto.ratingAvg,
                imageUrl: nil
            )
        }
    }
}

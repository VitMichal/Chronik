//
//  AccommodationImagesServiceImpl.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Supabase
import Foundation

class AccommodationImagesServiceImpl: AccommodationImagesService {
    
    let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func fetch(using filter: AccommodationImagesServiceFilter) async throws -> [AccommodationImage] {
    
        var query = client
            .from("accommodation_images")
            .select()
            .eq("accommodation_id", value: filter.accommodationId)
            .order("display_order", ascending: true)

        if let limit = filter.limit {
            query = query.limit(limit)
        }
        
        let accommodationImageDtos: [AccommodationImageDto] = try await query
            .execute()
            .value
    
        return accommodationImageDtos.compactMap { dto in
            AccommodationImage(
                url: dto.imageUrl.absoluteString
            )
        }
    }
}

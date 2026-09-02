//
//  Entry.swift
//  Chronik
//
//  Created by Vít Míchal on 13.08.2026.
//

import Foundation

public struct Entry: Equatable, Identifiable {
    public let id: UUID
    public let day: Date
    public let createdAt: Date
    public let title: String
    public let duration: Decimal?
    public let notes: String?

    public init(
        id: UUID,
        day: Date,
        createdAt: Date,
        title: String,
        duration: Decimal? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.day = day
        self.createdAt = createdAt
        self.title = title
        self.duration = duration
        self.notes = notes
    }
}

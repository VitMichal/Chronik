//
//  EntryServiceImpl.swift
//  Chronik
//
//  Created by Vít Míchal on 13.08.2026.
//

import Foundation
import SwiftData

@Model
final class EntryEntity {
    var id: UUID
    var day: Date
    var createdAt: Date
    var title: String
    var duration: Decimal?
    var notes: String?

    init(entry: Entry) {
        self.id = entry.id
        self.day = entry.day
        self.createdAt = entry.createdAt
        self.title = entry.title
        self.duration = entry.duration
        self.notes = entry.notes
    }
}

extension EntryEntity {
    func toEntry() -> Entry {
        Entry(id: id, day: day, createdAt: createdAt, title: title, duration: duration, notes: notes)
    }
}

@MainActor
final class EntryServiceImpl: EntryService {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func add(_ entry: Entry) async throws {
        let context = ModelContext(container)
        context.insert(EntryEntity(entry: entry))
        try context.save()
    }

    func fetchAll() async throws -> [Entry] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<EntryEntity>(sortBy: [
            SortDescriptor(\EntryEntity.day, order: .reverse),
            SortDescriptor(\EntryEntity.createdAt, order: .reverse)
        ])
        return try context.fetch(descriptor).map { $0.toEntry() }
    }

    func fetch(by id: UUID) async throws -> Entry? {
        let context = ModelContext(container)
        return try fetchEntity(by: id, in: context).map { $0.toEntry() }
    }

    func delete(by id: UUID) async throws {
        let context = ModelContext(container)
        if let entity = try fetchEntity(by: id, in: context) {
            context.delete(entity)
            try context.save()
        }
    }

    private func fetchEntity(by id: UUID, in context: ModelContext) throws -> EntryEntity? {
        var descriptor = FetchDescriptor<EntryEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}

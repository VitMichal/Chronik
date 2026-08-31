//
//  EntryServiceStub.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation
@testable import Chronik

@MainActor
final class EntryServiceStub: EntryService {

    var entries: [Entry] = []
    var error: Error?
    private(set) var deleteCallCount = 0
    private(set) var addedEntries: [Entry] = []
    private(set) var updatedEntries: [Entry] = []

    func add(_ entry: Entry) async throws {
        if let error { throw error }
        addedEntries.append(entry)
        entries.append(entry)
    }

    func update(_ entry: Entry) async throws {
        if let error { throw error }
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            throw StateError.general
        }
        updatedEntries.append(entry)
        entries[index] = entry
    }

    func fetchAll() async throws -> [Entry] {
        if let error { throw error }
        return entries
    }

    func fetch(by id: UUID) async throws -> Entry? {
        if let error { throw error }
        return entries.first { $0.id == id }
    }

    func delete(by id: UUID) async throws {
        if let error { throw error }
        deleteCallCount += 1
        entries.removeAll { $0.id == id }
    }
}

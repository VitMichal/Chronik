//
//  EntryService.swift
//  Chronik
//
//  Created by Vít Míchal on 13.08.2026.
//

import Foundation

@MainActor
public protocol EntryService {
    func add(_ entry: Entry) async throws
    func update(_ entry: Entry) async throws
    func fetchAll() async throws -> [Entry]
    func fetch(by id: UUID) async throws -> Entry?
    func delete(by id: UUID) async throws
}

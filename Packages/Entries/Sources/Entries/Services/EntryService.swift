//
//  EntryService.swift
//  Chronik
//
//  Created by Vít Míchal on 13.08.2026.
//

import Foundation

/// Deliberately not `@MainActor`: the bodies are network I/O, and main-actor
/// isolation would put request building, JSON decoding and row mapping on the
/// main thread. View models stay `@MainActor` and simply `await`. See D4 in
/// `docs/superpowers/specs/2026-09-07-supabase-persistence-design.md`.
protocol EntryService: Sendable {
    func add(_ entry: Entry) async throws
    func update(_ entry: Entry) async throws
    func fetchAll() async throws -> [Entry]
    func fetch(by id: UUID) async throws -> Entry?
    func delete(by id: UUID) async throws
}

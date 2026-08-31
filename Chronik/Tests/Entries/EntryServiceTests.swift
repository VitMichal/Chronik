//
//  EntryServiceTests.swift
//  Chronik
//
//  Created by Vít Míchal on 13.08.2026.
//

import XCTest
import SwiftData
@testable import Chronik

@MainActor
final class EntryServiceTests: XCTestCase {

    private func makeContainer() -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: EntryEntity.self, configurations: configuration)
    }

    private func makeDay(_ day: Int, _ month: Int, _ year: Int = 2026, hour: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    private func makeEntry(id: UUID = UUID(), day: Date, createdAt: Date, title: String) -> Entry {
        Entry(id: id, day: day, createdAt: createdAt, title: title, duration: nil, notes: nil)
    }

    func testFetchAllOrdersDaysNewestFirst() async throws {
        let sut = EntryServiceImpl(container: makeContainer())
        let older = makeEntry(day: makeDay(10, 8), createdAt: makeDay(10, 8, hour: 9), title: "older day")
        let newer = makeEntry(day: makeDay(11, 8), createdAt: makeDay(11, 8, hour: 9), title: "newer day")
        try await sut.add(older)
        try await sut.add(newer)

        let entries = try await sut.fetchAll()

        XCTAssertEqual(entries.map(\.title), ["newer day", "older day"])
    }

    func testFetchAllOrdersEntriesWithinSameDayNewestFirst() async throws {
        let sut = EntryServiceImpl(container: makeContainer())
        let day = makeDay(11, 8)
        let morning = makeEntry(day: day, createdAt: makeDay(11, 8, hour: 8), title: "morning")
        let evening = makeEntry(day: day, createdAt: makeDay(11, 8, hour: 17), title: "evening")
        try await sut.add(morning)
        try await sut.add(evening)

        let entries = try await sut.fetchAll()

        XCTAssertEqual(entries.map(\.title), ["evening", "morning"])
    }

    func testFetchByIDReturnsMatchingEntry() async throws {
        let sut = EntryServiceImpl(container: makeContainer())
        let id = UUID()
        let expected = Entry(id: id, day: makeDay(11, 8), createdAt: makeDay(11, 8, hour: 10), title: "stand-up", duration: Decimal(string: "1.5"), notes: "notes")
        try await sut.add(expected)

        let fetched = try await sut.fetch(by: id)

        XCTAssertEqual(fetched, expected)
    }

    func testFetchByIDReturnsNilWhenEntryDoesNotExist() async throws {
        let sut = EntryServiceImpl(container: makeContainer())

        let fetched = try await sut.fetch(by: UUID())

        XCTAssertNil(fetched)
    }

    func testAddPersistsEntry() async throws {
        let sut = EntryServiceImpl(container: makeContainer())
        let entry = makeEntry(day: makeDay(11, 8), createdAt: makeDay(11, 8, hour: 10), title: "persisted")

        try await sut.add(entry)

        let entries = try await sut.fetchAll()
        XCTAssertEqual(entries.map(\.title), ["persisted"])
    }

    func testUpdatePersistsChangedFieldsAndPreservesIdentity() async throws {
        let sut = EntryServiceImpl(container: makeContainer())
        let id = UUID()
        let createdAt = makeDay(11, 8, hour: 10)
        let original = makeEntry(id: id, day: makeDay(11, 8), createdAt: createdAt, title: "original")
        let updated = Entry(
            id: id,
            day: makeDay(12, 8),
            createdAt: createdAt,
            title: "updated",
            duration: Decimal(string: "2.5"),
            notes: "new notes"
        )
        try await sut.add(original)

        try await sut.update(updated)

        let fetched = try await sut.fetch(by: id)
        XCTAssertEqual(fetched, updated)
    }

    func testUpdateThrowsWhenEntryDoesNotExist() async throws {
        let sut = EntryServiceImpl(container: makeContainer())
        let entry = makeEntry(id: UUID(), day: makeDay(11, 8), createdAt: makeDay(11, 8), title: "missing")

        do {
            try await sut.update(entry)
            XCTFail("Expected update to throw")
        } catch {
            XCTAssertTrue(error is StateError)
        }
    }

    func testDeleteRemovesEntry() async throws {
        let sut = EntryServiceImpl(container: makeContainer())
        let id = UUID()
        let entry = makeEntry(id: id, day: makeDay(11, 8), createdAt: makeDay(11, 8, hour: 10), title: "doomed")
        try await sut.add(entry)

        try await sut.delete(by: id)

        let entries = try await sut.fetchAll()
        XCTAssertTrue(entries.isEmpty)
        let fetched = try await sut.fetch(by: id)
        XCTAssertNil(fetched)
    }
}

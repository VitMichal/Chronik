//
//  SupabaseEntryRowTests.swift
//  Chronik
//

import XCTest
@testable import Entries

final class SupabaseEntryRowTests: XCTestCase {

    private let prague = TimeZone(identifier: "Europe/Prague")!
    private let losAngeles = TimeZone(identifier: "America/Los_Angeles")!

    // MARK: - day

    func test_init_fromEntry_encodesDayAsLocalCalendarDay() {
        // Local midnight in Prague is 22:00Z the previous day. Storing the
        // instant would record the wrong Day; storing the calendar day does not.
        let day = date("2026-09-07T00:00:00", in: prague)
        let row = SupabaseEntryRow(entry: makeEntry(day: day), timeZone: prague)

        XCTAssertEqual(row.day, "2026-09-07")
    }

    func test_init_fromEntry_encodesLastInstantOfDayAsSameDay() {
        let day = date("2026-09-07T23:59:59", in: prague)
        let row = SupabaseEntryRow(entry: makeEntry(day: day), timeZone: prague)

        XCTAssertEqual(row.day, "2026-09-07")
    }

    func test_toEntry_parsesDayToLocalMidnight() throws {
        let row = makeRow(day: "2026-09-07")

        let entry = try row.toEntry(timeZone: prague)

        XCTAssertEqual(entry.day, date("2026-09-07T00:00:00", in: prague))
    }

    func test_toEntry_parsesDayToStartOfDayInTheGivenTimeZone() throws {
        let row = makeRow(day: "2026-09-07")

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = losAngeles
        let entry = try row.toEntry(timeZone: losAngeles)

        XCTAssertEqual(entry.day, calendar.startOfDay(for: entry.day))
    }

    func test_dayRoundTrips() throws {
        let original = date("2026-01-31T00:00:00", in: prague)

        let row = SupabaseEntryRow(entry: makeEntry(day: original), timeZone: prague)
        let entry = try row.toEntry(timeZone: prague)

        XCTAssertEqual(entry.day, original)
    }

    func test_toEntry_throwsOnUnreadableDay() {
        let row = makeRow(day: "07/09/2026")

        XCTAssertThrowsError(try row.toEntry(timeZone: prague)) { error in
            guard case .server = error as? EntryServiceError else {
                return XCTFail("Expected .server, got \(error)")
            }
        }
    }

    // MARK: - duration

    func test_decode_readsNumericDurationAsDecimal() throws {
        let row = try decode(json(duration: "1.5"))

        XCTAssertEqual(row.duration, Decimal(string: "1.5"))
    }

    func test_decode_readsQuarterHourDurationExactly() throws {
        let row = try decode(json(duration: "2.25"))

        XCTAssertEqual(row.duration, Decimal(string: "2.25"))
    }

    func test_decode_readsNullDurationAsNil() throws {
        let row = try decode(json(duration: "null"))

        XCTAssertNil(row.duration)
    }

    func test_durationRoundTripsThroughEntry() throws {
        let entry = makeEntry(duration: Decimal(string: "7.75"))

        let row = SupabaseEntryRow(entry: entry, timeZone: prague)
        let decoded = try row.toEntry(timeZone: prague)

        XCTAssertEqual(decoded.duration, Decimal(string: "7.75"))
    }

    // MARK: - notes

    func test_decode_readsNullNotesAsNil() throws {
        let row = try decode(json(notes: "null"))

        XCTAssertNil(row.notes)
    }

    func test_decode_readsPresentNotes() throws {
        let row = try decode(json(notes: "\"Paired on the sync engine\""))

        XCTAssertEqual(row.notes, "Paired on the sync engine")
    }

    // MARK: - columns

    func test_decode_ignoresUserID() throws {
        // user_id is never listed in SupabaseEntryRow.columns, but decoding must
        // not break if a row carries it anyway.
        let row = try decode(json(extra: "\"user_id\": \"\(UUID().uuidString)\","))

        XCTAssertEqual(row.title, "Wrote the migration")
    }

    func test_columns_excludesUserID() {
        XCTAssertFalse(SupabaseEntryRow.columns.contains("user_id"))
    }

    func test_encode_omitsUserID() throws {
        let data = try JSONEncoder().encode(SupabaseEntryRow(entry: makeEntry(), timeZone: prague))
        let encoded = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertFalse(encoded.contains("user_id"))
    }

    // MARK: - Helpers

    private func makeEntry(
        day: Date = Date(timeIntervalSince1970: 1_788_000_000),
        duration: Decimal? = nil
    ) -> Entry {
        Entry(
            id: UUID(),
            day: day,
            createdAt: Date(timeIntervalSince1970: 1_788_000_000),
            title: "Wrote the migration",
            duration: duration,
            notes: nil
        )
    }

    private func makeRow(day: String) -> SupabaseEntryRow {
        SupabaseEntryRow(
            id: UUID(),
            day: day,
            createdAt: Date(timeIntervalSince1970: 1_788_000_000),
            title: "Wrote the migration",
            duration: nil,
            notes: nil
        )
    }

    private func json(
        duration: String = "null",
        notes: String = "null",
        extra: String = ""
    ) -> String {
        """
        {
            \(extra)
            "id": "\(UUID().uuidString)",
            "day": "2026-09-07",
            "created_at": "2026-09-07T08:30:00Z",
            "title": "Wrote the migration",
            "duration": \(duration),
            "notes": \(notes)
        }
        """
    }

    private func decode(_ string: String) throws -> SupabaseEntryRow {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SupabaseEntryRow.self, from: Data(string.utf8))
    }

    private func date(_ string: String, in timeZone: TimeZone) -> Date {
        let formatter = Foundation.DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: string)!
    }
}

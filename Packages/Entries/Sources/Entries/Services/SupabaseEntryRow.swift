//
//  SupabaseEntryRow.swift
//  Chronik
//

import Foundation

/// Wire representation of a row in the `entries` table.
///
/// Named `SupabaseEntryRow` because `EntryRow` is already a public presentation
/// type in this module. `user_id` is absent by design: the column defaults from
/// `auth.uid()`, so the client cannot attribute a row to anyone else, and the
/// user is ambient session state rather than a property of an Entry (D7).
///
/// `day` stays a `"yyyy-MM-dd"` string on this type so the mapping to and from
/// `Entry` is pure and testable (D12).
struct SupabaseEntryRow: Codable, Equatable {
    let id: UUID
    let day: String
    let createdAt: Date
    let title: String
    let duration: Decimal?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case day
        case createdAt = "created_at"
        case title
        case duration
        case notes
    }

    /// Every column this app reads. Listed explicitly so `user_id` never reaches
    /// the decoder.
    static let columns = "id,day,created_at,title,duration,notes"
}

extension SupabaseEntryRow {
    init(entry: Entry, timeZone: TimeZone = .current) {
        self.id = entry.id
        self.day = Self.dayFormatter(for: timeZone).string(from: entry.day)
        self.createdAt = entry.createdAt
        self.title = entry.title
        self.duration = entry.duration
        self.notes = entry.notes
    }

    /// - Note: parses into local midnight, matching the `Calendar.current`
    ///   `startOfDay` that `EntriesViewModelImpl` groups by.
    func toEntry(timeZone: TimeZone = .current) throws -> Entry {
        guard let parsedDay = Self.dayFormatter(for: timeZone).date(from: day) else {
            throw EntryServiceError.server("Entry \(id) has an unreadable day: \(day)")
        }

        return Entry(
            id: id,
            day: parsedDay,
            createdAt: createdAt,
            title: title,
            duration: duration,
            notes: notes
        )
    }

    private static func dayFormatter(for timeZone: TimeZone) -> Foundation.DateFormatter {
        let formatter = Foundation.DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

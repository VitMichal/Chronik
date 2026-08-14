//
//  EntryDayDateFormatter.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation

struct EntryDayDateFormatter: DateFormatter {
    private let formatter: Foundation.DateFormatter

    init(
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        self.formatter = formatter
    }

    func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}

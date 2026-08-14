//
//  DateFormatter.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation

public protocol DateFormatter {
    func string(from date: Date) -> String
}

struct DateFormatterImpl: DateFormatter {
    private let formatter: Foundation.DateFormatter

    init(
        dateFormat: String,
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        self.formatter = formatter
    }

    func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}

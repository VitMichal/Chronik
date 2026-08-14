//
//  DateFormatterTests.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import XCTest
@testable import Chronik

final class DateFormatterTests: XCTestCase {

    private var calendar: Calendar!
    private var locale: Locale!
    private var timeZone: TimeZone!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        locale = Locale(identifier: "en_US_POSIX")
        timeZone = TimeZone(secondsFromGMT: 0)!
    }

    private func makeDay(_ day: Int, _ month: Int, year: Int = 2026) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    func testFormatsDayWithoutYear() {
        let sut = DayHeaderDateFormatter(calendar: calendar, locale: locale, timeZone: timeZone)

        XCTAssertEqual(sut.string(from: makeDay(11, 8)), "Tuesday, 11 Aug")
    }

    func testFormatsDayWithYear() {
        let sut = EntryDayDateFormatter(calendar: calendar, locale: locale, timeZone: timeZone)

        XCTAssertEqual(sut.string(from: makeDay(11, 8)), "Tuesday, 11 Aug 2026")
    }
}

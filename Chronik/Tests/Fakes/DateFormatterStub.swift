//
//  DateFormatterStub.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation
@testable import Chronik

final class DateFormatterStub: Chronik.DateFormatter {

    var stringsByDate: [Date: String] = [:]
    var defaultString: String = ""
    private(set) var formatCallCount = 0

    func string(from date: Date) -> String {
        formatCallCount += 1
        return stringsByDate[date] ?? defaultString
    }
}
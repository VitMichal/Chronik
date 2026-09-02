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

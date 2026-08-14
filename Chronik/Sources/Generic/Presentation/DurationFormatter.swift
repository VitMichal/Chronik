//
//  DurationFormatter.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation

enum DurationFormatter {
    static func string(from duration: Decimal) -> String {
        "\(duration) h"
    }
}

//
//  DurationFormatter.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation

public enum DurationFormatter {
    public static func string(from duration: Decimal) -> String {
        "\(duration) h"
    }
}

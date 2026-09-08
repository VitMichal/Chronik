//
//  DurationFormatter.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation

/// A duration split into the parts the Work log sets in different type — the
/// value in the display face, the unit alongside it.
public struct DurationDisplay: Equatable {
    public let value: String
    public let unit: String

    public init(value: String, unit: String) {
        self.value = value
        self.unit = unit
    }
}

public enum DurationFormatter {
    public static func display(from duration: Decimal) -> DurationDisplay {
        DurationDisplay(value: "\(duration)", unit: "h")
    }
}

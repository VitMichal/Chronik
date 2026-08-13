//
//  Decimal+toDouble.swift
//  Chronik
//
//  Created by Vít Míchal on 23.07.2026.
//

import Foundation

extension Decimal {
    public func toDouble() -> Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

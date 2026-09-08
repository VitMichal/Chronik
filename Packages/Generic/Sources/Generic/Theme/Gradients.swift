//
//  Gradients.swift
//  Chronik
//
//  Created by Vít Míchal on 08.09.2026.
//

import SwiftUI

/// Accent fills. Every action surface in the design is a gradient, never a
/// flat colour — `primaryColor` stays the single flat value for anything that
/// cannot take a gradient (tints, glyphs, selection states).
public struct Gradients {
    public let primary: LinearGradient

    public init(primary: LinearGradient) {
        self.primary = primary
    }
}

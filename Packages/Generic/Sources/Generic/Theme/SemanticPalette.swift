//
//  SemanticPalette.swift
//  Chronik
//
//  Created by Vít Míchal on 23.07.2026.
//

import SwiftUI

public protocol SemanticPalette {
    var primaryColor: Color { get }
    var primaryColorVariant: Color { get }
    var secondaryColor: Color { get }
    var errorColor: Color { get }
    var surfaceColor: Color { get }
    var surfaceColorVariant: Color { get }
    var backgroundColor: Color { get }
    var onPrimaryColor: Color { get }
    var onSecondaryColor: Color { get }
    var onErrorColor: Color { get }
    var onSurfaceColor: Color { get }
    var onBackgroundColor: Color { get }
}

public struct SemanticPaletteImpl: SemanticPalette {

    public let primaryColor: Color
    public let primaryColorVariant: Color
    public let secondaryColor: Color
    public let errorColor: Color
    public let surfaceColor: Color
    public let surfaceColorVariant: Color
    public let backgroundColor: Color
    public let onPrimaryColor: Color
    public let onSecondaryColor: Color
    public let onErrorColor: Color
    public let onSurfaceColor: Color
    public let onBackgroundColor: Color
}

extension Color {
    public static func named(_ name: String) -> Color {
        Color(UIColor(named: name)!)
    }
}

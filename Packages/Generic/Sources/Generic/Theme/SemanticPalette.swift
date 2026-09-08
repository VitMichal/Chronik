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
    var errorColorVariant: Color { get }
    var surfaceColor: Color { get }
    var surfaceColorVariant: Color { get }
    var backgroundColor: Color { get }
    var onPrimaryColor: Color { get }
    var onSecondaryColor: Color { get }
    var onErrorColor: Color { get }
    var onSurfaceColor: Color { get }
    var onSurfaceColorVariant: Color { get }
    var onBackgroundColor: Color { get }
    var placeholderColor: Color { get }
    var disabledColor: Color { get }
    var onDisabledColor: Color { get }
    var iconColor: Color { get }
    var iconColorVariant: Color { get }
}

public struct SemanticPaletteImpl: SemanticPalette {

    public let primaryColor: Color
    public let primaryColorVariant: Color
    public let secondaryColor: Color
    public let errorColor: Color
    public let errorColorVariant: Color
    public let surfaceColor: Color
    public let surfaceColorVariant: Color
    public let backgroundColor: Color
    public let onPrimaryColor: Color
    public let onSecondaryColor: Color
    public let onErrorColor: Color
    public let onSurfaceColor: Color
    public let onSurfaceColorVariant: Color
    public let onBackgroundColor: Color
    public let placeholderColor: Color
    public let disabledColor: Color
    public let onDisabledColor: Color
    public let iconColor: Color
    public let iconColorVariant: Color
}

extension Color {
    /// Looks the color up in the app bundle's asset catalog. SwiftUI's own
    /// initializer resolves on every platform, unlike `UIColor(named:)`.
    public static func named(_ name: String) -> Color {
        Color(name, bundle: .main)
    }
}

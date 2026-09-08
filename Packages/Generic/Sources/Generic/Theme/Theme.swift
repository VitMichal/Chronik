//
//  Theme.swift
//  Chronik
//
//  Created by Vít Míchal on 23.07.2026.
//

import SwiftUI
import UIKit

public struct Theme {
    public static let pallete: SemanticPalette = SemanticPaletteImpl(
        primaryColor: .named("primaryColor"),
        primaryColorVariant: .named("primaryColorVariant"),
        secondaryColor: .named("secondaryColor"),
        errorColor: .named("errorColor"),
        errorColorVariant: .named("errorColorVariant"),
        surfaceColor: .named("surfaceColor"),
        surfaceColorVariant: .named("surfaceColorVariant"),
        backgroundColor: .named("backgroundColor"),
        onPrimaryColor: .named("onPrimaryColor"),
        onSecondaryColor: .named("onSecondaryColor"),
        onErrorColor: .named("onErrorColor"),
        onSurfaceColor: .named("onSurfaceColor"),
        onSurfaceColorVariant: .named("onSurfaceColorVariant"),
        onBackgroundColor: .named("onBackgroundColor"),
        placeholderColor: .named("placeholderColor"),
        disabledColor: .named("disabledColor"),
        onDisabledColor: .named("onDisabledColor"),
        iconColor: .named("iconColor"),
        iconColorVariant: .named("iconColorVariant")
    )

    public static let typography = Typography()

    public static let gradients = Gradients(
        primary: LinearGradient(
            colors: [.named("primaryGradientStart"), .named("primaryGradientEnd")],
            startPoint: .leading,
            endPoint: .trailing
        )
    )

    public static let dimensions = Dimensions(
        padding: DimensionSize(
            s: 6.0,
            m: 12.0,
            l: 22.0
        ),
        radius: DimensionSize(
            s: 12.0,
            m: 18.0,
            l: 26.0
        )
    )
}

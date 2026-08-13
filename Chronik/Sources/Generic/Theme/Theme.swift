//
//  Theme.swift
//  Chronik
//
//  Created by Vít Míchal on 23.07.2026.
//

import UIKit

public struct Theme {
    public static let pallete: SemanticPalette = SemanticPaletteImpl(
        primaryColor: .named("primaryColor"),
        primaryColorVariant: .named("primaryColorVariant"),
        secondaryColor: .named("secondaryColor"),
        errorColor: .named("errorColor"),
        surfaceColor: .named("surfaceColor"),
        surfaceColorVariant: .named("surfaceColorVariant"),
        backgroundColor: .named("backgroundColor"),
        onPrimaryColor: .named("onPrimaryColor"),
        onSecondaryColor: .named("onSecondaryColor"),
        onErrorColor: .named("onErrorColor"),
        onSurfaceColor: .named("onSurfaceColor"),
        onBackgroundColor: .named("onBackgroundColor")
    )
    
    public static let dimensions = Dimensions(
        padding: DimensionSize(
            s: 5.0,
            m: 10.0,
            l: 20.0
        ),
        radius: DimensionSize(
            s: 5.0,
            m: 10.0,
            l: 20.0
        )
    )
}

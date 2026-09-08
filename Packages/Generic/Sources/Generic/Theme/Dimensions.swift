//
//  Dimensions.swift
//  Chronik
//
//  Created by Vít Míchal on 23.07.2026.
//

import CoreGraphics

public struct DimensionSize {
    public let s: CGFloat
    public let m: CGFloat
    public let l: CGFloat
}

public struct Dimensions {
    public let padding: DimensionSize
    public let radius: DimensionSize
}

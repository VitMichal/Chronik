//
//  Typography.swift
//  Chronik
//
//  Created by Vít Míchal on 08.09.2026.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
private typealias PlatformFont = UIFont
#elseif canImport(AppKit)
import AppKit
private typealias PlatformFont = NSFont
#endif

/// The type scale: a geometric sans, light-to-semibold, following the
/// reference design.
///
/// Each role names its faces in order of preference. Poppins is the closest
/// match to the reference and is used when the files are bundled; Avenir Next
/// ships with both iOS and macOS and carries the same geometric-humanist feel,
/// so it is the working default. The system font is the last resort.
public struct Typography {

    private enum Face {
        static let regular  = ["Poppins-Regular", "AvenirNext-Regular"]
        static let medium   = ["Poppins-Medium", "AvenirNext-Medium"]
        static let semibold = ["Poppins-SemiBold", "AvenirNext-DemiBold"]
    }

    /// Tracking for the uppercase field labels — 0.11em at 11pt.
    public let labelTracking: CGFloat = 1.2

    public init() {}

    // MARK: - Display

    public var screenTitle: Font { font(Face.semibold, 44, .semibold, .largeTitle) }
    public var dayHeader: Font { font(Face.medium, 26, .medium, .title2) }
    public var formTitle: Font { font(Face.regular, 31, .regular, .title) }
    public var emptyTitle: Font { font(Face.regular, 34, .regular, .title) }
    public var dayValue: Font { font(Face.medium, 20, .medium, .title3) }
    public var durationValue: Font { font(Face.medium, 23, .medium, .title3) }

    // MARK: - Text

    public var entryTitle: Font { font(Face.semibold, 17, .semibold, .body) }
    public var notes: Font { font(Face.regular, 14, .regular, .subheadline) }
    public var body: Font { font(Face.regular, 15, .regular, .subheadline) }
    public var label: Font { font(Face.semibold, 11, .semibold, .caption2) }
    public var durationUnit: Font { font(Face.semibold, 11, .semibold, .caption2) }
    public var button: Font { font(Face.semibold, 15, .semibold, .subheadline) }
    public var buttonLarge: Font { font(Face.semibold, 16, .semibold, .body) }
    public var backLabel: Font { font(Face.medium, 16, .medium, .body) }

    // MARK: - Resolution

    private func font(
        _ candidates: [String],
        _ size: CGFloat,
        _ weight: Font.Weight,
        _ style: Font.TextStyle
    ) -> Font {
        for name in candidates where PlatformFont(name: name, size: size) != nil {
            return .custom(name, size: size, relativeTo: style)
        }
        return .system(size: size, weight: weight)
    }
}

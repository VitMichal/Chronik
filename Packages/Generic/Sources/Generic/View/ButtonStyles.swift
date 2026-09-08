//
//  ButtonStyles.swift
//  Chronik
//
//  Created by Vít Míchal on 08.09.2026.
//

import SwiftUI

/// The filled action pill — Save, and the empty-state call to action.
public struct PrimaryPillButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    private let height: CGFloat
    private let horizontalPadding: CGFloat
    private let font: Font

    public init(
        height: CGFloat = 40,
        horizontalPadding: CGFloat = 22,
        font: Font = Theme.typography.button
    ) {
        self.height = height
        self.horizontalPadding = horizontalPadding
        self.font = font
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundStyle(isEnabled ? Theme.pallete.onPrimaryColor : Theme.pallete.onDisabledColor)
            .padding(.horizontal, horizontalPadding)
            .frame(height: height)
            .background(
                Group {
                    if isEnabled {
                        Capsule().fill(Theme.gradients.primary)
                    } else {
                        Capsule().fill(Theme.pallete.disabledColor)
                    }
                }
            )
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}

/// The circular add action that sits beside the Work log title.
public struct CircularActionButtonStyle: ButtonStyle {
    private let diameter: CGFloat

    public init(diameter: CGFloat = 48) {
        self.diameter = diameter
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Theme.pallete.onPrimaryColor)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(Theme.gradients.primary))
            .shadow(color: Theme.pallete.onBackgroundColor.opacity(0.22), radius: 5, y: 3)
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}

/// The duration quick-pick chips.
public struct ChipButtonStyle: ButtonStyle {
    private let isSelected: Bool

    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.typography.notes)
            .foregroundStyle(isSelected ? Theme.pallete.onPrimaryColor : Theme.pallete.onSurfaceColor)
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(
                Group {
                    if isSelected {
                        Capsule().fill(Theme.gradients.primary)
                    } else {
                        Capsule().fill(Theme.pallete.surfaceColor)
                    }
                }
            )
            .overlay(
                Capsule().stroke(
                    isSelected ? Theme.pallete.primaryColor : Theme.pallete.surfaceColorVariant,
                    lineWidth: 1
                )
            )
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}

/// The outlined destructive action at the foot of the Entry form.
public struct DestructiveOutlineButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.typography.button)
            .foregroundStyle(Theme.pallete.errorColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .overlay(
                Capsule().stroke(Theme.pallete.errorColorVariant, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}

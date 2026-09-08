//
//  PlatformModifiers.swift
//  Chronik
//

import SwiftUI

extension View {

    /// Hides the navigation chrome on screens that draw their own header — the
    /// navigation bar on iOS, the window toolbar on macOS. The two placements
    /// are not available on each other's platform, so the choice cannot be
    /// made at the call site.
    public func navigationChromeHidden() -> some View {
        #if os(macOS)
        return toolbar(.hidden, for: .windowToolbar)
        #else
        return toolbar(.hidden, for: .navigationBar)
        #endif
    }

    /// Asks for the decimal keypad on iOS. A no-op on macOS, which types
    /// through a hardware keyboard.
    public func decimalKeyboard() -> some View {
        #if os(iOS)
        return keyboardType(.decimalPad)
        #else
        return self
        #endif
    }
}

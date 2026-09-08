//
//  InteractivePopGesture.swift
//  Chronik
//
//  Created by Vít Míchal on 08.09.2026.
//

import SwiftUI

#if canImport(UIKit)

/// Restores the swipe-from-the-left-edge back gesture on screens that hide the
/// navigation bar. UIKit disables the gesture along with the bar, so the screens
/// that draw their own header have to hand it back.
///
/// Attach with `.interactivePopGestureEnabled()` on a screen inside a
/// `NavigationStack` that hides its navigation bar.
private struct InteractivePopGestureEnabler: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        Controller()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private final class Controller: UIViewController, UIGestureRecognizerDelegate {

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            guard let gesture = navigationController?.interactivePopGestureRecognizer else { return }
            gesture.delegate = self
            gesture.isEnabled = true
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let navigationController else { return false }
            // Swiping mid-transition, or on the root, leaves the stack inconsistent.
            return navigationController.viewControllers.count > 1
                && navigationController.transitionCoordinator == nil
        }
    }
}

extension View {
    public func interactivePopGestureEnabled() -> some View {
        background(
            InteractivePopGestureEnabler()
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
        )
    }
}

#else

extension View {
    /// A no-op on macOS: there is no edge-swipe back gesture to hand back.
    public func interactivePopGestureEnabled() -> some View { self }
}

#endif

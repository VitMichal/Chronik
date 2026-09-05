//
//  StackNavigator.swift
//  Chronik
//
//  Created by Vít Míchal on 05.09.2026.
//

import SwiftUI

/// A `Navigator` that drives a SwiftUI `NavigationStack`.
///
/// Views bind to `navigationPath` and stay generic over this protocol instead of
/// depending on a concrete navigator implementation.
public protocol StackNavigator<Screen>: Navigator, ObservableObject {
    var navigationPath: NavigationPath { get set }
}

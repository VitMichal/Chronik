//
//  Navigator.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import SwiftUI
import Observation

public class NavigatorImpl<Screen: Hashable>: Navigator, ObservableObject {
        
    @Published public var navigationPath = NavigationPath()
    
    public init() {}

    
    public func navigateTo(_ route: Screen) {
        navigationPath.append(route)
    }

    public func pop() {
        navigationPath.removeLast()
    }
}

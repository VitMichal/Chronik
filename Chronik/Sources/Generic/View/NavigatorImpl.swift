//
//  Navigator.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import SwiftUI
import Observation

class NavigatorImpl<Screen: Hashable>: Navigator, ObservableObject {
        
    @Published var navigationPath = NavigationPath()
    
    func navigateTo(_ route: Screen) {
        navigationPath.append(route)
    }

    func pop() {
        navigationPath.removeLast()
    }
}

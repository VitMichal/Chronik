//
//  NavigatorStub.swift
//  Chronik
//
//  Created by Vít Míchal on 24.07.2026.
//

import Generic

class NavigatorStub<Screen: Hashable>: Navigator {
        
    var lastScreen: Screen?
    private(set) var popCount = 0
    
    func navigateTo(_ route: Screen) {
        lastScreen = route
    }

    func pop() {
        lastScreen = nil
        popCount += 1
    }
}

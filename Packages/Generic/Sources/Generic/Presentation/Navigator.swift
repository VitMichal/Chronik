//
//  Navigator.swift
//  Chronik
//
//  Created by Vít Míchal on 24.07.2026.
//

public protocol Navigator<Screen> {
    associatedtype Screen: Hashable
    
    func navigateTo(_ route: Screen)
    func pop()
}


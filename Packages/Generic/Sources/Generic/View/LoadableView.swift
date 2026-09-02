//
//  LoadableStateView.swift
//  Chronik
//
//  Created by Vít Míchal on 24.07.2026.
//

import SwiftUI

public struct LoadableView<State, Content: View>: View {
    let state: Loadable<State>
    let retryAction: (() -> Void)?
    @ViewBuilder let content: (State) -> Content

    public init(
        _ state: Loadable<State>,
        retryAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (State) -> Content
    ) {
        self.state = state
        self.retryAction = retryAction
        self.content = content
    }

    public var body: some View {
        switch state {
            case .loading:
                DefaultLoadingView()
    
            case .error:
                DefaultErrorView(retryAction: retryAction)
            
            case .success(let loadedState):
                content(loadedState)
        }
    }
}

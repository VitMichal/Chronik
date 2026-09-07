//
//  LoadableStateView.swift
//  Chronik
//
//  Created by Vít Míchal on 24.07.2026.
//

import SwiftUI

public struct LoadableCollectionView<State, Content: View>: View {
    let state: LoadableCollection<State>
    let retryAction: (() -> Void)?
    @ViewBuilder let content: ([State]) -> Content

    public init(
        _ state: LoadableCollection<State>,
        retryAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping ([State]) -> Content
    ) {
        self.state = state
        self.retryAction = retryAction
        self.content = content
    }

    public var body: some View {
        switch state {
            case .loading:
                DefaultLoadingView()
            case .error(let error):
                DefaultErrorView(error: error, retryAction: retryAction)
            case .success(let loadedCollection):
                if loadedCollection.isEmpty {
                    DefaultEmptyView()
                } else {
                    content(loadedCollection)
                }
        }
    }
}

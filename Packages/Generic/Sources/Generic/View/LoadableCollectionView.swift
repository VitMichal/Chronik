//
//  LoadableCollectionView.swift
//  Chronik
//
//  Created by Vít Míchal on 24.07.2026.
//

import SwiftUI

public struct LoadableCollectionView<State, Content: View, EmptyContent: View>: View {
    let state: LoadableCollection<State>
    let retryAction: (() -> Void)?
    @ViewBuilder let emptyContent: () -> EmptyContent
    @ViewBuilder let content: ([State]) -> Content

    public init(
        _ state: LoadableCollection<State>,
        retryAction: (() -> Void)? = nil,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent,
        @ViewBuilder content: @escaping ([State]) -> Content
    ) {
        self.state = state
        self.retryAction = retryAction
        self.emptyContent = emptyContent
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
                    emptyContent()
                } else {
                    content(loadedCollection)
                }
        }
    }
}

extension LoadableCollectionView where EmptyContent == DefaultEmptyView {
    public init(
        _ state: LoadableCollection<State>,
        retryAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping ([State]) -> Content
    ) {
        self.init(
            state,
            retryAction: retryAction,
            emptyContent: { DefaultEmptyView() },
            content: content
        )
    }
}

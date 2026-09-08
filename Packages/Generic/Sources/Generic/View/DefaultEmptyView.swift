//
//  DefaultEmptyView.swift
//  Chronik
//
//  Created by Vít Míchal on 25.07.2026.
//

import SwiftUI

public struct DefaultEmptyView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: Theme.dimensions.padding.m) {
            Text("Nothing here yet")
                .font(Theme.typography.emptyTitle)
                .foregroundStyle(Theme.pallete.onBackgroundColor)
            Text("There is nothing to display right now.")
                .font(Theme.typography.body)
                .foregroundStyle(Theme.pallete.onSurfaceColor)
        }
        .multilineTextAlignment(.center)
        .padding(Theme.dimensions.padding.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.pallete.backgroundColor)
    }
}

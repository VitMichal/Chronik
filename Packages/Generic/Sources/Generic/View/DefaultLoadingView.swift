//
//  DefaultLoadingView.swift
//  Chronik
//
//  Created by Vít Míchal on 25.07.2026.
//

import SwiftUI

struct DefaultLoadingView: View {
    var body: some View {
        VStack(spacing: Theme.dimensions.padding.m) {
            ProgressView()
                .tint(Theme.pallete.primaryColor)
            Text("Loading...")
                .font(Theme.typography.body)
                .foregroundStyle(Theme.pallete.onSurfaceColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.pallete.backgroundColor)
    }
}

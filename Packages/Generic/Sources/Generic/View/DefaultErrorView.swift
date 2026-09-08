//
//  DefaultErrorView.swift
//  Chronik
//
//  Created by Vít Míchal on 25.07.2026.
//

import SwiftUI

struct DefaultErrorView: View {
    let error: Error?
    let retryAction: (() -> Void)?

    init(error: Error? = nil, retryAction: (() -> Void)?) {
        self.error = error
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: Theme.dimensions.padding.l) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(Theme.pallete.errorColor)

            Text(error?.localizedDescription ?? "Something went wrong")
                .font(Theme.typography.entryTitle)
                .foregroundStyle(Theme.pallete.onBackgroundColor)
                .multilineTextAlignment(.center)

            if let retryAction {
                Button("Retry", action: retryAction)
                    .buttonStyle(PrimaryPillButtonStyle())
            }
        }
        .padding(Theme.dimensions.padding.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.pallete.backgroundColor)
    }
}

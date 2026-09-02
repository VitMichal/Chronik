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
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.red)
            
            Text("Something went wrong")
                .font(.headline)
            
            if let retryAction {
                Button("Retry", action: retryAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

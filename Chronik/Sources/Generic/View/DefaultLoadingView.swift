//
//  Untitled.swift
//  Chronik
//
//  Created by Vít Míchal on 25.07.2026.
//

import SwiftUI

struct DefaultLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

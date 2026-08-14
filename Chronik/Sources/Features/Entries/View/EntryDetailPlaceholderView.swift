//
//  EntryDetailPlaceholderView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI

struct EntryDetailPlaceholderView: View {
    var body: some View {
        ContentUnavailableView(
            "Entry detail",
            systemImage: "doc.text",
            description: Text("Detail screen is coming soon.")
        )
        .navigationTitle("Entry")
    }
}

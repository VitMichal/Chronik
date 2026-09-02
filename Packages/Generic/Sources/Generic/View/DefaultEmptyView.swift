//
//  DefaultEmptyView.swift
//  Chronik
//
//  Created by Vít Míchal on 25.07.2026.
//

import SwiftUI

struct DefaultEmptyView: View {
    var body: some View {
        ContentUnavailableView(
            "No Data Available",
            systemImage: "tray",
            description: Text("There is nothing to display right now.")
        )
    }
}

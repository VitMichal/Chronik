//
//  EntryDetailView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI

struct EntryDetailView<VM: EntryDetailViewModel>: View {
    private let viewModel: VM

    init(viewModel: VM) {
        self.viewModel = viewModel
    }

    var body: some View {
        LoadableView(
            viewModel.state,
            retryAction: { Task { await viewModel.load() } }
        ) { detail in
            Form {
                Section {
                    Text(detail.title)
                        .font(.title2)
                        .foregroundStyle(Theme.pallete.onBackgroundColor)
                }
                Section {
                    LabeledContent("Day", value: detail.dayText)
                    if let durationText = detail.durationText {
                        LabeledContent("Duration", value: durationText)
                    }
                }
                if let notes = detail.notes, !notes.isEmpty {
                    Section("Notes") {
                        Text(notes)
                            .foregroundStyle(Theme.pallete.onSurfaceColor)
                    }
                }
            }
        }
        .navigationTitle("Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Delete") {
                    Task { await viewModel.delete() }
                }
                .foregroundStyle(Theme.pallete.errorColor)
            }
        }
        .onAppear { Task { await viewModel.load() } }
    }
}

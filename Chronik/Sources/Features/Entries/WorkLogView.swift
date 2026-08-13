//
//  WorkLogView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI

struct WorkLogView<VM: WorkLogViewModelProtocol>: View {
    private let viewModel: VM

    init(viewModel: VM) {
        self.viewModel = viewModel
    }

    var body: some View {
        LoadableCollectionView(
            viewModel.state,
            retryAction: { viewModel.load() }
        ) { sections in
            List {
                ForEach(sections) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.entries) { entry in
                            Button {
                                viewModel.select(entry.id)
                            } label: {
                                EntryRowView(entry: entry)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { viewModel.delete(section.entries[$0].id) }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Work log")
    }
}

private struct EntryRowView: View {
    let entry: EntryRow

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.padding.s) {
            Text(entry.title)
                .font(.headline)
                .foregroundStyle(Theme.pallete.onBackgroundColor)
            if let notes = entry.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(Theme.pallete.onSurfaceColor)
                    .lineLimit(2)
            }
            if let durationText = entry.durationText {
                Text(durationText)
                    .font(.caption)
                    .foregroundStyle(Theme.pallete.secondaryColor)
            }
        }
    }
}

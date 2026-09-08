//
//  EntriesView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI
import Generic

public struct EntriesView<VM: EntriesViewModel>: View {
    private let viewModel: VM

    public init(viewModel: VM) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            header

            LoadableCollectionView(
                viewModel.state,
                retryAction: { Task { await viewModel.load() } },
                emptyContent: { WorkLogEmptyView(addAction: viewModel.openAddEntry) }
            ) { sections in
                workLog(sections)
            }
        }
        .background(Theme.pallete.backgroundColor)
        .navigationTitle("Work log")
        .navigationChromeHidden()
        .onAppear { Task { await viewModel.load() } }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("Work log")
                .font(Theme.typography.screenTitle)
                .foregroundStyle(Theme.pallete.onBackgroundColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                viewModel.openAddEntry()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
            }
            .buttonStyle(CircularActionButtonStyle())
            .accessibilityLabel("Add Entry")
        }
        .padding(.horizontal, Theme.dimensions.padding.l)
        .padding(.top, Theme.dimensions.padding.m)
        .padding(.bottom, 16)
    }

    private func workLog(_ sections: [DaySection]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 28) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 11) {
                        DayHeaderView(title: section.title)

                        VStack(spacing: Theme.dimensions.padding.m - 2) {
                            ForEach(section.entries) { entry in
                                Button {
                                    viewModel.select(entry.id)
                                } label: {
                                    EntryRowView(entry: entry)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.dimensions.padding.l)
            .padding(.top, Theme.dimensions.padding.s)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }
}

private struct DayHeaderView: View {
    let title: String

    var body: some View {
        HStack(spacing: 13) {
            Text(title)
                .font(Theme.typography.dayHeader)
                .foregroundStyle(Theme.pallete.onBackgroundColor)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Rectangle()
                .fill(Theme.pallete.surfaceColorVariant)
                .frame(height: 1)
        }
    }
}

private struct EntryRowView: View {
    let entry: EntryRow

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: Theme.dimensions.padding.s - 1) {
                Text(entry.title)
                    .font(Theme.typography.entryTitle)
                    .foregroundStyle(Theme.pallete.onBackgroundColor)
                    .multilineTextAlignment(.leading)

                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(Theme.typography.notes)
                        .foregroundStyle(Theme.pallete.onSurfaceColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let duration = entry.duration {
                DurationView(duration: duration)
            }
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: Theme.dimensions.radius.m)
                .fill(Theme.pallete.surfaceColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.dimensions.radius.m)
                .stroke(Theme.pallete.surfaceColorVariant, lineWidth: 1)
        )
        .shadow(color: Theme.pallete.onBackgroundColor.opacity(0.06), radius: 8, y: 3)
    }
}

private struct DurationView: View {
    let duration: DurationDisplay

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(duration.value)
                .font(Theme.typography.durationValue)
            Text(duration.unit)
                .font(Theme.typography.durationUnit)
        }
        .foregroundStyle(Theme.pallete.primaryColorVariant)
    }
}

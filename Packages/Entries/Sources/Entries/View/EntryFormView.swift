//
//  EntryFormView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI
import Generic

struct EntryFormView<VM: EntryFormViewModel>: View {
    @State private var viewModel: VM
    @State private var isDayPickerExpanded = false

    private static var durationQuickPicks: [String] { ["0.5", "1", "2", "4"] }

    init(viewModel: VM) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            LoadableView(
                viewModel.loadState,
                retryAction: { Task { await viewModel.load() } }
            ) { _ in
                form
            }
        }
        .background(Theme.pallete.backgroundColor)
        .toolbar(.hidden, for: .navigationBar)
        .interactivePopGestureEnabled()
        .onAppear {
            if viewModel.isEditing { Task { await viewModel.load() } }
        }
        .alert(
            viewModel.state.errorTitle,
            isPresented: Binding(
                get: { viewModel.state.errorMessage != nil },
                set: { if !$0 { viewModel.dismissError() } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.state.errorMessage ?? "")
        }
    }

    private var header: some View {
        HStack(spacing: Theme.dimensions.padding.m - 2) {
            Button {
                viewModel.back()
            } label: {
                HStack(spacing: Theme.dimensions.padding.s - 1) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                    Text("Work log")
                        .font(Theme.typography.backLabel)
                }
                .foregroundStyle(Theme.pallete.primaryColorVariant)
                .padding(.horizontal, Theme.dimensions.padding.s)
                .frame(height: 44)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Button("Save") {
                Task { await viewModel.save() }
            }
            .buttonStyle(PrimaryPillButtonStyle())
            .disabled(!viewModel.isSaveEnabled)
        }
        .padding(.horizontal, 16)
        .padding(.top, Theme.dimensions.padding.s)
        .padding(.bottom, Theme.dimensions.padding.m - 2)
    }

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                titleField
                dayField
                durationField
                notesField

                if viewModel.canDelete {
                    Button("Delete Entry") {
                        Task { await viewModel.delete() }
                    }
                    .buttonStyle(DestructiveOutlineButtonStyle())
                }
            }
            .padding(.horizontal, Theme.dimensions.padding.l)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.padding.m - 2) {
            FieldLabel(viewModel.isEditing ? "Edit Entry" : "New Entry")

            TextField(
                "",
                text: titleBinding,
                prompt: Text("What did you work on?")
                    .foregroundColor(Theme.pallete.placeholderColor),
                axis: .vertical
            )
            .font(Theme.typography.formTitle)
            .foregroundStyle(Theme.pallete.onBackgroundColor)

            Rectangle()
                .fill(Theme.pallete.surfaceColorVariant)
                .frame(height: 2)
        }
    }

    private var dayField: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.snappy) { isDayPickerExpanded.toggle() }
            } label: {
                HStack(spacing: 13) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.pallete.iconColor)

                    VStack(alignment: .leading, spacing: 2) {
                        FieldLabel("Day")
                        Text(dayText)
                            .font(Theme.typography.dayValue)
                            .foregroundStyle(Theme.pallete.onBackgroundColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.pallete.iconColorVariant)
                        .rotationEffect(.degrees(isDayPickerExpanded ? 90 : 0))
                }
                .padding(.horizontal, 17)
                .frame(minHeight: 60)
            }
            .buttonStyle(.plain)

            if isDayPickerExpanded {
                DatePicker(
                    "Day",
                    selection: dayBinding,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(Theme.pallete.primaryColorVariant)
                .padding(.horizontal, Theme.dimensions.padding.m)
                .padding(.bottom, Theme.dimensions.padding.m)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.dimensions.radius.m)
                .fill(Theme.pallete.surfaceColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.dimensions.radius.m)
                .stroke(Theme.pallete.surfaceColorVariant, lineWidth: 1)
        )
    }

    private var durationField: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.padding.m) {
            FieldLabel("Duration")

            HStack(alignment: .firstTextBaseline, spacing: Theme.dimensions.padding.s) {
                TextField(
                    "",
                    text: durationBinding,
                    prompt: Text("0").foregroundColor(Theme.pallete.placeholderColor)
                )
                .font(Theme.typography.formTitle)
                .foregroundStyle(Theme.pallete.primaryColorVariant)
                .keyboardType(.decimalPad)

                Text("hours")
                    .font(Theme.typography.button)
                    .foregroundStyle(Theme.pallete.primaryColorVariant)
            }

            Rectangle()
                .fill(Theme.pallete.surfaceColorVariant)
                .frame(height: 2)

            HStack(spacing: Theme.dimensions.padding.s + 2) {
                ForEach(Self.durationQuickPicks, id: \.self) { value in
                    let isSelected = viewModel.state.durationText == value
                    Button("\(value) h") {
                        viewModel.updateDuration(isSelected ? "" : value)
                    }
                    .buttonStyle(ChipButtonStyle(isSelected: isSelected))
                }
            }
        }
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.padding.m - 2) {
            FieldLabel("Notes")

            TextField(
                "",
                text: notesBinding,
                prompt: Text("Anything worth remembering later.")
                    .foregroundColor(Theme.pallete.placeholderColor),
                axis: .vertical
            )
            .font(Theme.typography.body)
            .foregroundStyle(Theme.pallete.onBackgroundColor)
            .lineLimit(4, reservesSpace: true)
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
        }
    }

    private var dayText: String {
        EntryDayDateFormatter().string(from: viewModel.state.day)
    }

    private var titleBinding: Binding<String> {
        Binding(get: { viewModel.state.title }, set: { viewModel.updateTitle($0) })
    }

    private var dayBinding: Binding<Date> {
        Binding(get: { viewModel.state.day }, set: { viewModel.updateDay($0) })
    }

    private var durationBinding: Binding<String> {
        Binding(get: { viewModel.state.durationText }, set: { viewModel.updateDuration($0) })
    }

    private var notesBinding: Binding<String> {
        Binding(get: { viewModel.state.notes }, set: { viewModel.updateNotes($0) })
    }
}

private struct FieldLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text.uppercased())
            .font(Theme.typography.label)
            .tracking(Theme.typography.labelTracking)
            .foregroundStyle(Theme.pallete.onSurfaceColorVariant)
    }
}

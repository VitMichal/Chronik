//
//  AddEntryView.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import SwiftUI

struct AddEntryView<VM: AddEntryViewModel>: View {
    private let viewModel: VM

    init(viewModel: VM) {
        self.viewModel = viewModel
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: titleBinding)
            }
            Section {
                DatePicker("Day", selection: dayBinding, displayedComponents: .date)
            }
            Section {
                TextField("Duration (hours)", text: durationBinding)
                    .keyboardType(.decimalPad)
                TextField("Notes", text: notesBinding, axis: .vertical)
            }
        }
        .navigationTitle("New Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    viewModel.cancel()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.save() }
                }
                .disabled(!viewModel.isSaveEnabled)
            }
        }
        .onAppear { viewModel.reset() }
        .alert(
            "Could not save Entry",
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

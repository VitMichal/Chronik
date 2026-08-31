import SwiftUI

struct EntryFormView<VM: EntryFormViewModel>: View {
    @State private var viewModel: VM

    init(viewModel: VM) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        LoadableView(
            viewModel.loadState,
            retryAction: { Task { await viewModel.load() } }
        ) { _ in
            form
        }
        .navigationTitle(viewModel.isEditing ? "Edit Entry" : "New Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.canDelete {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete") {
                        Task { await viewModel.delete() }
                    }
                    .foregroundStyle(Theme.pallete.errorColor)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.save() }
                }
                .disabled(!viewModel.isSaveEnabled)
            }
        }
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

    private var form: some View {
        Form {
            Section { TextField("Title", text: titleBinding) }
            Section { DatePicker("Day", selection: dayBinding, displayedComponents: .date) }
            Section {
                TextField("Duration (hours)", text: durationBinding)
                    .keyboardType(.decimalPad)
                TextField("Notes", text: notesBinding, axis: .vertical)
            }
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

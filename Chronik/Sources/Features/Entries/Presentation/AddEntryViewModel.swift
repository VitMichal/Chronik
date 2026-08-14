//
//  AddEntryViewModel.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation
import Observation

struct AddEntryState {
    var title: String = ""
    var day: Date
    var durationText: String = ""
    var notes: String = ""
    var errorMessage: String?
}

@MainActor
protocol AddEntryViewModel {
    var state: AddEntryState { get }
    var isSaveEnabled: Bool { get }
    func updateTitle(_ text: String)
    func updateDay(_ day: Date)
    func updateDuration(_ text: String)
    func updateNotes(_ text: String)
    func save() async
    func reset()
    func cancel()
    func dismissError()
}

@MainActor
@Observable
final class AddEntryViewModelImpl: AddEntryViewModel {

    var state: AddEntryState

    var isSaveEnabled: Bool {
        guard !trimmedTitle.isEmpty else { return false }
        return trimmedDuration.isEmpty || Decimal(string: trimmedDuration) != nil
    }

    private let service: EntryService
    private let navigator: any Navigator<EntryScreen>
    private let calendar: Calendar
    private let now: () -> Date

    init(
        service: EntryService,
        navigator: any Navigator<EntryScreen>,
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.service = service
        self.navigator = navigator
        self.calendar = calendar
        self.now = now
        self.state = AddEntryState(day: now())
    }

    func updateTitle(_ text: String) {
        state.title = text
    }

    func updateDay(_ day: Date) {
        state.day = day
    }

    func updateDuration(_ text: String) {
        state.durationText = text
    }

    func updateNotes(_ text: String) {
        state.notes = text
    }

    func save() async {
        guard isSaveEnabled else { return }
        do {
            let entry = Entry(
                id: UUID(),
                day: calendar.startOfDay(for: state.day),
                createdAt: now(),
                title: trimmedTitle,
                duration: parsedDuration,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes
            )
            try await service.add(entry)
            navigator.pop()
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }

    func reset() {
        state = AddEntryState(day: now())
    }

    func cancel() {
        navigator.pop()
    }

    func dismissError() {
        state.errorMessage = nil
    }

    private var trimmedTitle: String {
        state.title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedNotes: String {
        state.notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedDuration: String {
        state.durationText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedDuration: Decimal? {
        guard !trimmedDuration.isEmpty else { return nil }
        return Decimal(string: trimmedDuration)
    }
}

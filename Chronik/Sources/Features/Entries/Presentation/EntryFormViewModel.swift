import Foundation
import Observation

struct EntryFormState {
    var title: String = ""
    var day: Date
    var durationText: String = ""
    var notes: String = ""
    var errorMessage: String?
    var errorTitle: String = "Could not save Entry"
}

@MainActor
protocol EntryFormViewModel {
    var state: EntryFormState { get }
    var isEditing: Bool { get }
    var loadState: Loadable<Bool> { get }
    var canDelete: Bool { get }
    var isSaveEnabled: Bool { get }
    func updateTitle(_ text: String)
    func updateDay(_ day: Date)
    func updateDuration(_ text: String)
    func updateNotes(_ text: String)
    func load() async
    func save() async
    func delete() async
    func dismissError()
}

@MainActor
@Observable
final class EntryFormViewModelImpl: EntryFormViewModel {
    var state: EntryFormState
    private(set) var loadState: Loadable<Bool>

    var isEditing: Bool { entryID != nil }
    var canDelete: Bool { isEditing && loadState.getSuccess() != nil }
    var isSaveEnabled: Bool {
        guard loadState.getSuccess() != nil, !trimmedTitle.isEmpty else { return false }
        return trimmedDuration.isEmpty || Decimal(string: trimmedDuration) != nil
    }

    private let entryID: UUID?
    private let service: EntryService
    private let navigator: any Navigator<EntryScreen>
    private let calendar: Calendar
    private let now: () -> Date
    private var originalEntry: Entry?

    init(
        entryID: UUID? = nil,
        service: EntryService,
        navigator: any Navigator<EntryScreen>,
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.entryID = entryID
        self.service = service
        self.navigator = navigator
        self.calendar = calendar
        self.now = now
        self.state = EntryFormState(day: now())
        self.loadState = entryID == nil ? .success(true) : .loading
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

    func load() async {
        guard let entryID else { return }
        guard originalEntry == nil else { return }
        loadState = .loading
        do {
            guard let entry = try await service.fetch(by: entryID) else {
                throw StateError.general
            }
            originalEntry = entry
            state.title = entry.title
            state.day = entry.day
            state.durationText = entry.duration.map(String.init(describing:)) ?? ""
            state.notes = entry.notes ?? ""
            loadState = .success(true)
        } catch {
            loadState = .error(error)
        }
    }

    func save() async {
        guard isSaveEnabled else { return }
        do {
            let entry = makeEntry()
            if isEditing {
                try await service.update(entry)
            } else {
                try await service.add(entry)
            }
            navigator.pop()
        } catch {
            state.errorTitle = "Could not save Entry"
            state.errorMessage = error.localizedDescription
        }
    }

    func delete() async {
        guard let entryID, canDelete else { return }
        do {
            try await service.delete(by: entryID)
            navigator.pop()
        } catch {
            state.errorTitle = "Could not delete Entry"
            state.errorMessage = error.localizedDescription
        }
    }

    func dismissError() {
        state.errorMessage = nil
        state.errorTitle = "Could not save Entry"
    }

    private func makeEntry() -> Entry {
        Entry(
            id: originalEntry?.id ?? UUID(),
            day: calendar.startOfDay(for: state.day),
            createdAt: originalEntry?.createdAt ?? now(),
            title: trimmedTitle,
            duration: parsedDuration,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes
        )
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

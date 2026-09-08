//
//  EntriesViewModel.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation
import Observation
import Generic

public struct EntryRow: Identifiable, Equatable {
    public let id: UUID
    let title: String
    let duration: DurationDisplay?
    let notes: String?
    
    public init(id: UUID, title: String, duration: DurationDisplay?, notes: String?) {
        self.id = id
        self.title = title
        self.duration = duration
        self.notes = notes
    }
}

public struct DaySection: Identifiable, Equatable {
    public let id: Date
    let title: String
    var entries: [EntryRow]
    
    public init(id: Date, title: String, entries: [EntryRow]) {
        self.id = id
        self.title = title
        self.entries = entries
    }
}

@MainActor
public protocol EntriesViewModel: LoadableCollectionViewModel where State == DaySection {
    var state: LoadableCollection<DaySection> { get }
    func load() async
    func delete(_ id: UUID) async 
    func select(_ id: UUID)
    func openAddEntry()
}


@MainActor
@Observable
final class EntriesViewModelImpl: LoadableCollectionViewModelImpl<DaySection>, EntriesViewModel {

    private let service: EntryService
    private let navigator: any Navigator<EntryScreen>
    private let calendar: Calendar
    private let dayFormatter: any Generic.DateFormatter
    private var isRefreshing = false

    init(
        service: EntryService,
        navigator: any Navigator<EntryScreen>,
        calendar: Calendar = .current,
        dayFormatter: any Generic.DateFormatter = DayHeaderDateFormatter()
    ) {
        self.service = service
        self.navigator = navigator
        self.calendar = calendar
        self.dayFormatter = dayFormatter
    }

    func load() async {
        await refresh()
    }

    func delete(_ id: UUID) async {
        do {
            try await service.delete(by: id)
            await refresh()
        } catch {
            state = .error(error)
        }
    }

    func select(_ id: UUID) {
        navigator.navigateTo(.entryDetail(id))
    }

    func openAddEntry() {
        navigator.navigateTo(.addEntry)
    }

    @MainActor
    private func refresh() async {
        // The Work log is refreshed from two places — the list's `onAppear` and
        // the navigation stack returning to its root — and on iOS a pop fires
        // both. One fetch is enough; the second would only re-request the same
        // rows the first is already in flight for.
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let entries = try await service.fetchAll()
            state = .success(Self.group(entries, calendar: calendar, dayFormatter: dayFormatter))
        } catch {
            state = .error(error)
        }
    }

    private static func group(
        _ entries: [Entry],
        calendar: Calendar,
        dayFormatter: any Generic.DateFormatter
    ) -> [DaySection] {
        let sorted = entries.sorted { lhs, rhs in
            let lhsDay = calendar.startOfDay(for: lhs.day)
            let rhsDay = calendar.startOfDay(for: rhs.day)
            if lhsDay != rhsDay {
                return lhsDay > rhsDay
            }
            return lhs.createdAt > rhs.createdAt
        }
        var sections: [DaySection] = []
        for entry in sorted {
            let day = calendar.startOfDay(for: entry.day)
            let row = EntryRow(
                id: entry.id,
                title: entry.title,
                duration: entry.duration.map(DurationFormatter.display(from:)),
                notes: entry.notes
            )
            if var last = sections.last, last.id == day {
                last.entries.append(row)
                sections[sections.count - 1] = last
            } else {
                sections.append(
                    DaySection(
                        id: day,
                        title: dayFormatter.string(from: day),
                        entries: [row]
                    )
                )
            }
        }
        return sections
    }
}

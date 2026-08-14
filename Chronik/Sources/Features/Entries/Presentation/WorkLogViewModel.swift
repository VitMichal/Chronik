//
//  WorkLogViewModel.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation
import Observation

struct EntryRow: Identifiable, Equatable {
    let id: UUID
    let title: String
    let durationText: String?
    let notes: String?
}

struct DaySection: Identifiable, Equatable {
    let id: Date
    let title: String
    var entries: [EntryRow]
}

@MainActor
protocol WorkLogViewModel: LoadableCollectionViewModel where State == DaySection {
    var state: LoadableCollection<DaySection> { get }
    func load() async
    func delete(_ id: UUID) async 
    func select(_ id: UUID)
    func openAddEntry()
}


@MainActor
@Observable
final class WorkLogViewModelImpl: LoadableCollectionViewModelImpl<DaySection>, WorkLogViewModel {

    private let service: EntryService
    private let navigator: any Navigator<EntryScreen>
    private let calendar: Calendar
    private let dayFormatter: DateFormatter

    init(
        service: EntryService,
        navigator: any Navigator<EntryScreen>,
        calendar: Calendar = .current,
        dayFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMM"
            return formatter
        }()
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
        dayFormatter: DateFormatter
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
                durationText: entry.duration.map { Self.format(duration: $0) },
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

    private static func format(duration: Decimal) -> String {
        "\(duration) h"
    }
}

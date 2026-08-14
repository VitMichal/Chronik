//
//  EntryDetailViewModel.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import Foundation
import Observation

struct EntryDetailState: Identifiable, Equatable {
    let id: UUID
    let title: String
    let dayText: String
    let durationText: String?
    let notes: String?
}

@MainActor
protocol EntryDetailViewModel: LoadableViewModel where State == EntryDetailState {
    func load() async
    func delete() async
}

@MainActor
@Observable
final class EntryDetailViewModelImpl: LoadableViewModelImpl<EntryDetailState>, EntryDetailViewModel {

    private let id: UUID
    private let service: EntryService
    private let navigator: any Navigator<EntryScreen>
    private let calendar: Calendar
    private let dayFormatter: any DateFormatter

    init(
        id: UUID,
        service: EntryService,
        navigator: any Navigator<EntryScreen>,
        calendar: Calendar = .current,
        dayFormatter: any DateFormatter = DateFormatterImpl(dateFormat: "EEEE, d MMM yyyy")
    ) {
        self.id = id
        self.service = service
        self.navigator = navigator
        self.calendar = calendar
        self.dayFormatter = dayFormatter
    }

    func load() async {
        do {
            guard let entry = try await service.fetch(by: id) else {
                state = .error(StateError.general)
                return
            }
            state = .success(
                EntryDetailState(
                    id: entry.id,
                    title: entry.title,
                    dayText: dayFormatter.string(from: calendar.startOfDay(for: entry.day)),
                    durationText: entry.duration.map(DurationFormatter.string(from:)),
                    notes: entry.notes
                )
            )
        } catch {
            state = .error(error)
        }
    }

    func delete() async {
        do {
            try await service.delete(by: id)
            navigator.pop()
        } catch {
            state = .error(error)
        }
    }
}
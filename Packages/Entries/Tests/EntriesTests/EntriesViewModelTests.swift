//
//  EntriesViewModelTests.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import XCTest
import Generic
@testable import Entries

@MainActor
final class EntriesViewModelTests: XCTestCase {

    private var service: EntryServiceStub!
    private var navigator: NavigatorStub<EntryScreen>!
    private var calendar: Calendar!
    private var formatter: DateFormatterStub!

    override func setUp() {
        super.setUp()
        service = EntryServiceStub()
        navigator = NavigatorStub<EntryScreen>()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        formatter = DateFormatterStub()
    }

    private func makeSut() -> EntriesViewModelImpl {
        EntriesViewModelImpl(
            service: service,
            navigator: navigator,
            calendar: calendar,
            dayFormatter: formatter
        )
    }

    private func makeDay(_ day: Int, _ month: Int, year: Int = 2026, hour: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    private func makeEntry(id: UUID = UUID(), day: Date, createdAt: Date, title: String) -> Entry {
        Entry(id: id, day: day, createdAt: createdAt, title: title, duration: nil, notes: nil)
    }

    private func sections(of state: LoadableCollection<DaySection>) -> [DaySection] {
        guard case .success(let sections) = state else {
            XCTFail("Expected success state, got \(state)")
            return []
        }
        return sections
    }

    func testLoadGroupsEntriesByDay() async {
        let sut = makeSut()
        service.entries = [
            makeEntry(day: makeDay(11, 8, hour: 9), createdAt: makeDay(11, 8, hour: 9), title: "Stand-up"),
            makeEntry(day: makeDay(12, 8, hour: 9), createdAt: makeDay(12, 8, hour: 9), title: "PR review")
        ]

        await sut.load()
        await Task.yield()

        let sections = sections(of: sut.state)
        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections[0].entries.map(\.title), ["PR review"])
        XCTAssertEqual(sections[1].entries.map(\.title), ["Stand-up"])
    }

    func testLoadOrdersDaysNewestFirst() async {
        let sut = makeSut()
        formatter.stringsByDate = [
            makeDay(10, 8): "Monday, 10 Aug",
            makeDay(11, 8): "Tuesday, 11 Aug",
            makeDay(12, 8): "Wednesday, 12 Aug"
        ]
        service.entries = [
            makeEntry(day: makeDay(10, 8, hour: 9), createdAt: makeDay(10, 8, hour: 9), title: "oldest"),
            makeEntry(day: makeDay(12, 8, hour: 9), createdAt: makeDay(12, 8, hour: 9), title: "newest"),
            makeEntry(day: makeDay(11, 8, hour: 9), createdAt: makeDay(11, 8, hour: 9), title: "middle")
        ]

        await sut.load()
        await Task.yield()

        let sections = sections(of: sut.state)
        XCTAssertEqual(sections.map(\.title), ["Wednesday, 12 Aug", "Tuesday, 11 Aug", "Monday, 10 Aug"])
    }

    func testLoadOrdersEntriesWithinDayNewestFirst() async {
        let sut = makeSut()
        let day = makeDay(11, 8)
        service.entries = [
            makeEntry(day: day, createdAt: makeDay(11, 8, hour: 8), title: "morning"),
            makeEntry(day: day, createdAt: makeDay(11, 8, hour: 17), title: "evening")
        ]

        await sut.load()
        await Task.yield()

        let sections = sections(of: sut.state)
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].entries.map(\.title), ["evening", "morning"])
    }

    func testLoadGroupsEntriesByCalendarDayIgnoringTime() async {
        let sut = makeSut()
        let day = makeDay(11, 8)
        service.entries = [
            makeEntry(day: makeDay(11, 8, hour: 8), createdAt: makeDay(11, 8, hour: 8), title: "morning"),
            makeEntry(day: makeDay(11, 8, hour: 23), createdAt: makeDay(11, 8, hour: 23), title: "late night")
        ]

        await sut.load()
        await Task.yield()

        let sections = sections(of: sut.state)
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].entries.map(\.title), ["late night", "morning"])
    }

    func testLoadYieldsEmptySuccessWhenNoEntries() async {
        let sut = makeSut()

        await sut.load()
        await Task.yield()

        let sections = sections(of: sut.state)
        XCTAssertTrue(sections.isEmpty)
    }

    func testLoadYieldsErrorWhenServiceFails() async {
        let sut = makeSut()
        service.error = StateError.general

        await sut.load()
        await Task.yield()

        guard case .error = sut.state else {
            return XCTFail("Expected error state, got \(sut.state)")
        }
    }

    func testLoadOrdersDaysAcrossMidnightBoundary() async {
        let sut = makeSut()
        formatter.stringsByDate = [
            makeDay(11, 8): "Tuesday, 11 Aug",
            makeDay(12, 8): "Wednesday, 12 Aug"
        ]
        service.entries = [
            makeEntry(day: makeDay(11, 8, hour: 23), createdAt: makeDay(11, 8, hour: 23), title: "Aug 11 late"),
            makeEntry(day: makeDay(12, 8, hour: 0), createdAt: makeDay(12, 8, hour: 0), title: "Aug 12 early")
        ]

        await sut.load()
        await Task.yield()

        let sections = sections(of: sut.state)
        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections.map(\.title), ["Wednesday, 12 Aug", "Tuesday, 11 Aug"])
    }

    func testDeleteRemovesEntryViaServiceAndReloads() async {
        let sut = makeSut()
        let doomed = makeEntry(id: UUID(), day: makeDay(11, 8, hour: 9), createdAt: makeDay(11, 8, hour: 9), title: "doomed")
        let kept = makeEntry(id: UUID(), day: makeDay(11, 8, hour: 10), createdAt: makeDay(11, 8, hour: 10), title: "kept")
        service.entries = [kept, doomed]

        await sut.load()
        await Task.yield()
        XCTAssertEqual(service.deleteCallCount, 0)

        await sut.delete(doomed.id)
        await Task.yield()

        XCTAssertEqual(service.deleteCallCount, 1)
        let sections = sections(of: sut.state)
        XCTAssertEqual(sections.flatMap(\.entries).map(\.title), ["kept"])
    }

    func testSelectNavigatesToDetail() {
        let sut = makeSut()
        let id = UUID()

        sut.select(id)

        XCTAssertEqual(navigator.lastScreen, .entryDetail(id))
    }

    func testOpenAddEntryNavigatesToAddEntryForm() {
        let sut = makeSut()

        sut.openAddEntry()

        XCTAssertEqual(navigator.lastScreen, .addEntry)
    }
}

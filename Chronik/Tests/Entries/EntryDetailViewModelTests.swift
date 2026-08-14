//
//  EntryDetailViewModelTests.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import XCTest
@testable import Chronik

@MainActor
final class EntryDetailViewModelTests: XCTestCase {

    private var service: EntryServiceStub!
    private var navigator: NavigatorStub<EntryScreen>!
    private var calendar: Calendar!
    private var formatter: DateFormatterStub!
    private var id: UUID!

    override func setUp() {
        super.setUp()
        service = EntryServiceStub()
        navigator = NavigatorStub<EntryScreen>()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        formatter = DateFormatterStub()
        id = UUID()
    }

    private func makeSut() -> EntryDetailViewModelImpl {
        EntryDetailViewModelImpl(
            id: id,
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

    private func makeEntry() -> Entry {
        Entry(
            id: id,
            day: makeDay(11, 8, hour: 9),
            createdAt: makeDay(11, 8, hour: 9),
            title: "Stand-up",
            duration: Decimal(string: "1.5"),
            notes: "with the team"
        )
    }

    private func detail(of state: Loadable<EntryDetailState>) -> EntryDetailState {
        guard case .success(let detail) = state else {
            XCTFail("Expected success state, got \(state)")
            return EntryDetailState(id: UUID(), title: "", dayText: "", durationText: nil, notes: nil)
        }
        return detail
    }

    func testLoadStartsWithLoadingState() {
        let sut = makeSut()

        XCTAssertTrue(sut.state.isLoading())
    }

    func testLoadRendersTitleDayDurationAndNotes() async {
        let sut = makeSut()
        service.entries = [makeEntry()]
        formatter.stringsByDate = [makeDay(11, 8): "Tuesday, 11 Aug 2026"]

        await sut.load()
        await Task.yield()

        let detail = detail(of: sut.state)
        XCTAssertEqual(detail.id, id)
        XCTAssertEqual(detail.title, "Stand-up")
        XCTAssertEqual(detail.dayText, "Tuesday, 11 Aug 2026")
        XCTAssertEqual(detail.durationText, "1.5 h")
        XCTAssertEqual(detail.notes, "with the team")
    }

    func testLoadOmitsDurationAndNotesWhenMissing() async {
        let sut = makeSut()
        let entry = Entry(id: id, day: makeDay(11, 8), createdAt: makeDay(11, 8), title: "No extras")
        service.entries = [entry]

        await sut.load()
        await Task.yield()

        let detail = detail(of: sut.state)
        XCTAssertNil(detail.durationText)
        XCTAssertNil(detail.notes)
    }

    func testLoadYieldsErrorWhenEntryNotFound() async {
        let sut = makeSut()

        await sut.load()
        await Task.yield()

        guard case .error = sut.state else {
            return XCTFail("Expected error state, got \(sut.state)")
        }
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

    func testDeleteRemovesEntryAndPopsNavigator() async {
        let sut = makeSut()
        service.entries = [makeEntry()]
        navigator.navigateTo(.entryDetail(id))

        await sut.delete()
        await Task.yield()

        XCTAssertEqual(service.deleteCallCount, 1)
        XCTAssertNil(navigator.lastScreen)
    }

    func testDeleteFailureDoesNotPopNavigator() async {
        let sut = makeSut()
        service.entries = [makeEntry()]
        service.error = StateError.general
        navigator.navigateTo(.entryDetail(id))

        await sut.delete()
        await Task.yield()

        XCTAssertEqual(service.deleteCallCount, 0)
        XCTAssertEqual(navigator.lastScreen, .entryDetail(id))
        guard case .error = sut.state else {
            return XCTFail("Expected error state, got \(sut.state)")
        }
    }
}

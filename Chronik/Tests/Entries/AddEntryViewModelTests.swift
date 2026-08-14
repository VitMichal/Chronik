//
//  AddEntryViewModelTests.swift
//  Chronik
//
//  Created by Vít Míchal on 14.08.2026.
//

import XCTest
@testable import Chronik

@MainActor
final class AddEntryViewModelTests: XCTestCase {

    private var service: EntryServiceStub!
    private var navigator: NavigatorStub<EntryScreen>!
    private var calendar: Calendar!
    private var now: Date!

    override func setUp() {
        super.setUp()
        service = EntryServiceStub()
        navigator = NavigatorStub<EntryScreen>()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        now = makeDay(14, 8)
    }

    private func makeSut() -> AddEntryViewModelImpl {
        AddEntryViewModelImpl(
            service: service,
            navigator: navigator,
            calendar: calendar,
            now: { self.now }
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

    func testDayDefaultsToToday() {
        let sut = makeSut()

        XCTAssertEqual(sut.state.day, now)
    }

    func testUpdateDayChangesSelectedDay() {
        let sut = makeSut()
        let backdated = makeDay(1, 8)

        sut.updateDay(backdated)

        XCTAssertEqual(sut.state.day, backdated)
    }

    func testSaveDisabledWhenTitleIsEmpty() {
        let sut = makeSut()

        XCTAssertFalse(sut.isSaveEnabled)
    }

    func testSaveDisabledWhenTitleIsWhitespaceOnly() {
        let sut = makeSut()

        sut.updateTitle("   ")

        XCTAssertFalse(sut.isSaveEnabled)
    }

    func testSaveEnabledWhenTitleProvided() {
        let sut = makeSut()

        sut.updateTitle("Stand-up")

        XCTAssertTrue(sut.isSaveEnabled)
    }

    func testSaveEnabledWhenDurationIsEmpty() {
        let sut = makeSut()

        sut.updateTitle("Stand-up")

        XCTAssertTrue(sut.isSaveEnabled)
    }

    func testSaveDisabledWhenDurationIsInvalid() {
        let sut = makeSut()

        sut.updateTitle("Stand-up")
        sut.updateDuration("not-a-number")

        XCTAssertFalse(sut.isSaveEnabled)
    }

    func testSaveBuildsEntryAndPersistsViaService() async throws {
        let sut = makeSut()
        sut.updateTitle("  Stand-up  ")
        sut.updateDay(makeDay(10, 8))
        sut.updateDuration("1.5")
        sut.updateNotes("  with the team  ")

        await sut.save()

        XCTAssertEqual(service.addedEntries.count, 1)
        let entry = try XCTUnwrap(service.addedEntries.first)
        XCTAssertEqual(entry.title, "Stand-up")
        XCTAssertEqual(entry.day, calendar.startOfDay(for: makeDay(10, 8)))
        XCTAssertEqual(entry.duration, Decimal(string: "1.5"))
        XCTAssertEqual(entry.notes, "with the team")
        XCTAssertEqual(entry.createdAt, now)
    }

    func testSaveStoresNilDurationAndNotesWhenEmpty() async throws {
        let sut = makeSut()
        sut.updateTitle("Stand-up")

        await sut.save()

        let entry = try XCTUnwrap(service.addedEntries.first)
        XCTAssertNil(entry.duration)
        XCTAssertNil(entry.notes)
    }

    func testSavePopsNavigatorAfterSaving() async {
        let sut = makeSut()
        sut.updateTitle("Stand-up")
        navigator.navigateTo(.addEntry)

        await sut.save()

        XCTAssertNil(navigator.lastScreen)
    }

    func testSaveBlockedWhenTitleEmptyDoesNotCallService() async {
        let sut = makeSut()

        await sut.save()

        XCTAssertTrue(service.addedEntries.isEmpty)
        XCTAssertNil(navigator.lastScreen)
    }

    func testSaveBlockedWhenDurationInvalidDoesNotCallService() async {
        let sut = makeSut()
        sut.updateTitle("Stand-up")
        sut.updateDuration("abc")
        navigator.navigateTo(.addEntry)

        await sut.save()

        XCTAssertTrue(service.addedEntries.isEmpty)
        XCTAssertEqual(navigator.lastScreen, .addEntry)
    }

    func testSaveFailureShowsErrorAndDoesNotPop() async {
        let sut = makeSut()
        sut.updateTitle("Stand-up")
        service.error = StateError.general
        navigator.navigateTo(.addEntry)

        await sut.save()

        XCTAssertNotNil(sut.state.errorMessage)
        XCTAssertEqual(navigator.lastScreen, .addEntry)
    }

    func testCancelPopsNavigator() {
        let sut = makeSut()
        navigator.navigateTo(.addEntry)

        sut.cancel()

        XCTAssertNil(navigator.lastScreen)
    }

    func testResetClearsFormAndRestoresToday() {
        let sut = makeSut()
        sut.updateTitle("Stand-up")
        sut.updateDay(makeDay(10, 8))
        sut.updateDuration("1.5")
        sut.updateNotes("notes")

        sut.reset()

        XCTAssertEqual(sut.state.title, "")
        XCTAssertEqual(sut.state.day, now)
        XCTAssertEqual(sut.state.durationText, "")
        XCTAssertEqual(sut.state.notes, "")
        XCTAssertNil(sut.state.errorMessage)
    }
}

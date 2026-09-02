import XCTest
import Generic
@testable import Entries

@MainActor
final class EntryFormViewModelTests: XCTestCase {
    private var service: EntryServiceStub!
    private var navigator: NavigatorStub<EntryScreen>!
    private var calendar: Calendar!
    private var now: Date!
    private var id: UUID!

    override func setUp() {
        super.setUp()
        service = EntryServiceStub()
        navigator = NavigatorStub<EntryScreen>()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        now = makeDay(14, 8)
        id = UUID()
    }

    private func makeSut(entryID: UUID? = nil) -> EntryFormViewModelImpl {
        EntryFormViewModelImpl(
            entryID: entryID,
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

    private func makeEntry() -> Entry {
        Entry(
            id: id,
            day: makeDay(11, 8, hour: 9),
            createdAt: makeDay(11, 8, hour: 10),
            title: "Stand-up",
            duration: Decimal(string: "1.5"),
            notes: "with the team"
        )
    }

    func testAddModeStartsWithTodayAndDoesNotExposeDelete() {
        let sut = makeSut()

        XCTAssertFalse(sut.isEditing)
        XCTAssertFalse(sut.canDelete)
        XCTAssertEqual(sut.state.day, now)
        XCTAssertEqual(sut.state.title, "")
    }

    func testAddModeSavesNewEntry() async throws {
        let sut = makeSut()
        sut.updateDay(makeDay(10, 8, hour: 9))
        sut.updateTitle("  Stand-up  ")
        sut.updateDuration("1.5")
        sut.updateNotes("  with the team  ")

        await sut.save()

        let entry = try XCTUnwrap(service.addedEntries.first)
        XCTAssertEqual(entry.title, "Stand-up")
        XCTAssertEqual(entry.id.uuidString.isEmpty, false)
        XCTAssertEqual(entry.createdAt, now)
        XCTAssertEqual(entry.day, calendar.startOfDay(for: makeDay(10, 8)))
        XCTAssertEqual(entry.duration, Decimal(string: "1.5"))
        XCTAssertEqual(entry.notes, "with the team")
        XCTAssertNil(navigator.lastScreen)
    }

    func testInvalidDurationBlocksSaving() async {
        let sut = makeSut()
        sut.updateTitle("Stand-up")
        sut.updateDuration("not-a-number")

        await sut.save()

        XCTAssertTrue(service.addedEntries.isEmpty)
        XCTAssertNil(navigator.lastScreen)
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

    func testBlankTitleBlocksSaving() async {
        let sut = makeSut()
        sut.updateTitle("   ")

        await sut.save()

        XCTAssertTrue(service.addedEntries.isEmpty)
    }

    func testEditModeLoadsExistingEntryIntoForm() async throws {
        let sut = makeSut(entryID: id)
        service.entries = [makeEntry()]

        await sut.load()

        XCTAssertTrue(sut.isEditing)
        XCTAssertTrue(sut.canDelete)
        XCTAssertEqual(sut.state.title, "Stand-up")
        XCTAssertEqual(sut.state.day, makeDay(11, 8, hour: 9))
        XCTAssertEqual(sut.state.durationText, "1.5")
        XCTAssertEqual(sut.state.notes, "with the team")
    }

    func testEditModeLoadFailureExposesErrorState() async {
        let sut = makeSut(entryID: id)
        service.error = StateError.general

        await sut.load()

        XCTAssertNotNil(sut.loadState.getError())
    }

    func testEditModeLoadFailureExposesErrorWhenEntryIsMissing() async {
        let sut = makeSut(entryID: id)

        await sut.load()

        XCTAssertNotNil(sut.loadState.getError())
    }

    func testEditModeUpdatesEntryAndPreservesIdentityAndCreationDate() async throws {
        let original = makeEntry()
        service.entries = [original]
        let sut = makeSut(entryID: id)
        await sut.load()
        sut.updateTitle("Updated")
        sut.updateDay(makeDay(12, 8))

        await sut.save()

        let updated = try XCTUnwrap(service.updatedEntries.first)
        XCTAssertEqual(updated.id, original.id)
        XCTAssertEqual(updated.createdAt, original.createdAt)
        XCTAssertEqual(updated.title, "Updated")
        XCTAssertNil(navigator.lastScreen)
    }

    func testEditModeUpdateFailureShowsErrorAndDoesNotPop() async {
        service.entries = [makeEntry()]
        let sut = makeSut(entryID: id)
        navigator.navigateTo(.entryDetail(id))
        await sut.load()
        service.error = StateError.general

        await sut.save()

        XCTAssertNotNil(sut.state.errorMessage)
        XCTAssertEqual(navigator.lastScreen, .entryDetail(id))
    }

    func testAddModeStoresNilOptionalFieldsWhenEmpty() async throws {
        let sut = makeSut()
        sut.updateTitle("Stand-up")

        await sut.save()

        let entry = try XCTUnwrap(service.addedEntries.first)
        XCTAssertNil(entry.duration)
        XCTAssertNil(entry.notes)
    }

    func testEditModeDeletesEntry() async throws {
        service.entries = [makeEntry()]
        let sut = makeSut(entryID: id)
        navigator.navigateTo(.entryDetail(id))
        await sut.load()

        await sut.delete()

        XCTAssertEqual(service.deleteCallCount, 1)
        XCTAssertNil(navigator.lastScreen)
    }

    func testEditModeDeleteFailureShowsErrorAndDoesNotPop() async {
        service.entries = [makeEntry()]
        let sut = makeSut(entryID: id)
        navigator.navigateTo(.entryDetail(id))
        await sut.load()
        service.error = StateError.general

        await sut.delete()

        XCTAssertNotNil(sut.state.errorMessage)
        XCTAssertEqual(navigator.lastScreen, .entryDetail(id))
    }

    func testAddModeDeleteDoesNothing() async {
        let sut = makeSut()
        navigator.navigateTo(.addEntry)

        await sut.delete()

        XCTAssertEqual(navigator.lastScreen, .addEntry)
        XCTAssertEqual(service.deleteCallCount, 0)
    }
}

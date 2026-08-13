import XCTest
import Chronik

final class AccommodationsViewModelTests: XCTestCase {
    
    var sut: AccommodationsViewModelImpl!
    
    public func makeSut(
        accommodationsService: AccommodationsService = AccommodationsServiceStub(),
        accommodationImagesService: AccommodationImagesService = AccommodationImagesServiceStub(),
        navigator: any Navigator<AccommodationScreen> = NavigatorStub<AccommodationScreen>()
    ) {
        sut = AccommodationsViewModelImpl(
            accommodationsService: accommodationsService,
            accommodationImagesService: accommodationImagesService,
            navigator: navigator
        )
    }
    
    func test_initialState_isLoading() {
        makeSut()
        
        XCTAssertTrue(sut.state.isLoading())
    }
    
    func test_givenSuccess_whenFetch_thenStateIsFilled() async {
        makeSut(accommodationsService: AccommodationsServiceStub(fetchResult: .success([
            Accommodation(id: UUID(), title: "Beach House", city: "Miami", country: "USA", price: 123.45, ratingAvg: 4.5, imageUrl: nil),
            Accommodation(id: UUID(), title: "Mountain Cabin", city: "Denver", country: "USA", price: 6.7, ratingAvg: 4.2, imageUrl: "pic.jpg"),
        ])))
        
        await sut.fetch()
        
        let states = sut.state.getSuccess()
        XCTAssertEqual(states?.count, 2)
        XCTAssertEqual(states?[0].title, "Beach House")
        XCTAssertEqual(states?[0].location, "Miami, USA")
        XCTAssertEqual(states?[0].price, "€123.45 / night")
        XCTAssertEqual(states?[0].rating, "4.5")
        XCTAssertEqual(states?[1].title, "Mountain Cabin")
        XCTAssertEqual(states?[1].location, "Denver, USA")
        XCTAssertEqual(states?[1].price, "€6.7 / night")
        XCTAssertEqual(states?[1].rating, "4.2")
    }
    
    func test_givenEmptySuccess_whenFetch_thenStateIsEmpty() async {
        let service = AccommodationsServiceStub(fetchResult: .success([]))
        makeSut(accommodationsService: service)
        
        await sut.fetch()
        
        let states = sut.state.getSuccess()
        XCTAssertTrue(states?.isEmpty ?? false)
    }
    
    func test_givenError_whenFetch_thenStateIsError() async {
        makeSut(accommodationsService: AccommodationsServiceStub(fetchResult: .failure(StateError.general)))
        
        await sut.fetch()
        
        XCTAssertNotNil(sut.state.getError())
    }
    
    func test_givenImageServiceReturnsImage_whenFetch_thenImageUrlIsPopulated() async {
        makeSut(
            accommodationsService: AccommodationsServiceStub(fetchResult: .success([
                Accommodation(id: UUID(), title: "Beach House", city: "Miami", country: "USA", price: 123.45, ratingAvg: 4.5, imageUrl: nil),
            ])),
            accommodationImagesService: AccommodationImagesServiceStub(fetchResult: .success([
                AccommodationImage(url: "https://example.com/image.jpg")
            ]))
        )
        
        await sut.fetch()
        
        let states = sut.state.getSuccess()
        XCTAssertEqual(states?.count, 1)
        XCTAssertEqual(try? states?[0].imageUrl?.get(), "https://example.com/image.jpg")
    }
    
    func test_givenImageServiceReturnsMultipleImages_whenFetch_thenOnlyFirstIsUsed() async {
        makeSut(
            accommodationsService: AccommodationsServiceStub(fetchResult: .success([
                Accommodation(id: UUID(), title: "Beach House", city: "Miami", country: "USA", price: 123.45, ratingAvg: 4.5, imageUrl: nil),
            ])),
            accommodationImagesService: AccommodationImagesServiceStub(fetchResult: .success([
                AccommodationImage(url: "https://example.com/first.jpg"),
                AccommodationImage(url: "https://example.com/second.jpg")
            ]))
        )
        
        await sut.fetch()
        
        let states = sut.state.getSuccess()
        XCTAssertEqual(try? states?[0].imageUrl?.get(), "https://example.com/first.jpg")
    }
    
    func test_givenImageServiceFailure_whenFetch_thenStateIsStillSuccessWithNilImageUrl() async {
        makeSut(
            accommodationsService: AccommodationsServiceStub(fetchResult: .success([
                Accommodation(id: UUID(), title: "Beach House", city: "Miami", country: "USA", price: 123.45, ratingAvg: 4.5, imageUrl: nil),
            ])),
            accommodationImagesService: AccommodationImagesServiceStub(fetchResult: .failure(StateError.general))
        )
        
        await sut.fetch()
        
        let states = sut.state.getSuccess()
        XCTAssertEqual(states?.count, 1)
        XCTAssertNil(try? states?[0].imageUrl?.get())
    }
    
    func test_givenLoadedContent_whenOpenDetail_thenNavigatorIsS() {
        let expectedUUID = UUID()
        let navigatorSpy = NavigatorStub<AccommodationScreen>()
        makeSut(
            accommodationsService: AccommodationsServiceStub(fetchResult: .success([
                Accommodation(id: UUID(), title: "Beach House", city: "Miami", country: "USA", price: 123.45, ratingAvg: 4.5, imageUrl: nil),
                Accommodation(id: UUID(), title: "Mountain Cabin", city: "Denver", country: "USA", price: 6.7, ratingAvg: 4.2, imageUrl: "pic.jpg"),
            ])),
            navigator: navigatorSpy
        )

        sut.openDetail(id: expectedUUID)

        guard
            let lastScreen = navigatorSpy.lastScreen,
            case AccommodationScreen.accommodationDetail(let accommodationId) = lastScreen
        else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(accommodationId == expectedUUID)
    }
}

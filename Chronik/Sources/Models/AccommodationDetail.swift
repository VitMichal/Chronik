import Foundation

public struct AccommodationDetail: Identifiable {
    public let id: UUID
    public let title: String
    public let city: String
    public let country: String
    public let ratingAvg: Double
    public let ratingCount: Int
    public let pricePerNight: Decimal
    public let description: String

    public init(
        id: UUID,
        title: String,
        city: String,
        country: String,
        ratingAvg: Double,
        ratingCount: Int,
        pricePerNight: Decimal,
        description: String,
    ) {
        self.id = id
        self.title = title
        self.city = city
        self.country = country
        self.ratingAvg = ratingAvg
        self.ratingCount = ratingCount
        self.pricePerNight = pricePerNight
        self.description = description
    }
}

public struct AccommodationDetailReview: Identifiable {
    public let id: UUID
    public let authorName: String
    public let authorAvatarUrl: String?
    public let rating: Int
    public let comment: String?

    public init(id: UUID, authorName: String, authorAvatarUrl: String?, rating: Int, comment: String?) {
        self.id = id
        self.authorName = authorName
        self.authorAvatarUrl = authorAvatarUrl
        self.rating = rating
        self.comment = comment
    }
}

import Foundation
import SwiftData

@Model
final class CachedMovieEntity {
    @Attribute(.unique) var id: Int
    var title: String
    var posterPath: String
    var releaseDate: Date?
    var overview: String?
    var backdropPath: String?
    var homepage: String?
    var budget: Double?
    var revenue: Double?
    var status: String?
    var runtime: Double?
    var popularity: Double?
    var genreIds: [Int]

    @Relationship(inverse: \CachedSpokenLanguageEntity.movies)
    var spokenLanguages: [CachedSpokenLanguageEntity]

    init(
        id: Int,
        title: String,
        posterPath: String,
        releaseDate: Date? = nil,
        overview: String? = nil,
        backdropPath: String? = nil,
        homepage: String? = nil,
        budget: Double? = nil,
        revenue: Double? = nil,
        spokenLanguages: [CachedSpokenLanguageEntity] = [],
        status: String? = nil,
        runtime: Double? = nil,
        popularity: Double? = nil,
        genreIds: [Int] = []
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.overview = overview
        self.backdropPath = backdropPath
        self.homepage = homepage
        self.budget = budget
        self.revenue = revenue
        self.spokenLanguages = spokenLanguages
        self.status = status
        self.runtime = runtime
        self.popularity = popularity
        self.genreIds = genreIds
    }
}

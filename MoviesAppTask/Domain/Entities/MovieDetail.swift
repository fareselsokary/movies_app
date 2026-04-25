import Foundation

struct MovieDetail: Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String
    let backdropPath: String
    let releaseDate: Date?
    let genres: [Genre]
    let homepage: String?
    let budget: Double?
    let revenue: Double?
    let spokenLanguages: [SpokenLanguage]
    let status: String?
    let runtime: Double?

    init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String,
        backdropPath: String,
        releaseDate: Date?,
        genres: [Genre],
        homepage: String?,
        budget: Double?,
        revenue: Double?,
        spokenLanguages: [SpokenLanguage],
        status: String?,
        runtime: Double?
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.genres = genres
        self.homepage = homepage
        self.budget = budget
        self.revenue = revenue
        self.spokenLanguages = spokenLanguages
        self.status = status
        self.runtime = runtime
    }
}

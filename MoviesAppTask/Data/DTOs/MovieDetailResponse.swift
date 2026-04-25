import Foundation

struct MovieDetailResponse: Decodable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String
    let backdropPath: String
    let releaseDate: Date?
    let genres: [GenreResponse]
    let homepage: String?
    let budget: Double?
    let revenue: Double?
    let spokenLanguages: [SpokenLanguageResponse]
    let status: String?
    let runtime: Double? // In minutes

    /// Coding keys to map snake_case API response fields to camelCase Swift properties.
    private enum CodingKeys: String, CodingKey {
        case id, title, overview, genres, homepage, budget, revenue, status, runtime
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case spokenLanguages = "spoken_languages"
    }

    init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String,
        backdropPath: String,
        releaseDate: Date?,
        genres: [GenreResponse],
        homepage: String?,
        budget: Double?,
        revenue: Double?,
        spokenLanguages: [SpokenLanguageResponse],
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

    /// Custom initializer for decoding, handling optional date format parsing.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? ""
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? ""
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath) ?? ""

        let dateString = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        if let dateString = dateString,
           let date = DateFormatter.yyyyMMdd.date(from: dateString) {
            releaseDate = date
        } else {
            releaseDate = nil
        }

        genres = try container.decode([GenreResponse].self, forKey: .genres)
        homepage = try container.decodeIfPresent(String.self, forKey: .homepage)
        budget = try container.decodeIfPresent(Double.self, forKey: .budget)
        revenue = try container.decodeIfPresent(Double.self, forKey: .revenue)
        spokenLanguages = try container.decode([SpokenLanguageResponse].self, forKey: .spokenLanguages)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        runtime = try container.decodeIfPresent(Double.self, forKey: .runtime)
    }
}

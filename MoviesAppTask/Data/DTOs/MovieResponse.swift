import Foundation

struct MovieResponse: Decodable, Identifiable, Hashable {
    let id: Int
    let title: String
    let posterPath: String
    let releaseDate: Date?
    let genreIds: [Int]
    let popularity: Double

    /// Coding keys to map snake_case API response fields to camelCase Swift properties.
    private enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case popularity
    }

    init(id: Int, title: String, posterPath: String, releaseDate: Date?, genreIds: [Int], popularity: Double) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.genreIds = genreIds
        self.popularity = popularity
    }

    /// Custom initializer for decoding, handling optional date format parsing.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? ""
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity) ?? 0

        let dateString = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        if let dateString = dateString,
           let date = DateFormatter.yyyyMMdd.date(from: dateString) {
            releaseDate = date
        } else {
            releaseDate = nil
        }
        genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds) ?? []
    }
}

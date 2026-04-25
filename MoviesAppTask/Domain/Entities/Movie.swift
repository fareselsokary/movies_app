import Foundation

struct Movie: Identifiable, Hashable {
    let id: Int
    let title: String
    let posterPath: String
    let releaseDate: Date?
    let genreIds: [Int]
    let popularity: Double

    init(
        id: Int,
        title: String,
        posterPath: String,
        releaseDate: Date?,
        genreIds: [Int],
        popularity: Double
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.genreIds = genreIds
        self.popularity = popularity
    }
}

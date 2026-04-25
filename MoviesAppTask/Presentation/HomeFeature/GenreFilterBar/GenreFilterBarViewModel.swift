import Combine
import Foundation

// MARK: - GenreFilterBarViewModel

class GenreFilterBarViewModel: Identifiable {
    let genres: [Genre]

    init(
        genres: [Genre]
    ) {
        self.genres = genres
    }
}

#if DEBUG
    extension GenreFilterBarViewModel {
        static let preview: GenreFilterBarViewModel = .init(
            genres: [
                Genre(id: 1, name: "Animation"),
                Genre(id: 2, name: "Comedy"),
                Genre(id: 3, name: "Adventure"),
                Genre(id: 4, name: "Adventure"),
                Genre(id: 5, name: "Adventure"),
                Genre(id: 6, name: "Adventure")
            ]
        )
    }
#endif

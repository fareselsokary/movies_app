import Foundation

// MARK: - MovieResponse → MovieModel

extension MovieResponse {
    /// Converts a `MovieResponse` (usually a network DTO) into a `MovieModel`,
    /// which is the clean domain model used across the app.
    func toDomain() -> Movie {
        Movie(
            id: id,
            title: title,
            posterPath: posterPath,
            releaseDate: releaseDate,
            genreIds: genreIds,
            popularity: popularity
        )
    }
}

// MARK: - MovieModel → CachedMovieModel

extension Movie {
    /// Converts a `MovieModel` into a `CachedMovieEntity` so that we can store
    /// the movie's basic info locally (e.g. in a database or persistent store).
    func toEntity() -> CachedMovieEntity {
        CachedMovieEntity(
            id: id,
            title: title,
            posterPath: posterPath,
            releaseDate: releaseDate,
            popularity: popularity,
            genreIds: genreIds
        )
    }
}

// MARK: - CachedMovieEntity → MovieModel

extension CachedMovieEntity {
    /// Converts a `CachedMovieModel` (local cached version) back into a `MovieModel`.
    /// Note: `genres` on the cached model contains full genre objects, so we map
    /// their `id` properties to populate the `genreIds` list expected in `MovieModel`.
    func toDomain() -> Movie {
        Movie(
            id: id,
            title: title,
            posterPath: posterPath,
            releaseDate: releaseDate,
            genreIds: genreIds,
            popularity: popularity ?? 0
        )
    }
}

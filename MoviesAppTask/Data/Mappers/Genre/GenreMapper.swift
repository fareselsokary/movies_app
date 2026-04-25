import Foundation

// MARK: - GenreModel → CachedGenreModel

extension Genre {
    /// Converts a `GenreModel` from the domain layer into a `CachedGenreModel`
    /// for local persistence (e.g., saving to a database).
    func toEntity() -> CachedGenreEntity {
        CachedGenreEntity(
            id: id,
            name: name
        )
    }
}

// MARK: - GenreResponse → GenreModel

extension GenreResponse {
    /// Converts a `GenreResponse` (typically a network DTO) into a `GenreModel`
    /// used within the domain layer.
    func toDomain() -> Genre {
        Genre(
            id: id,
            name: name
        )
    }
}

// MARK: - CachedGenreModel → GenreModel

extension CachedGenreEntity {
    /// Converts a `CachedGenreModel` (locally stored genre) back into a `GenreModel`
    /// for use in the app's domain layer.
    func toDomain() -> Genre {
        Genre(
            id: id,
            name: name
        )
    }
}

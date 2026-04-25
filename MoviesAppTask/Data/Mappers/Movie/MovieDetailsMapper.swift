import Foundation

// MARK: - MovieDetailResponse → MovieDetailModel

extension MovieDetailResponse {
    /// Converts a `MovieDetailResponse` (network DTO) into a `MovieDetailModel`
    /// for use across the app's domain layer.
    func toDomain() -> MovieDetail {
        MovieDetail(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            genres: genres.map { Genre(id: $0.id, name: $0.name) },
            homepage: homepage,
            budget: budget,
            revenue: revenue,
            spokenLanguages: spokenLanguages.map { SpokenLanguage(iso6391: $0.iso6391, name: $0.name) },
            status: status,
            runtime: runtime
        )
    }
}

// MARK: - MovieDetailModel → CachedMovieModel

extension MovieDetail {
    /// Converts a `MovieDetailModel` into a `CachedMovieEntity` for local persistence.
    func toEntity() -> CachedMovieEntity {
        CachedMovieEntity(
            id: id,
            title: title,
            posterPath: posterPath,
            releaseDate: releaseDate,
            overview: overview,
            backdropPath: backdropPath,
            homepage: homepage,
            budget: budget,
            revenue: revenue,
            spokenLanguages: spokenLanguages.map {
                CachedSpokenLanguageEntity(iso6391: $0.iso6391, name: $0.name)
            },
            status: status,
            runtime: runtime,
            genreIds: genres.map(\.id)
        )
    }
}

// MARK: - CachedMovieModel → MovieDetailModel

extension CachedMovieEntity {
    /// Converts a `CachedMovieModel` (local data) back into a `MovieDetailModel`.
    /// Falls back to empty strings for optional fields like `overview` and `backdropPath`.
    func toDomain(genres: [CachedGenreEntity]) -> MovieDetail {
        MovieDetail(
            id: id,
            title: title,
            overview: overview ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath ?? "",
            releaseDate: releaseDate,
            genres: genres.map { Genre(id: $0.id, name: $0.name) },
            homepage: homepage,
            budget: budget,
            revenue: revenue,
            spokenLanguages: spokenLanguages.map { SpokenLanguage(iso6391: $0.iso6391, name: $0.name) },
            status: status,
            runtime: runtime
        )
    }
}

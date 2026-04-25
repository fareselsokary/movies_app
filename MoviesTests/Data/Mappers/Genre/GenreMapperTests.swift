@testable import MoviesAppTask
import XCTest

final class GenreMapperTests: XCTestCase {

    // MARK: - GenreResponse → Genre

    func test_toDomain_fromGenreResponse_mapsIdAndName() {
        let response = GenreResponse(id: 28, name: "Action")
        let domain = response.toDomain()
        XCTAssertEqual(domain.id, 28)
        XCTAssertEqual(domain.name, "Action")
    }

    // MARK: - Genre → CachedGenreEntity

    func test_toEntity_fromGenre_mapsIdAndName() {
        let genre = Genre(id: 12, name: "Adventure")
        let entity = genre.toEntity()
        XCTAssertEqual(entity.id, 12)
        XCTAssertEqual(entity.name, "Adventure")
    }

    // MARK: - CachedGenreEntity → Genre

    func test_toDomain_fromCachedGenreEntity_mapsIdAndName() {
        let entity = CachedGenreEntity(id: 35, name: "Comedy")
        let domain = entity.toDomain()
        XCTAssertEqual(domain.id, 35)
        XCTAssertEqual(domain.name, "Comedy")
    }

    // MARK: - Round-trips

    func test_roundTrip_genreResponseThroughDomainToEntity_preservesData() {
        let response = GenreResponse(id: 99, name: "Thriller")
        let entity = response.toDomain().toEntity()
        XCTAssertEqual(entity.id, response.id)
        XCTAssertEqual(entity.name, response.name)
    }

    func test_roundTrip_entityToDomain_preservesData() {
        let entity = CachedGenreEntity(id: 18, name: "Drama")
        let domain = entity.toDomain()
        XCTAssertEqual(domain.id, entity.id)
        XCTAssertEqual(domain.name, entity.name)
    }
}

import Foundation

// MARK: - GenreListResponse

struct GenreListResponse: Decodable {
    let genres: [GenreResponse]

    init(genres: [GenreResponse]) {
        self.genres = genres
    }

    enum CodingKeys: CodingKey {
        case genres
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        genres = try container.decode([GenreResponse].self, forKey: .genres)
    }
}

// MARK: - GenreResponse

struct GenreResponse: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String

    enum CodingKeys: CodingKey {
        case id
        case name
    }

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
}

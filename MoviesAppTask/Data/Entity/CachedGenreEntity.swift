import Foundation
import SwiftData

@Model
final class CachedGenreEntity {
    @Attribute(.unique) var id: Int
    var name: String

    // Many-to-Many relationship back to movies
    @Relationship var movies: [CachedMovieEntity] = []

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    convenience init(from domainModel: Genre) {
        self.init(id: domainModel.id, name: domainModel.name)
    }
}

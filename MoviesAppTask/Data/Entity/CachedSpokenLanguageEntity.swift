import Foundation
import SwiftData

@Model
class CachedSpokenLanguageEntity {
    var iso6391: String?
    var name: String

    // Many-to-Many relationship back to movies
    @Relationship var movies: [CachedMovieEntity] = []

    init(iso6391: String?, name: String) {
        self.iso6391 = iso6391
        self.name = name
    }
}

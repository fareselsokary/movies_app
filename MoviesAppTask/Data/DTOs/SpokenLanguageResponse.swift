import Foundation

struct SpokenLanguageResponse: Decodable {
    let iso6391: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case iso6391 = "iso_639_1"
        case name
    }
}

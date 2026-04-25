import Foundation

struct SpokenLanguage {
    let iso6391: String?
    let name: String

    init(iso6391: String?, name: String) {
        self.iso6391 = iso6391
        self.name = name
    }
}

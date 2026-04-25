import Foundation

extension Sequence {
    func unique<T: Hashable>(by keySelector: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert(keySelector($0)).inserted }
    }
}

import Foundation

extension String? {
    var isEmptyOrNil: Bool {
        return self?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }

    var isNotEmptyOrNotNil: Bool {
        return !isEmptyOrNil
    }
}

extension String {
    func trimmingWhiteSpacesAndNewlines() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlankString: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

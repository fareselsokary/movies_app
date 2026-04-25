import SwiftUI

// MARK: - HideNavigationBarModifier

struct HideNavigationBarModifier: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content
                .toolbar(isHidden ? .hidden : .visible, for: .navigationBar)
        } else {
            content
                .navigationBarHidden(isHidden)
        }
    }
}

extension View {
    func setNavigationBarHidden(_ isHidden: Bool) -> some View {
        modifier(HideNavigationBarModifier(isHidden: isHidden))
    }
}

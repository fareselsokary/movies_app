import SwiftUI

// MARK: - GenreFilterItemView

struct GenreFilterItemView: View {
    let id: Int
    let name: String
    let isSelected: Bool

    var body: some View {
        Text(name)
            .font(.footnote)
            .foregroundStyle(isSelected ? Style.selectedTextColor : Style.unselectedTextColor)
            .padding(.horizontal, Style.horizontalPadding)
            .padding(.vertical, Style.verticalPadding)
            .background {
                RoundedRectangle(cornerRadius: Style.cornerRadius)
                    .stroke(Style.strokeColor)
                    .fill(isSelected ? Style.selectedFillColor : Style.unselectedFillColor)
            }
    }
}

// MARK: GenreFilterItemView.Style

private extension GenreFilterItemView {
    enum Style {
        static let cornerRadius: CGFloat = 15
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 4
        static let strokeColor: Color = .orange
        static let selectedTextColor: Color = .black
        static let unselectedTextColor: Color = .white
        static let selectedFillColor: Color = .orange
        static let unselectedFillColor: Color = .clear
    }
}

#Preview(body: {
    HStack(spacing: 16) {
        GenreFilterItemView(id: 1, name: "Animation", isSelected: true)
        GenreFilterItemView(id: 2, name: "Comedy", isSelected: false)
        GenreFilterItemView(id: 2, name: "Adventure", isSelected: true)
    }
})

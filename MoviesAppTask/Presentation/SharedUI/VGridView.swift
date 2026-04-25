import SwiftUI

struct VGridView<Item: Hashable, Content: View, EmptyContent: View>: View {
    private let columns: [GridItem]
    private let columnsSpacing: CGFloat
    private let rowSpacing: CGFloat
    private let items: [Item]
    private let content: (Item, Int) -> Content
    private let emptyView: () -> EmptyContent

    init(
        columns: Int = 2,
        columnsSpacing: CGFloat = 4,
        rowSpacing: CGFloat = 4,
        items: [Item],
        @ViewBuilder content: @escaping (Item, Int) -> Content,
        @ViewBuilder emptyView: @escaping () -> EmptyContent = { EmptyView() }
    ) {
        self.columns = Array(repeating: GridItem(.flexible(), spacing: columnsSpacing), count: columns)
        self.columnsSpacing = columnsSpacing
        self.rowSpacing = rowSpacing
        self.items = items
        self.content = content
        self.emptyView = emptyView
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if items.isEmpty {
                    emptyView()
                } else {
                    let itemSize = getItemSize(geometry)
                    LazyVGrid(columns: columns, spacing: rowSpacing) {
                        ForEach(Array(items.enumerated()), id: \.element) { index, item in
                            content(item, index)
                                .frame(width: itemSize.width)
                        }
                    }
                }
            }
        }
    }

    private func getItemSize(_ geometry: GeometryProxy) -> CGSize {
        let columnsCount = CGFloat(columns.count)
        let totalSpacing = columnsSpacing * (columnsCount - 1)
        let availableWidth = geometry.size.width - totalSpacing // Account for padding
        let width = availableWidth / columnsCount

        // Ensure width is never negative or too small
        let finalWidth = max(width, 10)

        return CGSize(width: finalWidth, height: finalWidth)
    }
}

#Preview {
    let sampleData = (0 ..< 30).map { i in
        Color.red
    }
    return VGridView(items: sampleData) { item, index in
        VStack {
            item
                .cornerRadius(6)
                .overlay {
                    Text("\(index)")
                }
        }
    }
    .padding(.horizontal, 4)
}

import SwiftUI

// MARK: - GenreFilterBarView

/// A horizontal scrollable bar displaying genre filter chips.
struct GenreFilterBarView: View {
    let viewModel: GenreFilterBarViewModel
    @Binding var selectedGenreId: Int?

    init(
        viewModel: GenreFilterBarViewModel,
        selectedGenreId: Binding<Int?>
    ) {
        self.viewModel = viewModel
        _selectedGenreId = selectedGenreId
    }

    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Style.spacing) {
                        ForEach(viewModel.genres, id: \.id) { genre in
                            GenreFilterItemView(
                                id: genre.id,
                                name: genre.name,
                                isSelected: selectedGenreId == genre.id
                            )
                            .padding(.vertical, Style.verticalPadding)
                            .onTapGesture {
                                withAnimation(.spring) {
                                    if selectedGenreId == genre.id {
                                        selectedGenreId = nil
                                    } else {
                                        selectedGenreId = genre.id
                                    }

                                    value.scrollTo(selectedGenreId, anchor: .center)
                                }
                            }
                            .id(genre.id)
                        }
                    }
                    .padding(.horizontal, Style.horizontalPadding)
                }
                .onAppear {
                    withAnimation(.spring) {
                        value.scrollTo(selectedGenreId, anchor: .center)
                    }
                }
            }
        }
    }
}

// MARK: GenreFilterBarView.Style

private extension GenreFilterBarView {
    enum Style {
        static let spacing: CGFloat = 8
        static let verticalPadding: CGFloat = 1
        static let horizontalPadding: CGFloat = 16
    }
}

#if DEBUG
    private struct GenreFilterBarView_Previews: View {
        @State private var selectedGenreId: Int? = 6

        var body: some View {
            GenreFilterBarView(
                viewModel: .preview,
                selectedGenreId: $selectedGenreId
            )
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        }
    }

    #Preview {
        GenreFilterBarView_Previews()
    }
#endif

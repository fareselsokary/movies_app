import Foundation

struct CachedPaginatedEntity<T: Identifiable> {
    /// The current page number of the results.
    let page: Int
    /// An array of domain models for the current page.
    let results: [T]
    /// The total number of pages available.
    let totalPages: Int
    /// The total number of results across all pages.
    let totalResults: Int

    init(
        page: Int,
        results: [T],
        totalPages: Int,
        totalResults: Int
    ) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }
}

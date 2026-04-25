@testable import MoviesAppTask
import XCTest

final class ParameterEncodingTests: XCTestCase {

    private func makeRequest(urlString: String = "https://api.example.com/test") -> URLRequest {
        URLRequest(url: URL(string: urlString)!)
    }

    // MARK: - URL Encoding — nil / empty guards

    func test_urlEncoding_nilParameters_doesNotModifyRequest() throws {
        var request = makeRequest()
        try ParameterEncoding.urlEncoding.encode(&request, with: nil)
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/test")
    }

    func test_urlEncoding_emptyParameters_doesNotModifyRequest() throws {
        var request = makeRequest()
        try ParameterEncoding.urlEncoding.encode(&request, with: [:])
        XCTAssertNil(request.httpBody)
    }

    // MARK: - URL Encoding — valid parameters

    func test_urlEncoding_intParameter_appendedAsQueryItem() throws {
        var request = makeRequest()
        try ParameterEncoding.urlEncoding.encode(&request, with: ["page": 3])
        XCTAssertTrue(request.url?.absoluteString.contains("page=3") == true)
    }

    func test_urlEncoding_stringParameter_appendedAsQueryItem() throws {
        var request = makeRequest()
        try ParameterEncoding.urlEncoding.encode(&request, with: ["sort_by": "popularity.desc"])
        XCTAssertTrue(request.url?.absoluteString.contains("sort_by=popularity.desc") == true)
    }

    func test_urlEncoding_boolParameter_appendedAsQueryItem() throws {
        var request = makeRequest()
        try ParameterEncoding.urlEncoding.encode(&request, with: ["include_adult": false])
        XCTAssertTrue(request.url?.absoluteString.contains("include_adult=false") == true)
    }

    func test_urlEncoding_doesNotSetHttpBody() throws {
        var request = makeRequest()
        try ParameterEncoding.urlEncoding.encode(&request, with: ["key": "value"])
        XCTAssertNil(request.httpBody)
    }

    // MARK: - URL Encoding — nil URL error

    func test_urlEncoding_nilURL_throwsInvalidURL() {
        var request = makeRequest()
        request.url = nil
        XCTAssertThrowsError(
            try ParameterEncoding.urlEncoding.encode(&request, with: ["key": "value"])
        ) { error in
            XCTAssertEqual(error as? NetworkError, .invalidURL)
        }
    }

    // MARK: - JSON Encoding — nil / empty guards

    func test_jsonEncoding_nilParameters_doesNotSetBody() throws {
        var request = makeRequest()
        try ParameterEncoding.jsonEncoding.encode(&request, with: nil)
        XCTAssertNil(request.httpBody)
    }

    func test_jsonEncoding_emptyParameters_doesNotSetBody() throws {
        var request = makeRequest()
        try ParameterEncoding.jsonEncoding.encode(&request, with: [:])
        XCTAssertNil(request.httpBody)
    }

    // MARK: - JSON Encoding — valid parameters

    func test_jsonEncoding_withParameters_setsHttpBody() throws {
        var request = makeRequest()
        try ParameterEncoding.jsonEncoding.encode(&request, with: ["key": "value"])
        XCTAssertNotNil(request.httpBody)
    }

    func test_jsonEncoding_withParameters_setsContentTypeHeader() throws {
        var request = makeRequest()
        try ParameterEncoding.jsonEncoding.encode(&request, with: ["key": "value"])
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func test_jsonEncoding_bodyDecodesBackCorrectly() throws {
        var request = makeRequest()
        try ParameterEncoding.jsonEncoding.encode(&request, with: ["name": "test"])
        let body = try XCTUnwrap(request.httpBody)
        let decoded = try JSONSerialization.jsonObject(with: body) as? [String: String]
        XCTAssertEqual(decoded?["name"], "test")
    }

    func test_jsonEncoding_doesNotModifyURL() throws {
        var request = makeRequest()
        let originalURL = request.url?.absoluteString
        try ParameterEncoding.jsonEncoding.encode(&request, with: ["key": "value"])
        XCTAssertEqual(request.url?.absoluteString, originalURL)
    }
}

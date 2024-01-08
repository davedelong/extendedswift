import XCTest
@testable import HTTP

final class HTTPTests: XCTestCase {
    func testExample() async throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let chain = URLSessionLoader(configuration: .ephemeral)
        
        var r = HTTPRequest()
        r.host = "swapi.dev"
        r.path = "/api/people/1"
        
        let result = await chain.load(request: r)
        print(result)
    }
}

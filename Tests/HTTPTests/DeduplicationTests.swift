import HTTP
import XCTest

class DeduplicationTests: XCTestCase {
    
    var loader = ManualLoader()
    
    func testRequestsWithNoDedupeIDBothExecute() async throws {
        let r1 = HTTPRequest()
        let r2 = HTTPRequest()
        
        let chain = await DeduplicatingLoader() --> loader
        
        let thenCount = expectation(description: "thens")
        thenCount.expectedFulfillmentCount = 2
        
        await loader
            .then { req, _ in try! await Task.sleep(for: .seconds(0.1)); thenCount.fulfill(); return .ok(req) }
            .then { req, _ in try! await Task.sleep(for: .seconds(0.1)); thenCount.fulfill(); return .ok(req) }
        
        let e1 = expectation(description: "r1")
        Task.detached {
            XCTAssertSuccess(await chain.load(request: r1))
            e1.fulfill()
        }
        
        let e2 = expectation(description: "r2")
        Task.detached {
            XCTAssertSuccess(await chain.load(request: r2))
            e2.fulfill()
        }
        
        try await allExpectations()
    }
    
    func testRequestsWithDifferentIDsBothExecute() async throws {
        let r1 = HTTPRequest.build { $0[option: \.deduplicationIdentifier] = "r1" }
        let r2 = HTTPRequest.build { $0[option: \.deduplicationIdentifier] = "r2" }
        
        let chain = await DeduplicatingLoader() --> loader
        
        let thenCount = expectation(description: "thens")
        thenCount.expectedFulfillmentCount = 2
        
        await loader
            .then { req, _ in try! await Task.sleep(for: .seconds(0.1)); thenCount.fulfill(); return .ok(req) }
            .then { req, _ in try! await Task.sleep(for: .seconds(0.1)); thenCount.fulfill(); return .ok(req) }
        
        let e1 = expectation(description: "r1")
        Task.detached {
            XCTAssertSuccess(await chain.load(request: r1))
            e1.fulfill()
        }
        
        let e2 = expectation(description: "r2")
        Task.detached {
            XCTAssertSuccess(await chain.load(request: r2))
            e2.fulfill()
        }
        
        try await allExpectations()
    }
    
    func testRequestsWithSameIDsDeduplicate() async throws {
        let r1 = HTTPRequest.build { $0[option: \.deduplicationIdentifier] = "r1" }
        let r2 = HTTPRequest.build { $0[option: \.deduplicationIdentifier] = "r1" }
        
        let chain = await DeduplicatingLoader() --> loader
        
        let thenCount = expectation(description: "thens")
        
        await loader
            .then { req, _ in try! await Task.sleep(for: .seconds(0.1)); thenCount.fulfill(); return .ok(req) }
            .then { req, _ in XCTFail(); return .failure(.cannotConnect, request: req) }
        
        let e1 = expectation(description: "r1")
        Task.detached {
            XCTAssertSuccess(await chain.load(request: r1))
            e1.fulfill()
        }
        
        let e2 = expectation(description: "r2")
        Task.detached {
            let result = await chain.load(request: r2)
            XCTAssertSuccess(result)
            XCTAssertEqual(result.response?[header: .xOriginalRequestID], r1.id.uuidString)
            e2.fulfill()
        }
        
        try await allExpectations()
    }
}

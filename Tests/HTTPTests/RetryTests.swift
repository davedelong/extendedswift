import HTTP
import XCTest

class RetryTests: XCTestCase {
    
    var manual = ManualLoader()
    
    func testRequestWithoutStrategyDoesNotRetry() async throws {
        let chain = await RetryLoader() --> manual
        
        let r1 = HTTPRequest()
        let e1 = expectation(description: "r1")
        
        await manual.then { req, _ in e1.fulfill(); return .ok(req) }
        await manual.then { req, _ in
            XCTFail()
            return .failure(.cannotConnect, request: req)
        }
        
        let result = await chain.load(request: r1)
        
        XCTAssertSuccess(result)
        XCTAssertEqual(result.response?[header: .xRetryCount], "0")
        try await allExpectations()
    }
    
    func testCancelledRequestDoesNotRetry() async throws {
        let chain = await RetryLoader() --> manual
        
        let r1 = HTTPRequest.build {
            $0[option: \.retryStrategy] = BackoffRetry.immediately(maximumNumberOfAttempts: 3)
        }
        let e1 = expectation(description: "r1")
        
        await manual.then { req, _ in e1.fulfill(); return .failure(.cancelled, request: req) }
        await manual.then { req, _ in
            XCTFail()
            return .failure(.cannotConnect, request: req)
        }
        
        let result = await chain.load(request: r1)
        
        XCTAssertFailure(result)
        try await allExpectations()
    }
    
    func testBasicRetry() async throws {
        let chain = await RetryLoader() --> manual
        
        let r1 = HTTPRequest.build {
            $0[option: \.retryStrategy] = BackoffRetry.immediately(maximumNumberOfAttempts: 3)
        }
        let e1 = expectation(description: "r1")
        e1.expectedFulfillmentCount = 3
        
        await manual.then { req, _ in e1.fulfill(); return .failure(.cannotConnect, request: req) }
        await manual.then { req, _ in e1.fulfill(); return .failure(.cannotConnect, request: req) }
        await manual.then { req, _ in e1.fulfill(); return .ok(req) }
        await manual.then { req, _ in
            XCTFail()
            return .failure(.cannotConnect, request: req)
        }
        
        let result = await chain.load(request: r1)
        
        XCTAssertSuccess(result)
        XCTAssertEqual(result.response?[header: .xRetryCount], "2")
        try await allExpectations()
    }
    
}

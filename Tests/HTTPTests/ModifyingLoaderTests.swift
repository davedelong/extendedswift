import HTTP
import XCTest

class ModifyingLoaderTests: XCTestCase {
    
    let manual = ManualLoader()
    
    func testRequestModification() async throws {
        let r1 = HTTPRequest()
        XCTAssertNil(r1.path)
        
        let modifier = ModifyingLoader(requestModifier: { req in
            req.path = "test"
        })
        
        let chain = await modifier --> manual
        
        let e1 = expectation(description: "r1")
        await manual.then { req, _ in
            XCTAssertEqual(req.path, "test")
            e1.fulfill()
            return .ok(req)
        }
        
        let result = await chain.load(request: r1)
        
        XCTAssertSuccess(result)
        try await allExpectations()
    }
    
    func testResponseModification() async throws {
        let r1 = HTTPRequest()
        
        let modifier = ModifyingLoader(responseModifier: { response in
            response.status = .ok
        })
        
        let chain = await modifier --> manual
        
        let e1 = expectation(description: "r1")
        await manual.then { req, _ in
            e1.fulfill()
            return .internalServerError(req)
        }
        
        let result = await chain.load(request: r1)
        
        XCTAssertSuccess(result)
        XCTAssertEqual(result.response?.status, .ok)
        try await allExpectations()
    }
    
    func testSkippedModification() async throws {
        let r1 = HTTPRequest()
        
        let modifier = ModifyingLoader(responseModifier: { response in
            XCTFail()
            response.status = .ok
        })
        
        let chain = await modifier --> manual
        
        let e1 = expectation(description: "r1")
        await manual.then { req, _ in
            e1.fulfill()
            return .failure(.internal, request: req)
        }
        
        let result = await chain.load(request: r1)
        
        XCTAssertFailure(result)
        try await allExpectations()
    }
    
    func testResultModification() async throws {
        let r1 = HTTPRequest()
        
        let modifier = ModifyingLoader(resultModifier: { result in
            let req = result.request
            result = .ok(req)
        })
        
        let chain = await modifier --> manual
        
        let e1 = expectation(description: "r1")
        await manual.then { req, _ in
            e1.fulfill()
            return .failure(.internal, request: req)
        }
        
        let result = await chain.load(request: r1)
        
        XCTAssertSuccess(result)
        XCTAssertEqual(result.response?.status, .ok)
        try await allExpectations()
    }
    
    func testReplacingRequestFailsLoading() async throws {
        let r1 = HTTPRequest()
        let r2 = HTTPRequest()
        
        let modifier = ModifyingLoader(requestModifier: { request in
            request = r2
        })
        
        let chain = await modifier --> manual
        await manual.then { req, _ in
            XCTFail()
            return .failure(.internal, request: req)
        }
        
        let result = await chain.load(request: r1)
        
        if let error = XCTAssertFailure(result) {
            XCTAssertEqual(error.code, .invalidRequest)
        }
    }
    
    func testReplacingResponseFailsLoading() async throws {
        let r1 = HTTPRequest()
        let r2 = HTTPRequest()
        
        let modifier = ModifyingLoader(responseModifier: { response in
            response = .ok(r2)
        })
        
        let chain = await modifier --> manual
        
        let e1 = expectation(description: "r1")
        await manual.then { req, _ in
            e1.fulfill()
            return .ok(req)
        }
        
        let result = await chain.load(request: r1)
        
        if let error = XCTAssertFailure(result) {
            XCTAssertEqual(error.code, .invalidResponse)
        }
        
        try await allExpectations()
    }
    
}

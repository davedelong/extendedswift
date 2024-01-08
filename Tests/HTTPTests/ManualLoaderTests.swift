import HTTP
import XCTest

class ManualLoaderTests: XCTestCase {
    
    var loader = ManualLoader()
    
    func testNoHandlers() async {
        let result = await loader.load(request: .init())
        XCTAssertFailure(result)
    }
    
    func testDefaultHandler() async throws {
        let expectation = self.expectation(description: #function)
        
        await loader.setDefaultHandler({ req, token in
            expectation.fulfill()
            return .ok(req)
        })
        
        let result = await loader.load(request: .init())
        XCTAssertSuccess(result)
        try await allExpectations()
    }
    
    func testSingleHandler() async {
        await loader.setDefaultHandler({ req, token in
            XCTFail()
            return .failure(.cannotConnect, request: req)
        })
        
        await loader.then { req, token in
            return .ok(req)
        }
        
        let result = await loader.load(request: .init())
        if let response = XCTAssertSuccess(result) {
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func testMultipleHandlers() async {
        await loader.setDefaultHandler({ req, token in
            XCTFail()
            return .failure(.cannotConnect, request: req)
        })
        
        await loader.then { req, _ in return .ok(req) }
        await loader.then { req, _ in return .internalServerError(req) }
        
        XCTAssertSuccess(await loader.load(request: .init()))
        
        if let response = XCTAssertSuccess(await loader.load(request: .init())) {
            XCTAssertEqual(response.status, .internalServerError)
        }
    }
    
    func testFallbackToDefaultHandler() async throws {
        let expectation = self.expectation(description: #function)
        
        await loader.setDefaultHandler({ req, _ in
            expectation.fulfill()
            return .internalServerError(req)
        })
        
        await loader.then { req, _ in return .ok(req) }
        
        XCTAssertSuccess(await loader.load(request: .init()))
        
        if let response = XCTAssertSuccess(await loader.load(request: .init())) {
            XCTAssertEqual(response.status, .internalServerError)
        }
        
        try await allExpectations()
    }
    
}

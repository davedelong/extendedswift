import XCTest

@discardableResult
public func XCTAssertSuccess<T, E: Error>(_ result: Result<T, E>, file: StaticString = #file, line: UInt = #line) -> T? {
    
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        XCTFail("Unexpected failure: \(error)", file: file, line: line)
        return nil
    }
    
}

@discardableResult
public func XCTAssertFailure<T, E: Error>(_ result: Result<T, E>, file: StaticString = #file, line: UInt = #line) -> E? {
    
    switch result {
    case .success(let value):
        XCTFail("Unexpected success: \(value)", file: file, line: line)
        return nil
    case .failure(let error):
        return error
    }
    
}

extension XCTestCase {
    
    @MainActor
    public func allExpectations(timeout: TimeInterval = 1.0) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.waitForExpectations(timeout: timeout, handler: { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            })
        }
    }
    
}

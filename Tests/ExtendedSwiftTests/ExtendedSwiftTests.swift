@_exported import XCTest
@testable @_exported import ExtendedSwift

func test(_ suiteName: StaticString? = nil, _ name: StaticString, perform test: @escaping @Sendable () async throws -> Void) {
    let harness = TestHarness(name: name, test: test)
    
    let suite: XCTestSuite
    if let suiteName {
        suite = XCTestSuite(name: suiteName.description)
    } else {
        suite = .default
    }
    suite.addTest(harness)
}

private class TestHarness: XCTest {
    
    private let _name: String
    override var name: String { _name }
    
    private let testAction: @Sendable () async throws -> Void
    
    init(name: StaticString, test: @escaping @Sendable () async throws -> Void) {
        self._name = name.description
        self.testAction = test
        
        super.init()
    }
    
    func test() async throws {
        try await testAction()
    }
    
}

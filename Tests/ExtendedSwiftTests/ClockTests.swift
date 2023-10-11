//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/17/23.
//

import XCTest
import ExtendedSwift

class ClockTests: XCTestCase {
    
    func testMutableClock() async throws {
        let user = UserClock()
        let mutable = user.mutableClock()
        
        var userNow = user.now
        var mutableNow = mutable.now
        XCTAssertEqual(userNow.timeIntervalSinceReferenceDate, mutableNow.timeIntervalSinceReferenceDate, accuracy: 0.1)
        
        let referenceDate = Date(timeIntervalSinceReferenceDate: 0)
        mutable.now = referenceDate
        
        userNow = user.now
        mutableNow = mutable.now
        XCTAssertNotEqual(userNow.timeIntervalSinceReferenceDate, mutableNow.timeIntervalSinceReferenceDate, accuracy: 0.1)
        XCTAssertEqual(mutableNow.timeIntervalSinceReferenceDate, 0, accuracy: 0.1)
        
        try await mutable.sleep(for: .seconds(1))
        
        mutableNow = mutable.now
        XCTAssertEqual(mutableNow.timeIntervalSinceReferenceDate, 1, accuracy: 0.1)
    }
    
    func testManualClock() async throws {
        let user = UserClock()
        let manual = user.manualClock()
        
        var userNow = user.now
        let manualNow = manual.now
        XCTAssertEqual(userNow.timeIntervalSinceReferenceDate, manualNow.timeIntervalSinceReferenceDate, accuracy: 0.1)
        
        try await user.sleep(for: .seconds(1))
        
        userNow = user.now
        var newManualNow = manual.now
        XCTAssertNotEqual(userNow.timeIntervalSinceReferenceDate, newManualNow.timeIntervalSinceReferenceDate, accuracy: 0.1)
        XCTAssertEqual(manualNow, newManualNow)
        
        manual.advance(by: .seconds(1))
        newManualNow = manual.now
        
        XCTAssertEqual(userNow.timeIntervalSinceReferenceDate, newManualNow.timeIntervalSinceReferenceDate, accuracy: 0.1)
    }
    
}

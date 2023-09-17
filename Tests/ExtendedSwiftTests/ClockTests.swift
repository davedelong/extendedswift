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
        mutable.setNow(referenceDate)
        
        userNow = user.now
        mutableNow = mutable.now
        XCTAssertNotEqual(userNow.timeIntervalSinceReferenceDate, mutableNow.timeIntervalSinceReferenceDate, accuracy: 0.1)
        XCTAssertEqual(mutableNow.timeIntervalSinceReferenceDate, 0, accuracy: 0.1)
        
        try await mutable.sleep(for: .seconds(1))
        
        mutableNow = mutable.now
        XCTAssertEqual(mutableNow.timeIntervalSinceReferenceDate, 1, accuracy: 0.1)
        
    }
    
}

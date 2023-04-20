//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/19/23.
//

import XCTest
import ExtendedSwift

class CountedSetTests: XCTestCase {
    
    func testEmpty() {
        let e = CountedSet<Int>()
        XCTAssertTrue(e.isEmpty)
        XCTAssertEqual(e.count, 0)
        
        var i = e.makeIterator()
        XCTAssertNil(i.next())
    }
    
    func testCreationFromSequence() {
        let e = CountedSet([1, 2, 3, 1, 2, 3])
        XCTAssertFalse(e.isEmpty)
        XCTAssertEqual(e.count, 6)
        XCTAssertTrue(e.contains(1))
        XCTAssertTrue(e.contains(2))
        XCTAssertTrue(e.contains(3))
        XCTAssertEqual(e.count(for: 1), 2)
        XCTAssertEqual(e.count(for: 2), 2)
        XCTAssertEqual(e.count(for: 3), 2)
        
        XCTAssertFalse(e.contains(4))
        XCTAssertEqual(e.count(for: 4), 0)
    }
    
    func testArrayLiteral() {
        let e: CountedSet = [1, 2, 3, 1, 2, 3]
        XCTAssertFalse(e.isEmpty)
        XCTAssertEqual(e.count, 6)
        XCTAssertTrue(e.contains(1))
        XCTAssertTrue(e.contains(2))
        XCTAssertTrue(e.contains(3))
        XCTAssertEqual(e.count(for: 1), 2)
        XCTAssertEqual(e.count(for: 2), 2)
        XCTAssertEqual(e.count(for: 3), 2)
        
        XCTAssertFalse(e.contains(4))
        XCTAssertEqual(e.count(for: 4), 0)
    }
    
    func testRemoval() {
        var e = CountedSet([1, 2, 3, 1, 2, 3])
        XCTAssertEqual(e.count(for: 1), 2)
        
        XCTAssertEqual(e.remove(1), 1)
        XCTAssertEqual(e.count(for: 1), 1)
        
        XCTAssertEqual(e.remove(1), 1)
        XCTAssertEqual(e.count(for: 1), 0)
        
        XCTAssertEqual(e.remove(1), nil)
    }
    
    func testIteration() {
        let e = CountedSet([1, 1, 1])
        var i = e.makeIterator()
        XCTAssertEqual(i.next(), 1)
        XCTAssertEqual(i.next(), 1)
        XCTAssertEqual(i.next(), 1)
        XCTAssertEqual(i.next(), nil)
        
        let e2 = CountedSet([1, 2, 3, 1, 2, 3])
        let a2 = Array(e2).sorted(by: <)
        XCTAssertEqual(a2, [1, 1, 2, 2, 3, 3])
    }
    
    func testIndices() {
        let e = CountedSet([1, 1, 1])
        var i = e.startIndex
        XCTAssertTrue(i < e.endIndex)
        XCTAssertFalse(i > e.endIndex)
        XCTAssertEqual(e[i], 1)
        
        i = e.index(after: i)
        XCTAssertEqual(e[i], 1)
        
        e.formIndex(after: &i)
        XCTAssertEqual(e[i], 1)
        
        let end = e.index(after: i)
        XCTAssertEqual(end, e.endIndex)
        
        let empty = CountedSet<Int>()
        XCTAssertEqual(empty.startIndex, empty.endIndex)
    }
    
    func testUnion() {
        let e1 = CountedSet([1, 2])
        let e2 = CountedSet([1, 3, 4])
        let u1 = e1.union(e2)
        XCTAssertEqual(u1, CountedSet([1, 1, 2, 3, 4]))
        
        var e3 = CountedSet([1, 2])
        let e4 = CountedSet([1, 3])
        e3.formUnion(e4)
        XCTAssertEqual(e3, CountedSet([1, 1, 2, 3]))
    }
    
    func testIntersection() {
        let e1 = CountedSet([1, 1, 2])
        let e2 = CountedSet([1, 1, 2, 2])
        let i1 = e1.intersection(e2)
        XCTAssertEqual(i1, CountedSet([1, 1, 2]))
        
        var e3 = CountedSet([1, 2, 2, 2, 3])
        let e4 = CountedSet([2, 2, 3, 4])
        e3.formIntersection(e4)
        XCTAssertEqual(e3, CountedSet([2, 2, 3]))
    }
    
    func testSubtraction() {
        let e1 = CountedSet([1, 1, 2, 3])
        let e2 = CountedSet([2, 2, 3, 4])
        let s1 = e1.subtracting(e2)
        XCTAssertEqual(s1, CountedSet([1, 1]))
        
        var e3 = CountedSet([2, 2, 3, 4])
        let e4 = CountedSet([2, 3, 3, 4])
        e3.subtract(e4)
        XCTAssertEqual(e3, CountedSet([2]))
    }
    
    func testSymmetricDifference() {
        let e1 = CountedSet([1, 1, 2, 3])
        let e2 = CountedSet([2, 2, 3, 3, 4])
        let d1 = e1.symmetricDifference(e2)
        XCTAssertEqual(d1, CountedSet([1, 1, 2, 3, 4]))
        
        var e3 = CountedSet([1, 2, 2, 3])
        let e4 = CountedSet([1, 2, 4])
        e3.formSymmetricDifference(e4)
        XCTAssertEqual(e3, CountedSet([2, 3, 4]))
    }
    
    func testDisjoint() {
        let e1 = CountedSet([1, 2, 3])
        let e2 = CountedSet([2, 3, 4])
        XCTAssertFalse(e1.isDisjoint(with: e2))
        
        let e3 = CountedSet([1, 2, 3])
        let e4 = CountedSet([4, 5, 6])
        XCTAssertTrue(e3.isDisjoint(with: e4))
    }
    
    func testSubsetAndSuperset() {
        let e1 = CountedSet([1, 1, 2, 2, 3, 3])
        let e2 = CountedSet([1, 2, 3])
        
        XCTAssertTrue(e1.isSubset(of: e1))
        XCTAssertTrue(e2.isSubset(of: e1))
        
        let e3 = CountedSet([1, 2, 3, 4])
        XCTAssertFalse(e3.isSubset(of: e1))
        
        XCTAssertTrue(e1.isSuperset(of: e1))
        XCTAssertTrue(e1.isSuperset(of: e2))
        
        XCTAssertFalse(e1.isSuperset(of: e3))
    }
    
    func testStrictSubsetAndSuperset() {
        let e1 = CountedSet([1, 1, 2, 2, 3, 3])
        let e2 = CountedSet([1, 2, 3])
        
        XCTAssertFalse(e1.isStrictSubset(of: e1))
        XCTAssertTrue(e2.isStrictSubset(of: e1))
        
        XCTAssertFalse(e1.isStrictSuperset(of: e1))
        XCTAssertTrue(e1.isStrictSuperset(of: e2))
    }
    
    func testUpdate() {
        let s1 = S(value: 1)
        let s2 = S(value: 1)
        XCTAssertTrue(s1 == s2)
        XCTAssertNotEqual(s1.id, s2.id)
        XCTAssertEqual(s1, s2)
        
        var e = CountedSet<S>()
        e.insert(s1)
        e.insert(s1)
        
        XCTAssertEqual(e.count(for: s1), 2)
        XCTAssertEqual(e.count(for: s2), 2)
        
        let a1 = Array(e)
        XCTAssertEqual(a1.count, 2)
        XCTAssertEqual(a1[0].id, s1.id)
        XCTAssertEqual(a1[1].id, s1.id)
        
        let old = e.update(with: s2)
        XCTAssertEqual(old?.id, s1.id)
        
        let a2 = Array(e)
        XCTAssertEqual(a2.count, 2)
        XCTAssertEqual(a2[0].id, s2.id)
        XCTAssertEqual(a2[1].id, s2.id)
    }
}

fileprivate struct S: Equatable, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
    
    let id = UUID()
    let value: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

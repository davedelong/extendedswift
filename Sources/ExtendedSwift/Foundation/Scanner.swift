//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

public struct Scanner<C: Collection> {
    
    public typealias Element = C.Element
    
    public enum ScannerError: Error {
        case isAtEnd
        case invalidElement(C.Element)
        case invalidSequence(C.SubSequence)
    }
    
    public let data: C
    public var location: C.Index {
        willSet {
            guard newValue >= data.startIndex && newValue <= data.endIndex else {
                fatalError("Setting the location to an invalid index is a programmer error")
            }
        }
    }
    public var isAtEnd: Bool { location >= data.endIndex }
    
    public init(data: C) {
        self.data = data
        self.location = data.startIndex
    }
}

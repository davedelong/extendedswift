//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/10/23.
//

import Foundation

@propertyWrapper
public class ThrowingOnce<In, Out> {
    private var hasInvoked: Bool = false
    private let file: StaticString
    private let line: UInt
    private let closure: (In) throws -> Out
    
    public var wrappedValue: (In) throws -> Out {
        return { [self] input in
            if self.hasInvoked {
                fatalError("Closure (\(In.self)) -> \(Out.self) captured at \(file):\(line) was invoked more than once")
            }
            self.hasInvoked = true
            return try self.closure(input)
        }
    }
    
    fileprivate init(closure: @escaping (In) throws -> Out, file: StaticString, line: UInt) {
        self.closure = closure
        self.file = file
        self.line = line
    }
    
    public convenience init(wrappedValue: @escaping (In) throws -> Out, file: StaticString = #fileID, line: UInt = #line) {
        self.init(closure: wrappedValue, file: file, line: line)
    }
    
    @available(*, unavailable, message: "Use @Once for non-throwing closures")
    public convenience init(wrappedValue: @escaping (In) -> Out, file: StaticString = #fileID, line: UInt = #line) {
        self.init(closure: wrappedValue, file: file, line: line)
    }
    
    deinit {
        if hasInvoked == false {
            fatalError("Closure (\(In.self)) -> \(Out.self) captured at \(file):\(line) was never invoked")
        }
    }
}

@propertyWrapper
public class Once<In, Out>: ThrowingOnce<In, Out> {
    
    public override var wrappedValue: (In) -> Out {
        let superClosure = super.wrappedValue
        
        return { try! superClosure($0) }
    }
    
    public init(wrappedValue: @escaping (In) -> Out, file: StaticString = #fileID, line: UInt = #line) {
        super.init(closure: wrappedValue, file: file, line: line)
    }
    
    @available(*, unavailable, message: "Use @ThrowingOnce for throwing closures")
    public init(wrappedValue: @escaping (In) throws -> Out, file: StaticString = #fileID, line: UInt = #line) {
        super.init(closure: wrappedValue, file: file, line: line)
    }
    
}

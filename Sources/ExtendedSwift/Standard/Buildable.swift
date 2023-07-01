//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/25/23.
//

import Foundation

public typealias BuilderBlock<T: Buildable> = (inout Builder<T>) -> Void

public protocol Buildable {
    
    init(builder: Builder<Self>)
    init()
    
}

extension Buildable {
    
    public static func builder() -> Builder<Self> { Builder() }
    public static func buildDefault() -> Self { builder().build() }
    
    public init(build: BuilderBlock<Self>) {
        var builder = Builder(building: Self.self)
        build(&builder)
        self.init(builder: builder)
    }
    
    public init() {
        self.init(builder: Self.builder())
    }
    
}

@dynamicMemberLookup
public struct Builder<Base: Buildable> {
    
    private var values = Dictionary<PartialKeyPath<Base>, Any>()
    
    public init(building type: Base.Type = Base.self) { }
    
    public func build() -> Base {
        return Base(builder: self)
    }
    
    // MARK: - Properties
    
    @_disfavoredOverload
    public subscript<V>(dynamicMember keyPath: KeyPath<Base, V>) -> V? {
        get { values[keyPath] as? V }
        set { values[keyPath] = newValue }
    }
    
    public subscript<V>(dynamicMember keyPath: KeyPath<Base, V?>) -> V? {
        get { values[keyPath] as? V }
        set { values[keyPath] = newValue }
    }
    
    // MARK: - Chaining
    
    // MARK: Properties
    
    public subscript<V>(dynamicMember keyPath: KeyPath<Base, V>) -> (V) -> Builder<Base> {
        return { newValue in
            var copy = self
            copy.values[keyPath] = newValue
            return copy
        }
    }
    
    // MARK: Buildable Properties
    
    public subscript<B: Buildable>(dynamicMember keyPath: KeyPath<Base, B>) -> (BuilderBlock<B>) -> Builder<Base> {
        return { builderBlock in
            var copy = self
            
            var inner = Builder<B>()
            builderBlock(&inner)
            copy.values[keyPath] = inner.build()
            return copy
        }
    }
    
    public subscript<B: Buildable>(dynamicMember keyPath: KeyPath<Base, B?>) -> (BuilderBlock<B>) -> Builder<Base> {
        return { builderBlock in
            var copy = self
            
            var inner = Builder<B>()
            builderBlock(&inner)
            copy.values[keyPath] = inner.build()
            return copy
        }
    }
    
    public subscript<B: Buildable>(dynamicMember keyPath: KeyPath<Base, B>) -> (Builder<B>) -> Builder<Base> {
        return { innerBuilder in
            var copy = self
            copy.values[keyPath] = innerBuilder.build()
            return copy
        }
    }
    
    public subscript<B: Buildable>(dynamicMember keyPath: KeyPath<Base, B?>) -> (Builder<B>) -> Builder<Base> {
        return { innerBuilder in
            var copy = self
            copy.values[keyPath] = innerBuilder.build()
            return copy
        }
    }
    
}

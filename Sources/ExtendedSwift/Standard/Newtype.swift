//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/4/23.
//

import Foundation

public protocol Newtype: RawRepresentable {
    init(rawValue: RawValue)
}

extension Newtype where Self: Equatable, RawValue: Equatable {
    public static func ==(left: Self, right: Self) -> Bool {
        return left.rawValue == right.rawValue
    }
}

extension Newtype where Self: Comparable, RawValue: Comparable {
    public static func <(left: Self, right: Self) -> Bool {
        return left.rawValue < right.rawValue
    }
}

extension Newtype where Self: Hashable, RawValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        self.rawValue.hash(into: &hasher)
    }
}

extension Newtype where Self: Identifiable, RawValue: Identifiable {
    public var id: RawValue.ID { rawValue.id }
}

extension Newtype where Self: Decodable, RawValue: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        self.init(rawValue: try c.decode(RawValue.self))
    }
}

extension Newtype where Self: Encodable, RawValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(self.rawValue)
    }
}

extension Newtype where Self: Error, RawValue: Error {
    public var underlyingError: RawValue { rawValue }
}

// MARK: - ExpressibleByLiteral

extension Newtype where Self: ExpressibleByNilLiteral, RawValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(rawValue: RawValue(nilLiteral: nilLiteral))
    }
}


extension Newtype where Self: ExpressibleByFloatLiteral, RawValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: RawValue.FloatLiteralType) {
        self.init(rawValue: RawValue(floatLiteral: value))
    }
}

extension Newtype where Self: ExpressibleByStringLiteral, RawValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: RawValue.StringLiteralType) {
        self.init(rawValue: RawValue(stringLiteral: value))
    }
}

extension Newtype where Self: ExpressibleByBooleanLiteral, RawValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: RawValue.BooleanLiteralType) {
        self.init(rawValue: RawValue(booleanLiteral: value))
    }
}

extension Newtype where Self: ExpressibleByIntegerLiteral, RawValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: RawValue.IntegerLiteralType) {
        self.init(rawValue: RawValue(integerLiteral: value))
    }
}

extension Newtype where Self: ExpressibleByStringInterpolation, RawValue: ExpressibleByStringInterpolation {
    public init(stringInterpolation: RawValue.StringInterpolation) {
        self.init(rawValue: RawValue(stringInterpolation: stringInterpolation))
    }
}

// can't actually do this because variadics can't be splatted
//
//extension Newtype where Self: ExpressibleByArrayLiteral, RawValue: ExpressibleByArrayLiteral {
//    public init(arrayLiteral elements: RawValue.ArrayLiteralElement...) {
//        self.init(rawValue: RawValue(arrayLiteral: elements))
//    }
//}
//
//extension Newtype where Self: ExpressibleByDictionaryLiteral, RawValue: ExpressibleByDictionaryLiteral {
//    public init(dictionaryLiteral elements: RawValue.DictionaryLiteralElement...) {
//        self.init(rawValue: RawValue(dictionaryLiteral: elements))
//    }
//}


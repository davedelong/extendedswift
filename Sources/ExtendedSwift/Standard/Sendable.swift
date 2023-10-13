//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/13/23.
//

import Foundation

// source: https://mastodon.world/@bjhomer/111227953983044879


/// A `Sendable` wrapper for things that are not sendable, but can be accessed in Sendable ways
///
/// For example, `Notification` is not sendable because its `userInfo` cannot be Sendable.
/// However, if you only care about the notification *name*, then the `Notification` can be
/// partially Sendable and can be safely wrapped in this struct.
@dynamicMemberLookup
public struct UncheckedSendable<Wrapped>: @unchecked Sendable {
    
    public let value: Wrapped
    
    public init(_ value: Wrapped) {
        self.value = value
    }
    
    public subscript<V>(dynamicMember keyPath: KeyPath<Wrapped, V>) -> V {
        return value[keyPath: keyPath]
    }
    
}

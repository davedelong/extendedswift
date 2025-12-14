//
//  File.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 12/14/25.
//

import Foundation

extension Collection where Element: Identifiable {
    
    public func firstIndex(with id: Element.ID?) -> Index? {
        guard let id else { return nil }
        return self.firstIndex(where: { $0.id == id })
    }
    
    public func first(with id: Element.ID?) -> Element? {
        guard let id else { return nil }
        return self.first(where: { $0.id == id })
    }
    
}

extension BidirectionalCollection where Element: Identifiable {
    
    public func lastIndex(with id: Element.ID?) -> Index? {
        guard let id else { return nil }
        return self.lastIndex(where: { $0.id == id })
    }
    
    public func last(with id: Element.ID?) -> Element? {
        guard let id else { return nil }
        return self.last(where: { $0.id == id })
    }
    
}

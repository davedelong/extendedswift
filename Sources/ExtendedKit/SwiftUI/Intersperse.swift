//
//  Intersperse.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/8/26.
//

import SwiftUI

public struct Intersperse<Content: View, Separator: View>: View {
    private let content: Content
    private let separator: Separator
    
    public init(@ViewBuilder content: () -> Content, @ViewBuilder separator: () -> Separator) {
        self.content = content()
        self.separator = separator()
    }
    
    public var body: some View {
        Group(subviews: content) { subviews in
            subviews.first
            ForEach(subviews.dropFirst()) { subview in
                separator
                subview
            }
        }
    }
    
}

extension Intersperse where Separator == Text {
    
    public init(_ text: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(content: content, separator: { Text(text) })
    }
    
}

extension Intersperse where Separator == Divider {
    
    public init(@ViewBuilder content: () -> Content) {
        self.init(content: content, separator: { Divider() })
    }
    
}

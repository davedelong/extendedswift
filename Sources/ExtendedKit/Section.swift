//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/7/23.
//

import SwiftUI

extension Section where Content: View, Footer: View, Parent == Text {
    
    public init(_ header: LocalizedStringKey, footer: Footer, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), footer: footer, content: content)
    }
    
}

extension Section where Content: View, Parent == Text, Footer == EmptyView {
    
    public init(_ header: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), footer: EmptyView(), content: content)
    }
    
    @_disfavoredOverload
    public init(_ header: String, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), footer: EmptyView(), content: content)
    }
    
}

extension Section where Content: View, Parent == Text, Footer == Text {
    
    public init(header: LocalizedStringKey, footer: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), footer: Text(footer), content: content)
    }
    
    @_disfavoredOverload
    public init(header: String, footer: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), footer: Text(footer), content: content)
    }
    
    @_disfavoredOverload
    public init(header: LocalizedStringKey, footer: String, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), footer: Text(footer), content: content)
    }
    
    @_disfavoredOverload
    public init(header: String, footer: String, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), footer: Text(footer), content: content)
    }
    
}


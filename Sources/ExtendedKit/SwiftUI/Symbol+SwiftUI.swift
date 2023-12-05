//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/5/23.
//

import Foundation
import SwiftUI

extension Symbol: View {
    
    public var body: some View {
        Image(symbol: self)
    }
    
}

extension Image {
    
    public init(symbol: Symbol) {
        switch symbol.sourceProvider() {
            case .systemName(let sf):
                self.init(systemName: sf)
            case .named(let name, let bundle):
                self.init(name, bundle: bundle)
            case .image(let img):
                self.init(platformImage: img)
            case .imageView(let imgView):
                self = imgView
        }
    }
    
    public init(platformImage: PlatformImage) {
        #if os(macOS)
        self.init(nsImage: platformImage)
        #else
        self.init(uiImage: platformImage)
        #endif
    }
    
}

extension Label where Title == Text, Icon == Symbol {
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol) {
        self.init(title: { Text(titleKey) }, icon: { symbol })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol) where S : StringProtocol {
        self.init(title: { Text(title) }, icon: { symbol })
    }
    
}


extension Menu where Label == SwiftUI.Label<Text, Symbol> {
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, @ViewBuilder content: () -> Content) {
        self.init(content: content, label: { Label(titleKey, symbol: symbol) })
    }

    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.init(content: content, label: { Label(title, symbol: symbol) })
    }

    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, @ViewBuilder content: () -> Content, primaryAction: @escaping () -> Void) {
        self.init(content: content, label: { Label(titleKey, symbol: symbol) }, primaryAction: primaryAction)
    }
}

#if os(macOS)
extension MenuBarExtra where Label == SwiftUI.Label<Text, Symbol> {

    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, isInserted: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.init(isInserted: isInserted, content: content, label: { Label(titleKey, symbol: symbol) })
    }

    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, isInserted: Binding<Bool>, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.init(isInserted: isInserted, content: content, label: { Label(title, symbol: symbol) })
    }

    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, @ViewBuilder content: () -> Content) {
        self.init(content: content, label: { Label(titleKey, symbol: symbol) })
    }

    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.init(content: content, label: { Label(title, symbol: symbol) })
    }
}
#endif

extension Picker where Label == SwiftUI.Label<Text, Symbol> {
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) {
        self.init(selection: selection, content: content, label: { Label(titleKey, symbol: symbol) })
    }
    
    public init<C>(_ titleKey: LocalizedStringKey, symbol: Symbol, sources: C, selection: KeyPath<C.Element, Binding<SelectionValue>>, @ViewBuilder content: () -> Content) where C : RandomAccessCollection, C.Element == Binding<SelectionValue> {
        self.init(sources: sources, selection: selection, content: content, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.init(selection: selection, content: content, label: { Label(title, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<C, S>(_ title: S, symbol: Symbol, sources: C, selection: KeyPath<C.Element, Binding<SelectionValue>>, @ViewBuilder content: () -> Content) where C : RandomAccessCollection, S : StringProtocol, C.Element == Binding<SelectionValue> {
        self.init(sources: sources, selection: selection, content: content, label: { Label(title, symbol: symbol) })
    }
}

extension Toggle where Label == SwiftUI.Label<Text, Symbol> {

    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, isOn: Binding<Bool>) {
        self.init(isOn: isOn, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, isOn: Binding<Bool>) where S : StringProtocol {
        self.init(isOn: isOn, label: { Label(title, symbol: symbol) })
    }

    public init<C>(_ titleKey: LocalizedStringKey, symbol: Symbol, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where C : RandomAccessCollection {
        self.init(sources: sources, isOn: isOn, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S, C>(_ title: S, symbol: Symbol, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where S : StringProtocol, C : RandomAccessCollection {
        self.init(sources: sources, isOn: isOn, label: { Label(title, symbol: symbol) })
    }
}

extension Button where Label == SwiftUI.Label<Text, Symbol> {
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, action: @escaping () -> Void) {
        self.init(action: action, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, action: @escaping () -> Void) where S : StringProtocol {
        self.init(action: action, label: { Label(title, symbol: symbol) })
    }
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, role: ButtonRole?, action: @escaping () -> Void) {
        self.init(role: role, action: action, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, role: ButtonRole?, action: @escaping () -> Void) where S : StringProtocol {
        self.init(role: role, action: action, label: { Label(title, symbol: symbol) })
    }
}

extension ControlGroup {
    
    public init<C>(_ titleKey: LocalizedStringKey, symbol: Symbol, @ViewBuilder content: () -> C) where Content == LabeledControlGroupContent<C, Label<Text, Symbol>>, C : View {
        self.init(content: content, label: { Label(titleKey, symbol: symbol) })
    }

    @_disfavoredOverload
    public init<C, S>(_ title: S, symbol: Symbol, @ViewBuilder content: () -> C) where Content == LabeledControlGroupContent<C, Label<Text, Symbol>>, C : View, S : StringProtocol {
        self.init(content: content, label: { Label(title, symbol: symbol) })
    }
}

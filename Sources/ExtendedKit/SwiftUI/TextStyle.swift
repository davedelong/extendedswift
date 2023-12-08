//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/7/23.
//

import SwiftUI

extension View {
    
    public func textStyle(_ style: TextStyle) -> some View {
        return modifier(TextStyleModifier(style: style))
    }
    
    public func textStyle(_ style: Font.TextStyle) -> some View {
        return modifier(TextStyleModifier(style: .init(style: style)))
    }
}

public struct TextStyle {
    
    public static var title: TextStyle { .init(style: .title) }
    public static func title(weight: Font.Weight) -> TextStyle { .init(style: .title, weight: weight) }
    
    public enum SmallCaps {
        case regular
        case lowercase
        case uppercase
    }
    
    public var custom: Font?
    public var style: Font.TextStyle?
    
    public var italic: Bool
    public var monospaceDigit: Bool
    public var weight: Font.Weight?
    public var leading: Font.Leading?
    public var width: Font.Width?
    
    public var smallCaps: SmallCaps?
    
    public var color: Color?
    
    public init(custom: Font? = nil,
                style: Font.TextStyle? = nil,
                italic: Bool = false,
                monospaceDigit: Bool = false,
                weight: Font.Weight? = nil,
                leading: Font.Leading? = nil,
                width: Font.Width? = nil,
                smallCaps: SmallCaps? = nil,
                color: Color? = nil) {
        
        self.custom = custom
        self.style = style
        self.italic = italic
        self.monospaceDigit = monospaceDigit
        self.weight = weight
        self.leading = leading
        self.width = width
        self.smallCaps = smallCaps
        self.color = color
    }
    
    fileprivate func apply(to font: Font) -> Font {
        var f = custom ?? style.map { Font.system($0, weight: weight) } ?? font
        
        switch smallCaps {
            case .regular: f = f.smallCaps()
            case .lowercase: f = f.lowercaseSmallCaps()
            case .uppercase: f = f.uppercaseSmallCaps()
            default: break
        }
        
        if let weight { f = f.weight(weight) }
        if let width { f = f.width(width) }
        if italic { f = f.italic() }
        if monospaceDigit { f = f.monospacedDigit() }
        
        return f
    }
}

private struct TextStyleModifier: ViewModifier {
    @Environment(\.font) var font
    let style: TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(style.apply(to: font ?? .body))
            .foregroundColor(style.color)
    }
    
}

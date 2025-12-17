//
//  LabeledContentStyle.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 12/16/25.
//

import SwiftUI

extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
    
    public static var vertical: Self { VerticalLabeledContentStyle() }
    
    public static func vertical(alignment: HorizontalAlignment) -> Self { VerticalLabeledContentStyle(alignment: alignment) }
    
    public static func vertical(spacing: CGFloat) -> Self { VerticalLabeledContentStyle(spacing: spacing) }
    
    public static func vertical(alignment: HorizontalAlignment, spacing: CGFloat) -> Self { VerticalLabeledContentStyle(alignment: alignment, spacing: spacing) }
    
}

public struct VerticalLabeledContentStyle: LabeledContentStyle {
    
    private let alignment: HorizontalAlignment?
    private let spacing: CGFloat?
    
    public init(alignment: HorizontalAlignment? = nil, spacing: CGFloat? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: alignment ?? .center, spacing: spacing) {
            configuration.label
            configuration.content
        }
    }
    
}

extension LabeledContentStyle where Self == HorizontalLabeledContentStyle {
    
    public static var horizontal: Self { HorizontalLabeledContentStyle() }
    
    public static func horizontal(alignment: VerticalAlignment) -> Self { HorizontalLabeledContentStyle(alignment: alignment) }
    
    public static func horizontal(spacing: CGFloat) -> Self { HorizontalLabeledContentStyle(spacing: spacing) }
    
    public static func horizontal(alignment: VerticalAlignment, spacing: CGFloat) -> Self { HorizontalLabeledContentStyle(alignment: alignment, spacing: spacing) }
    
}

public struct HorizontalLabeledContentStyle: LabeledContentStyle {
    
    private let alignment: VerticalAlignment?
    private let spacing: CGFloat?
    
    public init(alignment: VerticalAlignment? = nil, spacing: CGFloat? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: alignment ?? .center, spacing: spacing) {
            configuration.label
            configuration.content
        }
    }
    
}

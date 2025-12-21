//
//  LabeledContentStyle.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 12/16/25.
//

import SwiftUI

extension LabeledContentStyle where Self == StackLabeledContentStyle {
    
    public static var stack: Self { StackLabeledContentStyle(axis: nil) }
    
    public static var vertical: Self { StackLabeledContentStyle(axis: .vertical) }
    
    public static func vertical(alignment: HorizontalAlignment) -> Self {
        StackLabeledContentStyle(axis: .vertical, alignment: Alignment(horizontal: alignment, vertical: .center))
    }
    
    public static func vertical(spacing: CGFloat) -> Self {
        StackLabeledContentStyle(axis: .vertical, spacing: spacing)
    }
    
    public static func vertical(alignment: HorizontalAlignment, spacing: CGFloat) -> Self {
        StackLabeledContentStyle(axis: .vertical, alignment: Alignment(horizontal: alignment, vertical: .center), spacing: spacing)
    }
    
    public static var horizontal: Self { StackLabeledContentStyle(axis: .horizontal) }
    
    public static func horizontal(alignment: VerticalAlignment) -> Self {
        StackLabeledContentStyle(axis: .horizontal, alignment: Alignment(horizontal: .center, vertical: alignment))
    }
    
    public static func horizontal(spacing: CGFloat) -> Self {
        StackLabeledContentStyle(axis: .horizontal, spacing: spacing)
    }
    
    public static func horizontal(alignment: VerticalAlignment, spacing: CGFloat) -> Self {
        StackLabeledContentStyle(axis: .horizontal, alignment: Alignment(horizontal: .center, vertical: alignment), spacing: spacing)
    }
    
}

public struct StackLabeledContentStyle: LabeledContentStyle {
    
    internal var axis: Axis?
    internal var alignment: Alignment? = nil
    internal var spacing: CGFloat? = nil
    
    public func makeBody(configuration: Configuration) -> some View {
        switch axis {
            case .none:
                configuration.label
                configuration.content
                
            case .horizontal:
                HStack(alignment: alignment?.vertical ?? .center, spacing: spacing) {
                    configuration.label
                    configuration.content
                }
                
            case .vertical:
                VStack(alignment: alignment?.horizontal ?? .center, spacing: spacing) {
                    configuration.label
                    configuration.content
                }
        }
    }
    
}

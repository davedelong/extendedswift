//
//  LabelStyle.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/15/26.
//

import SwiftUI

extension LabelStyle where Self == StackLabelStyle {
    
    public static var stack: Self { StackLabelStyle(axis: nil) }
    
    public static var vertical: Self { StackLabelStyle(axis: .vertical) }
    
    public static func vertical(alignment: HorizontalAlignment) -> Self {
        StackLabelStyle(axis: .vertical, alignment: Alignment(horizontal: alignment, vertical: .center))
    }
    
    public static func vertical(spacing: CGFloat) -> Self {
        StackLabelStyle(axis: .vertical, spacing: spacing)
    }
    
    public static func vertical(alignment: HorizontalAlignment, spacing: CGFloat) -> Self {
        StackLabelStyle(axis: .vertical, alignment: Alignment(horizontal: alignment, vertical: .center), spacing: spacing)
    }
    
    public static var horizontal: Self { StackLabelStyle(axis: .horizontal) }
    
    public static func horizontal(alignment: VerticalAlignment) -> Self {
        StackLabelStyle(axis: .horizontal, alignment: Alignment(horizontal: .center, vertical: alignment))
    }
    
    public static func horizontal(spacing: CGFloat) -> Self {
        StackLabelStyle(axis: .horizontal, spacing: spacing)
    }
    
    public static func horizontal(alignment: VerticalAlignment, spacing: CGFloat) -> Self {
        StackLabelStyle(axis: .horizontal, alignment: Alignment(horizontal: .center, vertical: alignment), spacing: spacing)
    }
    
}

public struct StackLabelStyle: LabelStyle {
    
    internal var axis: Axis?
    internal var alignment: Alignment? = nil
    internal var spacing: CGFloat? = nil
    
    public func makeBody(configuration: Configuration) -> some View {
        switch axis {
            case .none:
                configuration.icon
                configuration.title
                
            case .horizontal:
                HStack(alignment: alignment?.vertical ?? .center, spacing: spacing) {
                    configuration.icon
                    configuration.title
                }
                
            case .vertical:
                VStack(alignment: alignment?.horizontal ?? .center, spacing: spacing) {
                    configuration.icon
                    configuration.title
                }
        }
    }
    
}



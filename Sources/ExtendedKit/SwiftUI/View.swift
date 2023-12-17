//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/7/23.
//

import SwiftUI

extension View {
    
    public func enabled(_ isEnabled: Bool) -> some View {
        disabled(!isEnabled)
    }
    
    public func frame(_ rect: CGRect) -> some View {
        self.frame(width: rect.size.width, height: rect.height)
            .position(rect.center)
    }
    
    public func frame(size: CGSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }
    
    public func frame(size: CGSize, alignment: Alignment) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
    
    public func alignment(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    public func whenAligned(to verticalAlignment: VerticalAlignment, use guide: VerticalAlignment, offset: CGFloat = 0) -> some View {
        self.alignmentGuide(verticalAlignment, computeValue: { $0[guide] + offset })
    }
    
    public func whenAligned(to horizontalAlignment: HorizontalAlignment, use guide: HorizontalAlignment, offset: CGFloat = 0) -> some View {
        self.alignmentGuide(horizontalAlignment, computeValue: { $0[guide] + offset })
    }
    
    public func whenAligned(to alignment: Alignment, use guide: Alignment, offset: CGSize = .zero) -> some View {
        self.alignmentGuide(alignment.horizontal, computeValue: { $0[guide.horizontal] + offset.width })
            .alignmentGuide(alignment.vertical, computeValue: { $0[guide.vertical] + offset.height })
    }
}


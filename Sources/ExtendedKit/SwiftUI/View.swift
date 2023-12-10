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
        self.frame(alignment: alignment)
    }
}


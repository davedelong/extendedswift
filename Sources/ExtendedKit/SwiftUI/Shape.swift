//
//  Shape.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 12/20/25.
//

import SwiftUI

extension Shape where Self == Square {
    
    public static var square: Self { Square() }
    
}

public struct Square: Shape {
    
    public nonisolated func path(in rect: CGRect) -> SwiftUI.Path {
        let dimension = min(rect.width, rect.height)
        
        let square = CGRect(center: rect.center, square: dimension)
        return .init(roundedRect: square, cornerRadius: 0)
    }
    
}

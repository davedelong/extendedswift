//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation
import CoreGraphics

extension CGFloat {
    
    public static let tau: CGFloat = 2 * CGFloat.pi
    
}


extension CGPoint {
    
    public init(polarAngle: CGFloat, length: CGFloat) {
        self.init(x: cos(polarAngle) * length,
                  y: sin(polarAngle) * -length)
    }
    
}

extension CGRect {
    
    public var center: CGPoint {
        get {
            return CGPoint(x: midX, y: midY)
        }
        set {
            self = .init(center: newValue, size: size)
        }
    }
    
    public var area: CGFloat {
        if self.isEmpty { return 0 }
        if self.isNull { return 0 }
        if self.isInfinite { return CGFloat.greatestFiniteMagnitude }
        
        return abs(self.width * self.height)
    }
    
    public init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width / 2,
                             y: center.y - size.height / 2)
        
        self.init(origin: origin, size: size)
    }
    
    public init(center: CGPoint, square: CGFloat) {
        self.init(center: center, size: CGSize(width: square, height: square))
    }
    
    public init(origin: CGPoint, square: CGFloat) {
        self.init(origin: origin, size: CGSize(width: square, height: square))
    }
    
}

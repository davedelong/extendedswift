//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension CGPoint {
    
    public init(polarAngle: CGFloat, length: CGFloat) {
        self.init(x: cos(polarAngle) * length,
                  y: sin(polarAngle) * -length)
    }
    
}

extension CGFloat {
    
    public static let tau: CGFloat = 2 * CGFloat.pi
    
}

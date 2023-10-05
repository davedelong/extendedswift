//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/13/23.
//

import Foundation
import SwiftUI

extension SwiftUI.Path {
    
    // return point at the curve
    public func point(at offset: Normalized) -> CGPoint {
        return trimmedPath(from: 0, to: offset.rawValue).cgPath.currentPoint
    }
    
}

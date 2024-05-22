//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/22/24.
//

import SwiftUI

extension CGRect {
    
    public subscript(_ unitPoint: UnitPoint) -> CGRect {
        // via https://mas.to/@kayleesdevlog/112475071330602405
        return CGRect(x: minX + unitPoint.x * width,
                      y: minY + unitPoint.y * height,
                      width: width,
                      height: height)
    }
    
}

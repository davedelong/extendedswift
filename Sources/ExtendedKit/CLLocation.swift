//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/14/23.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        guard lhs.isValid == rhs.isValid else { return false }
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public var isValid: Bool { CLLocationCoordinate2DIsValid(self) }
    
}

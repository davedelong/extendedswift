//
//  UserLocation.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/11/26.
//

import SwiftUI
import MapKit
import UIKit

public struct UserLocation: MapItem, _MapItem {
    public init() { }
    
    internal let stableID: AnyHashable? = "USER_LOCATION"
    internal let annotation: (any MKAnnotation)? = MKUserLocation()
}

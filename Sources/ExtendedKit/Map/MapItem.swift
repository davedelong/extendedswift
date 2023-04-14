//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/14/23.
//

import Foundation
import MapKit

public protocol MapItem: Identifiable {
    var coordinate: CLLocationCoordinate2D { get }
    var cluster: (any MapCluster.Type) { get }
    var title: String? { get }
    var subtitle: String? { get }
}

extension MapItem {
    public var cluster: any MapCluster.Type { Never.self }
    public var title: String? { nil }
    public var subtitle: String? { nil }
    
    internal var resolvedCluster: (any MapCluster.Type)? {
        if cluster.isValid { return cluster }
        return nil
    }
}

public struct BasicMapItem: MapItem {
    public let mapItem: MKMapItem
    public var id: ObjectIdentifier { ObjectIdentifier(mapItem) }
    public var coordinate: CLLocationCoordinate2D { mapItem.placemark.coordinate }
    public var title: String? { mapItem.name ?? mapItem.placemark.title }
    public var subtitle: String? { mapItem.placemark.subtitle }
    
    public init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
}

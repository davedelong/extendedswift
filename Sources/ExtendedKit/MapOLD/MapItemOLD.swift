//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/14/23.
//

import Foundation
import MapKit

public protocol MapItemOLD: Identifiable {
    var coordinate: CLLocationCoordinate2D { get }
    var cluster: (any MapClusterOLD.Type) { get }
    var title: String? { get }
    var subtitle: String? { get }
}

extension MapItemOLD {
    public var cluster: any MapClusterOLD.Type { Never.self }
    public var title: String? { nil }
    public var subtitle: String? { nil }
    
    internal var resolvedCluster: (any MapClusterOLD.Type)? {
        if cluster.isValid { return cluster }
        return nil
    }
}

public struct BasicMapItemOLD: MapItemOLD {
    public let mapItem: MKMapItem
    public var id: ObjectIdentifier { ObjectIdentifier(mapItem) }
    public var coordinate: CLLocationCoordinate2D { mapItem.placemark.coordinate }
    public var title: String? { mapItem.name ?? mapItem.placemark.title }
    public var subtitle: String? { mapItem.placemark.subtitle }
    
    public init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
}

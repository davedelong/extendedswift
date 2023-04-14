//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/14/23.
//

import Foundation
import MapKit

public protocol MapCluster {
    associatedtype Marker: MKAnnotationView
    associatedtype Item: MapItem
    
    static func configure(view: Marker, members: Array<Item>)
    
}

extension Never: MapCluster {
    public typealias Marker = MKAnnotationView
    public typealias Item = BasicMapItem
    
    public static func configure(view: MKAnnotationView, members: Array<BasicMapItem>) {
        fatalError("Unreachable")
    }
}

extension MapCluster {
    
    internal static var isValid: Bool {
        return self != Never.self
    }
    
    internal static var markerView: Marker.Type { Marker.self }
    
    internal static var clusteringIdentifier: String? {
        guard isValid else { return nil }
        return String(describing: self)
    }
    
    internal static func configure(annotations: Array<MKAnnotation>, for marker: MKAnnotationView) {
        guard let typedMarker = marker as? Marker else { return }
        
        let mapAnnotations = annotations.filter(is: _MapAnnotation<Item>.self)
        let items = mapAnnotations.map(\.item)
        if items.isEmpty { return }
        
        self.configure(view: typedMarker, members: items)
    }
}

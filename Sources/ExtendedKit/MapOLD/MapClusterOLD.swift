//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/14/23.
//

import Foundation
import MapKit

public protocol MapClusterOLD {
    associatedtype Marker: MKAnnotationView
    associatedtype Item: MapItemOLD
    
    static func configure(view: Marker, members: Array<Item>)
    
}

extension Never: MapClusterOLD {
    public typealias Marker = MKAnnotationView
    public typealias Item = BasicMapItemOLD
    
    public static func configure(view: MKAnnotationView, members: Array<BasicMapItemOLD>) {
        fatalError("Unreachable")
    }
}

extension MapClusterOLD {
    
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
        
        let mapAnnotations = annotations.filter(is: _MapAnnotationOLD<Item>.self)
        let items = mapAnnotations.map(\.item)
        if items.isEmpty { return }
        
        self.configure(view: typedMarker, members: items)
    }
}

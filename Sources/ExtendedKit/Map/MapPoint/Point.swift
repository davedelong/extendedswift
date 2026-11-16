//
//  Point.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/11/26.
//

import SwiftUI
import MapKit

//public protocol MapPoint: MapItem { }

public struct Point<Content: View>: MapItem, _MapItem {
    
    internal private(set) var stableID: AnyHashable?
    internal let content: PointContent<Content>
    internal let annotation: MKAnnotation?
    internal let selection: (@MainActor () -> Void)?
    
    // MARK: - _Point
    
    internal var viewClass: MKAnnotationView.Type? {
        return switch content {
            case .custom: MapPointView<Content>.self
            case .marker: DefaultMarkerAnnotationView.self
        }
    }
    
    // MARK: - Initializers
    
    internal init(id: AnyHashable?, annotation: MKAnnotation, content: PointContent<Content>, selection: (@MainActor () -> Void)?) {
        self.stableID = id
        self.annotation = annotation
        self.content = content
        self.selection = selection
    }
    
    @MainActor func populateView(_ view: MKAnnotationView) {
        switch content {
            case .custom(let c):
                let v = view as! MapPointView<Content>
                #warning("TODO: populate the hosted view")
                
            case .marker(let m):
                let marker = view as! MKMarkerAnnotationView
                let markerContent = m.content
                marker.markerTintColor = markerContent.tint
                marker.glyphText = markerContent.glyphText
                marker.glyphImage = markerContent.glyphImage
                marker.glyphTintColor = markerContent.glyphTint
                marker.selectedGlyphImage = markerContent.selectedGlyphImage
                if let v = markerContent.titleVisibility { marker.titleVisibility = v.featureVisibility }
                if let v = markerContent.subtitleVisibility { marker.subtitleVisibility = v.featureVisibility }
        }
    }
    
    // MARK: - Modifiers
    
    public func id(_ value: AnyHashable) -> some MapItem {
        var copy = self
        copy.stableID = value
        return copy
    }
}

internal class DefaultMarkerAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setDefaults()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setDefaults()
    }
    override func prepareForReuse() {
        setDefaults()
    }
    
    private func setDefaults() {
        self.displayPriority = .required
        self.zPriority = .max
        self.collisionMode = .none
        self.clusteringIdentifier = nil
    }
    
}

internal enum PointContent<Content: View> {
    case custom(Content)
    case marker(any _MapMarkerContent)
}

internal struct MarkerContent {
    var title: String?
    var subtitle: String?
    var tint: PlatformColor?
    var glyphText: String?
    var glyphImage: PlatformImage?
    var glyphTint: PlatformColor?
    var selectedGlyphImage: PlatformImage?
    
    var titleVisibility: Visibility?
    var subtitleVisibility: Visibility?
}

extension Point where Content == EmptyView {
    
    public init(annotation: MKPointAnnotation, action: (@MainActor () -> Void)? = nil, @ContentBuilder marker: () -> some MapMarkerContent) {
        let m = marker() as! _MapMarkerContent
        self.init(
            id: annotation,
            annotation: annotation,
            content: .marker(m),
            selection: action
        )
    }
    
    public init(coordinate: CLLocationCoordinate2D, action: (@MainActor () -> Void)? = nil, @ContentBuilder marker: () -> some MapMarkerContent) {
        let m = marker() as! _MapMarkerContent
        self.init(
            id: nil,
            annotation: MKPointAnnotation(coordinate: coordinate),
            content: .marker(m),
            selection: action
        )
    }
    
    public init(location: CLLocation, action: (@MainActor () -> Void)? = nil, @ContentBuilder marker: () -> some MapMarkerContent) {
        let m = marker() as! _MapMarkerContent
        self.init(
            id: location,
            annotation: MKPointAnnotation(coordinate: location.coordinate),
            content: .marker(m),
            selection: action
        )
    }
    
    public init(mapItem: MKMapItem, action: (@MainActor () -> Void)? = nil, @ContentBuilder marker: () -> some MapMarkerContent) {
        let m = marker() as! _MapMarkerContent
        self.init(
            id: mapItem,
            annotation: MKMapItemAnnotation(mapItem: mapItem) ?? MKPointAnnotation(coordinate: mapItem.location.coordinate),
            content: .marker(m),
            selection: action
        )
    }
    
}

extension Point {
    
    public init(annotation: MKPointAnnotation, action: (@MainActor () -> Void)? = nil, @ContentBuilder content: () -> Content) {
        self.init(
            id: annotation,
            annotation: annotation,
            content: .custom(content()),
            selection: action
        )
    }
    
    public init(coordinate: CLLocationCoordinate2D, action: (@MainActor () -> Void)? = nil, @ContentBuilder content: () -> Content) {
        self.init(
            id: nil,
            annotation: MKPointAnnotation(coordinate: coordinate),
            content: .custom(content()),
            selection: action
        )
    }
    
    public init(location: CLLocation, action: (@MainActor () -> Void)? = nil, @ContentBuilder content: () -> Content) {
        self.init(
            id: location,
            annotation: MKPointAnnotation(coordinate: location.coordinate),
            content: .custom(content()),
            selection: action
        )
    }
    
    public init(mapItem: MKMapItem, action: (@MainActor () -> Void)? = nil, @ContentBuilder content: () -> Content) {
        self.init(
            id: mapItem.identifier ?? mapItem,
            annotation: MKMapItemAnnotation(mapItem: mapItem) ?? MKPointAnnotation(coordinate: mapItem.location.coordinate),
            content: .custom(content()),
            selection: action
        )
    }
    
}

internal class MapPointView<Content: View>: MKAnnotationView {
    
    private var host: UIHostingController<Content>!
    
    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension Visibility {
    
    internal var featureVisibility: MKFeatureVisibility {
        switch self {
            case .automatic: return .adaptive
            case .hidden: return .hidden
            case .visible: return .visible
            @unknown default: return .adaptive
        }
    }
    
}

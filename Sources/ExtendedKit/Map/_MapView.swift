//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/14/23.
//

import Foundation
import SwiftUI
import MapKit

internal struct _MapView<Data, Label: MKAnnotationView>: PlatformViewRepresentable where Data: RandomAccessCollection, Data.Element: MapItem {
    typealias Coordinator = _MapCoordinator<Data, Label>
        
    let annotations: Data
    let interactable: Bool
    let showsUserLocation: Bool
    let visibleRegion: Binding<MKCoordinateRegion?>
    let action: (Data.Element) -> Void
    let label: (Data.Element, Label) -> Void
    
    func makeCoordinator() -> Coordinator {
        _MapCoordinator(region: visibleRegion, action: action, label: label)
    }
    
    #if os(macOS)
    func makeNSView(context: Context) -> MKMapView { return context.coordinator.map }
    func updateNSView(_ nsView: MKMapView, context: Context) { context.coordinator.updateMap(from: self) }
    #else
    func makeUIView(context: Self.Context) -> MKMapView { return context.coordinator.map }
    func updateUIView(_ uiView: MKMapView, context: Context) { context.coordinator.updateMap(from: self) }
    #endif
}


internal class _MapCoordinator<Data, Label: MKAnnotationView>: NSObject, MKMapViewDelegate where Data: RandomAccessCollection, Data.Element: MapItem {
    let region: Binding<MKCoordinateRegion?>
    let action: (Data.Element) -> Void
    let label: (Data.Element, Label) -> Void
    var isUpdatingRegion = false
    
    private var registeredClusters = Set<String>()
    
    private var itemMap = Dictionary<Data.Element.ID, _MapAnnotation<Data.Element>>()
    
    private(set) lazy var map: MKMapView = {
        let map = MKMapView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        // do this before setting the delegate
        if let r = region.wrappedValue { map.setRegion(r, animated: false) }
        
        map.delegate = self
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        map.register(Label.self, forAnnotationViewWithReuseIdentifier: "\(Data.Element.self)")
        return map
    }()
    
    internal init(region: Binding<MKCoordinateRegion?>, action: @escaping (Data.Element) -> Void, label: @escaping (Data.Element, Label) -> Void) {
        self.region = region.debounce(0.3)
        self.action = action
        self.label = label
        super.init()
    }
    
    func updateMap(from container: _MapView<Data, Label>) {
        map.isZoomEnabled = container.interactable
        map.isScrollEnabled = container.interactable
        map.isPitchEnabled = false
        map.isRotateEnabled = false
        #if !os(macOS)
        map.isUserInteractionEnabled = container.interactable
        #endif
        
        self.updateAnnotations(container.annotations)
        
        map.showsUserLocation = container.showsUserLocation
        
        if let r = region.wrappedValue {
            if r != map.region {
                self.isUpdatingRegion = true
                map.setRegion(r, animated: false)
                self.isUpdatingRegion = false
            }
        } else {
            self.isUpdatingRegion = true
            map.showAnnotations(map.annotations, animated: false)
            self.isUpdatingRegion = false
        }
    }
    
    func updateAnnotations(_ newAnnotations: Data) {
        var previous = itemMap
        var new = Dictionary<Data.Element.ID, _MapAnnotation<Data.Element>>()
        
        var added = Array<MKAnnotation>()
        for item in newAnnotations {
            if let id = item.cluster.clusteringIdentifier, registeredClusters.contains(id) == false {
                map.register(item.cluster.markerView, forAnnotationViewWithReuseIdentifier: id)
            }
            
            if let e = previous[item.id] {
                new[item.id] = e
                previous[item.id] = nil
            } else {
                let annotation = _MapAnnotation(item: item)
                new[item.id] = annotation
                added.append(annotation)
            }
        }
        
        itemMap = new
        let deleted = Array(previous.values)
        
        if deleted.count > 0 { map.removeAnnotations(deleted) }
        if added.count > 0 { map.addAnnotations(added) }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        if let mapAnnotation = annotation as? _MapAnnotation<Data.Element> {
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "\(Data.Element.self)", for: annotation) as! Label
            label(mapAnnotation.item, view)
            view.clusteringIdentifier = mapAnnotation.item.cluster.clusteringIdentifier
            return view
        }
        
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            let cluster = clusterAnnotation.memberAnnotations.firstMap {
                ($0 as? _MapAnnotation<Data.Element>)?.item.resolvedCluster
            }
            
            if let cluster, let id = cluster.clusteringIdentifier {
                let marker = mapView.dequeueReusableAnnotationView(withIdentifier: id, for: clusterAnnotation)
                cluster.configure(annotations: clusterAnnotation.memberAnnotations, for: marker)
                return marker
            }
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        if let mapAnnotation = annotation as? _MapAnnotation<Data.Element> {
            if view.canShowCallout == false {
                action(mapAnnotation.item)
            }
            
        } else if let cluster = annotation as? MKClusterAnnotation {
            var region = mapView.region
            region.center = cluster.coordinate
            region.span.latitudeDelta /= 2
            region.span.longitudeDelta /= 2
            
            #if os(macOS)
            mapView.setRegion(region, animated: true)
            #else
            UIView.animate(withDuration: 0.3) {
                mapView.setRegion(region, animated: true)
            }
            #endif
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    #if !os(macOS)
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let mapAnnotation = view.annotation as? _MapAnnotation<Data.Element> {
            action(mapAnnotation.item)
        }
    }
    #endif
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        guard isUpdatingRegion == false else { return }
        
        if let r = region.wrappedValue, r != mapView.region {
            region.wrappedValue = mapView.region
        }
    }
}

internal class _MapAnnotation<Item: MapItem>: NSObject, MKAnnotation {
    let item: Item
    var id: Item.ID { item.id }
    var coordinate: CLLocationCoordinate2D { item.coordinate }
    var cluster: any MapCluster.Type { Never.self }
    var title: String? { item.title }
    var subtitle: String? { item.subtitle }
    
    init(item: Item) {
        self.item = item
    }
}

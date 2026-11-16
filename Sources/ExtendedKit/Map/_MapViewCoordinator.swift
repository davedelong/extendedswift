//
//  _MapViewCoordinator.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/12/26.
//

import SwiftUI
import MapKit
import UIKit

internal class _MapViewCoordinator<Content: _MapItem>: NSObject, MKMapViewDelegate {
    
    private lazy var map: MKMapView = {
        let map = MKMapView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        // do this before setting the delegate
//        if let r = region.wrappedValue { map.setRegion(r, animated: false) }
        
        map.delegate = self
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        return map
    }()
    
    private var displayedAnnotations = Set<_MapAnnotation>()
    private var config = _MapConfiguration(interactionEnabled: true)
    
    func make(config: _MapConfiguration) -> MKMapView {
        self.config = config
        if let r = config.region {
            map.setRegion(r.wrappedValue, animated: false)
        }
        return map
    }
    
    func update(content: Content, config: _MapConfiguration) {
        let newRegion = config.region?.wrappedValue ?? map.region
        self.config = config
        var all = Set<_MapAnnotation>()
        
        content._visit(using: { item in
            guard let a = item.annotation else {
                print("\(item) does not have an annotation")
                return
            }
            let id: _MapAnnotation.ID
            if let stable = item.stableID {
                id = .stable(stable)
            } else {
                id = .positional(all.count)
            }
            if let c = item.viewClass, let r = item.viewReuseIdentifier {
                map.register(c, forAnnotationViewWithReuseIdentifier: r)
            }
            all.insert(_MapAnnotation(id: id, annotation: a, item: item))
        })
        
        let inserted = all.subtracting(displayedAnnotations)
        let removed = displayedAnnotations.subtracting(all)
        
        // NOTE: this directly manipulates the set instead of replacing it
        // the items retrieved from the content may have different annotation instances,
        // even if they were the "same" as the last time the content was built
        // by only inserting the new things, we make sure that the annotation instances on the map
        // are the same as the instances held by the set
        displayedAnnotations.subtract(removed)
        displayedAnnotations.formUnion(inserted)
        
        if removed.isNotEmpty { map.removeAnnotations(removed.map(\.annotation)) }
        if inserted.isNotEmpty { map.addAnnotations(inserted.map(\.annotation)) }
        if newRegion != map.region { map.setRegion(newRegion, animated: false) }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        guard let m = displayedAnnotations.first(where: { $0.annotation === annotation }) else { return nil }
        guard let r = m.item.viewReuseIdentifier else { return nil }
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: r, for: annotation)
        m.item.populateView(view)
        view.isEnabled = m.item.isSelectable
        return view
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [any MKAnnotation]) -> MKClusterAnnotation {
        fatalError()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        fatalError()
    }
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        print(#function, view, view.annotation)
//    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        config.region?.wrappedValue = mapView.region
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
        print(#function, annotation)
        guard let m = displayedAnnotations.first(where: { $0.annotation === annotation }) else { return }
        m.item.selection?()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect annotation: any MKAnnotation) {
        
    }
}


private struct _MapAnnotation: Identifiable, Hashable {
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
//        guard lhs.id == rhs.id else { return false }
//        return lhs.annotation === rhs.annotation
    }
    
    enum ID: Hashable {
        case positional(Int)
        case stable(AnyHashable)
    }
    
    let id: ID
    let annotation: MKAnnotation
    var item: any _MapItem
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

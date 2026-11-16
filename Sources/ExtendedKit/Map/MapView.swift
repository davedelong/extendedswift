//
//  SwiftUIView.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/10/26.
//

import SwiftUI
import MapKit
import UIKit

@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
public struct MapView<Content: MapItem>: View {
    
    private let content: Content
    
    private let tracksRegion: Bool
    @Binding private var region: MKCoordinateRegion
    
    public init(@ContentBuilder content: () -> Content) {
        self.content = content()
        self._region = .constant(.init())
        self.tracksRegion = false
    }
    
    public init(region: Binding<MKCoordinateRegion>, @ContentBuilder content: () -> Content) {
        self.content = content()
        self._region = region
        self.tracksRegion = true
    }
    
    public var body: some View {
        if let typedContent = content as? any _MapItem {
            unbox(typedContent)
        } else {
            Label("Unknown content type \(Content.self)" as String, systemImage: "questionmark")
        }
    }
    
    private func unbox<T: _MapItem>(_ content: T) -> AnyView {
        AnyView(_MapViewContent(content: content, region: tracksRegion ? _region : nil))
    }
}


private struct _MapViewContent<Content: _MapItem>: PlatformViewRepresentable {
    typealias UIViewType = MKMapView
    @Environment(\.isEnabled) var interactionEnabled
    
    var content: Content
    var region: Binding<MKCoordinateRegion>?
    
    var config: _MapConfiguration {
        .init(region: region, interactionEnabled: interactionEnabled)
    }
    
    func makeCoordinator() -> _MapViewCoordinator<Content> {
        _MapViewCoordinator()
    }
    func makePlatformView(context: Context) -> MKMapView {
        context.coordinator.make(config: config)
    }
    func updatePlatformView(_ view: MKMapView, context: Context) {
        context.coordinator.update(content: content, config: config)
    }
}

internal struct _MapConfiguration {
    var region: Binding<MKCoordinateRegion>?
    var interactionEnabled: Bool
}

@available(iOS 27.0, macOS 27.0, watchOS 27.0, tvOS 27.0, visionOS 27.0, *)
#Preview {
    MapView {
        UserLocation()
        Point(coordinate: CLLocationCoordinate2D(latitude: 40.40568, longitude: -111.93768)) {
            MapMarker()
                .glyph("DD")
                .tint(.yellow)
        }
    }
}

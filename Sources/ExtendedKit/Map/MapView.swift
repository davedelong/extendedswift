//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/14/23.
//

import Foundation
import SwiftUI
import MapKit

public struct MapView<Data, Label: MKAnnotationView>: View where Data: RandomAccessCollection, Data.Element: MapItem {
    
    private let data: Data
    private let interactable: Bool
    private let showsUserLocation: Bool
    private let visibleRegion: Binding<MKCoordinateRegion?>
    private let action: (Data.Element) -> Void
    private let label: (Data.Element, Label) -> Void
    
    public init(items: Data,
                interactable: Bool = true,
                showsUserLocation: Bool = false,
                visibleRegion: Binding<MKCoordinateRegion?>,
                action: @escaping (Data.Element) -> Void,
                label: @escaping (Data.Element, Label) -> Void) {
        
        self.data = items
        self.interactable = interactable
        self.showsUserLocation = showsUserLocation
        self.visibleRegion = visibleRegion
        self.action = action
        self.label = label
    }
    
    public init(items: Data,
                interactable: Bool = true,
                showsUserLocation: Bool = false,
                visibleRegion: Binding<MKCoordinateRegion>,
                action: @escaping (Data.Element) -> Void,
                label: @escaping (Data.Element, Label) -> Void) {
        
        let region: Binding<MKCoordinateRegion?> = Binding(get: { visibleRegion.wrappedValue },
                                                           set: {
                                                            if let v = $0 { visibleRegion.wrappedValue = v }
                                                           })
        self.init(items: items,
                  interactable: interactable,
                  showsUserLocation: showsUserLocation,
                  visibleRegion: region,
                  action: action,
                  label: label)
    }
    
    public init(items: Data,
                interactable: Bool = true,
                showsUserLocation: Bool = false,
                visibleRegion: Binding<MKCoordinateRegion?>,
                selection: Binding<Data.Element?>,
                label: @escaping (Data.Element, Label) -> Void) {
    
        self.init(items: items,
                  interactable: interactable,
                  showsUserLocation: showsUserLocation,
                  visibleRegion: visibleRegion,
                  action: { selection.wrappedValue = $0 },
                  label: label)
    }
    
    public init(items: Data,
                interactable: Bool = true,
                showsUserLocation: Bool = false,
                visibleRegion: Binding<MKCoordinateRegion>,
                selection: Binding<Data.Element?>,
                label: @escaping (Data.Element, Label) -> Void) {
        
        let region: Binding<MKCoordinateRegion?> = Binding(get: { visibleRegion.wrappedValue },
                                                           set: {
                                                            if let v = $0 { visibleRegion.wrappedValue = v }
                                                           })
    
        self.init(items: items,
                  interactable: interactable,
                  showsUserLocation: showsUserLocation,
                  visibleRegion: region,
                  action: { selection.wrappedValue = $0 },
                  label: label)
    }
    
    public var body: some View {
        _MapView(annotations: data,
                 interactable: interactable,
                 showsUserLocation: showsUserLocation,
                 visibleRegion: visibleRegion,
                 action: action,
                 label: label)
    }
}

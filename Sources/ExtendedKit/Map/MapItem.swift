//
//  MapItem.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/11/26.
//

import SwiftUI
import MapKit

public protocol MapItem { }

// MARK: - ContentBuilder support
extension ContentBuilder {
    public static func buildBlock<each Content>(_ content: repeat each Content) -> TupleContent<repeat each Content> {
        TupleContent(repeat each content)
    }
}

extension EmptyView: MapItem { }
extension Optional: MapItem where Wrapped: MapItem { }
extension _ConditionalContent: MapItem where TrueContent: MapItem, FalseContent: MapItem { }
extension TupleView: MapItem where T: MapItem { }
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 2.0, *)
extension TupleContent: MapItem where repeat each Content: MapItem { }
extension ForEach: MapItem where Content: MapItem { }

// MARK: Internal Implementations

internal protocol _MapItem {
    var stableID: AnyHashable? { get }
    
    // leaf item properties
    nonisolated var annotation: (any MKAnnotation)? { get }
    var viewClass: MKAnnotationView.Type? { get }
    @MainActor func populateView(_ view: MKAnnotationView)
    
    var selection: (@MainActor () -> Void)? { get }
    
    
    // only implement this for non-leaf MapItems, like ForEach, TupleContent, etc
    nonisolated func _visit(using visitor: (any _MapItem) -> Void)
}

extension _MapItem {
    var stableID: AnyHashable? { nil }
    var viewClass: MKAnnotationView.Type? { nil }
    var viewReuseIdentifier: String? {
        guard let v = self.viewClass else { return nil }
        return "\(type(of: v))"
    }
    @MainActor func populateView(_ view: MKAnnotationView) { }
    var selection: (@MainActor () -> Void)? { nil }
    var isSelectable: Bool { selection != nil }
}

extension MapItem where Self: _MapItem {
    func _visit(using visitor: (any _MapItem) -> Void) { visitor(self) }
    nonisolated var annotation: (any MKAnnotation)? { nil }
}

extension EmptyView: _MapItem {
    nonisolated func _visit(using visitor: (any _MapItem) -> Void) { }
}

extension Optional: _MapItem where Wrapped: MapItem & _MapItem {
    nonisolated func _visit(using visitor: (any _MapItem) -> Void) {
        guard let wrapped = self else { return }
        wrapped._visit(using: visitor)
    }
}

extension _ConditionalContent: _MapItem where TrueContent: MapItem & _MapItem, FalseContent: MapItem & _MapItem {
    nonisolated func _visit(using visitor: (any _MapItem) -> Void) {
        switch self.storage {
            case .trueContent(let t): t._visit(using: visitor)
            case .falseContent(let f):f._visit(using: visitor)
        }
    }
}

extension TupleView: _MapItem where T: MapItem & _MapItem {
    nonisolated func _visit(using visitor: (any _MapItem) -> Void) {
        value._visit(using: visitor)
    }
}

@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 2.0, *)
extension TupleContent: _MapItem where repeat each Content: MapItem & _MapItem {
    nonisolated func _visit(using visitor: (any _MapItem) -> Void) {
        repeat (each content)._visit(using: visitor)
    }
}

extension ForEach: _MapItem where Content: MapItem & _MapItem {
    nonisolated func _visit(using visitor: (any _MapItem) -> Void) {
        data.forEach { c in content(c)._visit(using: visitor) }
    }
}

//
//  SwiftUIView.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/12/26.
//

import SwiftUI

public protocol MapMarkerContent { }

internal protocol _MapMarkerContent: MapMarkerContent {
    var content: MarkerContent { get }
}

public struct MapMarker: MapMarkerContent, _MapMarkerContent {
    
    internal var content = MarkerContent()
    
    public init() { }
    
    public func tint(_ color: PlatformColor?) -> MapMarker {
        var copy = self
        copy.content.tint = color
        return copy
    }
    
    public func glyph(_ text: String?) -> MapMarker {
        var copy = self
        copy.content.glyphText = text
        return copy
    }
    
    public func glyph(_ image: PlatformImage?) -> MapMarker {
        var copy = self
        copy.content.glyphImage = image
        return copy
    }
    
    public func glyph(symbol name: String) -> MapMarker {
        var copy = self
        copy.content.glyphImage = PlatformImage(systemName: name)
        return copy
    }
    
    public func glyph(named name: String, in bundle: Bundle? = nil) -> MapMarker {
        var copy = self
        copy.content.glyphImage = PlatformImage(named: name, in: bundle, with: nil)
        return copy
    }
    
    public func glyphTint(_ color: PlatformColor?) -> MapMarker {
        var copy = self
        copy.content.glyphTint = color
        return copy
    }
    
    public func selectedGlyph(_ image: PlatformImage?) -> MapMarker {
        var copy = self
        copy.content.selectedGlyphImage = image
        return copy
    }
    
    public func title(_ visibility: Visibility) -> MapMarker {
        var copy = self
        copy.content.titleVisibility = visibility
        return copy
    }
    
    public func subtitle(_ visibility: Visibility) -> MapMarker {
        var copy = self
        copy.content.subtitleVisibility = visibility
        return copy
    }
    
    public func title(_ string: String?) -> MapMarker {
        var copy = self
        copy.content.title = string
        return copy
    }
    
    public func subtitle(_ string: String?) -> MapMarker {
        var copy = self
        copy.content.subtitle = string
        return copy
    }
    
    
}

// MARK: - ContentBuilder support

extension EmptyView: MapMarkerContent { }

extension _ConditionalContent: MapMarkerContent where TrueContent: MapMarkerContent, FalseContent: MapMarkerContent { }

extension Optional: MapMarkerContent where Wrapped: MapMarkerContent { }

extension EmptyView: _MapMarkerContent {
    var content: MarkerContent { .init() }
}

extension _ConditionalContent: _MapMarkerContent where TrueContent: _MapMarkerContent, FalseContent: _MapMarkerContent {
    var content: MarkerContent {
        switch self.storage {
            case .trueContent(let t): return t.content
            case .falseContent(let f): return f.content
        }
    }
}

extension Optional: _MapMarkerContent where Wrapped: _MapMarkerContent {
    var content: MarkerContent {
        if let wrapped = self { return wrapped.content }
        return .init()
    }
}

// MARK: multiple marker support

//extension TupleView: MapItem where T: MapItem {
//    public nonisolated func _visit(using visitor: (any MapItem) -> Void) { value._visit(using: visitor) }
//}
//
//@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 2.0, *)
//extension TupleContent: MapItem where repeat each Content: MapItem {
//    public nonisolated func _visit(using visitor: (any MapItem) -> Void) {
//        repeat (each content)._visit(using: visitor)
//    }
//}
//
//extension ForEach: MapItem where Content: MapItem {
//    public nonisolated func _visit(using visitor: (any MapItem) -> Void) {
//        data.forEach { c in content(c)._visit(using: visitor) }
//    }
//}

//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/4/23.
//

import Foundation
import SwiftUI

#if os(macOS)
import AppKit

public typealias PlatformImage = NSImage
public typealias PlatformView = NSView
public typealias PlatformColor = NSColor
public typealias PlatformViewRepresentableType = NSViewRepresentable

//extension PlatformViewRepresentableType {
//    public typealias _ViewType = NSViewType
//}

#else
import UIKit

public typealias PlatformImage = UIImage
public typealias PlatformView = UIView
public typealias PlatformColor = UIColor
public typealias PlatformViewRepresentableType = UIViewRepresentable

//extension PlatformViewRepresentableType {
//    public typealias _ViewType = UIViewType
//}

#endif

@MainActor
public protocol PlatformViewRepresentable: PlatformViewRepresentableType {
    #if os(macOS)
    func makePlatformView(context: Self.Context) -> Self.NSViewType
    func updatePlatformView(_ platformView: Self.NSViewType, context: Self.Context)
    static func dismantlePlatformView(_ uiView: Self.NSViewType, coordinator: Self.Coordinator)
    #else
    func makePlatformView(context: Self.Context) -> Self.UIViewType
    func updatePlatformView(_ platformView: Self.UIViewType, context: Self.Context)
    static func dismantlePlatformView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator)
    #endif
}

extension PlatformViewRepresentable {
    
    #if os(macOS)
    public func makeNSView(context: NSViewRepresentableContext<Self>) -> NSViewType {
        return self.makePlatformView(context: context)
    }
    public func updateNSView(_ nsView: NSViewType, context: NSViewRepresentableContext<Self>) {
        self.updatePlatformView(nsView, context: context)
    }
    public static func dismantleNSView(_ nsView: NSViewType, coordinator: Coordinator) {
        self.dismantlePlatformView(nsView, coordinator: coordinator)
    }
    public static func dismantlePlatformView(_ uiView: Self.ViewType, coordinator: Self.Coordinator) { }
    #else
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        return self.makePlatformView(context: context)
    }
    public func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        self.updatePlatformView(uiView, context: context)
    }
    public static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {
        self.dismantlePlatformView(uiView, coordinator: coordinator)
    }
    public static func dismantlePlatformView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator) { }
    #endif
    
}

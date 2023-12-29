//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/4/23.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
#if os(macOS)
import AppKit
#endif

/*
 Jake’s SwiftUI Gotchas
 - Always define an SF Symbol with the SwiftUI.Image initializer, do not use a UIImage or NSImage with symbol configurations as those will not be honored.
 - Always use font (size and weight) and imageScale modifiers when attempting to adjust the size of the symbol in relation to other text
 - Never use the resizable() modifier on SF Symbols. Basically ever.
 - And also do not use .scaleToFit() / .aspectRatio() on them either.
 Bonus
 - If using an icon-only button, still declare the title of the button’s label and use .labelStyle(.iconOnly) for some great accessibility wins
 */
public struct Symbol {
    
    public enum SymbolSource {
        case image(PlatformImage)
        case systemName(String)
        case named(String, Bundle?)
        case imageView(SwiftUI.Image)
    }
    
    public let sourceProvider: () -> SymbolSource
    
    public init(sourceProvider: @escaping () -> SymbolSource) {
        self.sourceProvider = sourceProvider
    }
    
    public init(image: PlatformImage) {
        self.sourceProvider = { .image(image) }
    }
    
    public init(systemName: String) {
        self.sourceProvider = { .systemName(systemName) }
    }
    
    public init(named: String, bundle: Bundle? = nil) {
        self.sourceProvider = { .named(named, bundle) }
    }
    
}

extension Symbol {
    
    public static func icon(_ name: String, in bundle: Bundle? = nil) -> Self {
        self.init(sourceProvider: { .named(name, bundle) })
    }
    
    public static func systemName(_ name: String) -> Self {
        self.init(sourceProvider: { .systemName(name) })
    }
    
    public static func image(_ image: PlatformImage) -> Self {
        self.init(sourceProvider: { .image(image) })
    }
    
    #if os(macOS)
    public static func fileType(_ type: UTType) -> Self {
        self.init(sourceProvider: {
            let img = NSWorkspace.shared.icon(for: type)
            return .image(img)
        })
    }
    
    public static func fileIcon(_ url: URL) -> Self {
        self.init(sourceProvider: {
            let img = NSWorkspace.shared.icon(forFile: url.path())
            return .image(img)
        })
    }
    
    public static func fileIcon(_ path: ExtendedSwift.Path) -> Self {
        self.init(sourceProvider: {
            let img = NSWorkspace.shared.icon(forFile: path.fileSystemPath)
            return .image(img)
        })
    }
    
    public static func application(_ bundleID: String) -> Self {
        self.init(sourceProvider: {
            if let u = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
                return .image(NSWorkspace.shared.icon(forFile: u.path(percentEncoded: false)))
            }
            return .systemName("questionmark.app")
        })
    }
    #endif
}

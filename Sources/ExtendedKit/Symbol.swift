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

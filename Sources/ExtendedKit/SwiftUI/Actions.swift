//
//  Actions.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 8/31/25.
//

import SwiftUI

#if os(macOS) && canImport(AppKit)

import AppKit

extension EnvironmentValues {
    public var revealInFinder: RevealInFinder { RevealInFinder.default }
    
    public var copyToPasteboard: CopyToPasteboard { CopyToPasteboard.default }
    
    public var openSystemSettings: OpenSystemSettings { OpenSystemSettings(open: self.openURL) }
}

public struct RevealInFinder {
    fileprivate static let `default` = Self()
    
    public func callAsFunction(_ url: URL) {
        self.callAsFunction([url])
    }
    
    public func callAsFunction(_ urls: URL...) {
        self.callAsFunction(urls)
    }
    
    public func callAsFunction(_ urls: any Collection<URL>) {
        let fileURLs = urls.filter({ $0.isFileURL })
        NSWorkspace.shared.activateFileViewerSelecting(fileURLs)
    }
    
}

public struct CopyToPasteboard {
    fileprivate static let `default` = Self()
    
    public func callAsFunction<O: _ObjectiveCBridgeable>(_ item: O, to pasteboard: NSPasteboard = .general) where O._ObjectiveCType: NSPasteboardWriting {
        let writer = item._bridgeToObjectiveC()
        pasteboard.clearContents()
        pasteboard.writeObjects([writer])
    }
    
    public func callAsFunction<C: Collection>(_ items: C, to pasteboard: NSPasteboard = .general) where C.Element: _ObjectiveCBridgeable, C.Element._ObjectiveCType: NSPasteboardWriting {
        let writers = items.map { $0._bridgeToObjectiveC() }
        pasteboard.clearContents()
        pasteboard.writeObjects(writers)
    }
    
    public func callAsFunction(_ item: any NSPasteboardWriting, to pasteboard: NSPasteboard = .general) {
        self.callAsFunction([item], to: pasteboard)
    }
    
    public func callAsFunction(_ items: (any NSPasteboardWriting)..., to pasteboard: NSPasteboard = .general) {
        self.callAsFunction(items, to: pasteboard)
    }
    
    public func callAsFunction(_ items: any Collection<any NSPasteboardWriting>, to pasteboard: NSPasteboard = .general) {
        pasteboard.clearContents()
        let array = Array(items)
        pasteboard.writeObjects(array)
    }
    
//    @available(macOS 15.2, *)
//    @_disfavoredOverload
//    public func callAsFunction<T: Transferable>(_ item: T, to pasteboard: NSPasteboard = .general) {
//        let provider = NSItemProvider()
//        let visibilities: Array<(NSItemProviderRepresentationVisibility, TransferRepresentationVisibility)> = [
//            (.group, .group),
//            (.ownProcess, .ownProcess),
//            (.all, .all),
//        ]
//        
//        for (ns, xfer) in visibilities {
//            let types = item.exportedContentTypes(xfer)
//            for type in types {
//                provider.registerDataRepresentation(for: type, visibility: ns) { done in
//                    let p = Progress()
//                    Task {
//                        do {
//                            let data = try await item.exported(as: type)
//                            p.totalUnitCount = 1
//                            p.completedUnitCount = 1
//                            done(data, nil)
//                        } catch {
//                            done(nil, error)
//                        }
//                    }
//                    return p
//                }
//            }
//        }
//        
//        
//    }
    
}

public struct OpenSystemSettings {
    
    public struct Pane {
        public static let general = Self(rawValue: "com.apple.preference.general")
        public static let desktop = Self(rawValue: "com.apple.preference.desktopscreeneffect")
        public static let dock = Self(rawValue: "com.apple.preference.dock")
        public static let language = Self(rawValue: "com.apple.preference.language")
        public static let notifications = Self(rawValue: "com.apple.preference.notifications")
        
        public static let bluetooth = Self(rawValue: "com.apple.preference.bluetooth")
        public static let sound = Self(rawValue: "com.apple.preference.sound")
        public static let displays = Self(rawValue: "com.apple.preference.displays")
        public static let usersAndGroups = Self(rawValue: "com.apple.preference.users")
        public static let dateAndTime = Self(rawValue: "com.apple.preference.datetime")
        public static let accessibility = Self(rawValue: "com.apple.preference.universalaccess")
        public static let softwareUpdate = Self(rawValue: "com.apple.preferences.softwareupdate")
        public static let energySaver = Self(rawValue: "com.apple.preference.energysaver")
        public static let timeMachine = Self(rawValue: "com.apple.preference.timemachine")
        public static let keyboard = Self(rawValue: "com.apple.preference.keyboard")
        public static let mouse = Self(rawValue: "com.apple.preference.mouse")
        public static let trackpad = Self(rawValue: "com.apple.preference.trackpad")
        public static let printers = Self(rawValue: "com.apple.preference.printfax")
        public static let sharing = Self(rawValue: "com.apple.preferences.sharing")
        
        public static let security = security(nil)
        public static func security(_ section: SecuritySection?) -> Self {
            var raw = "com.apple.preference.security"
            if let section { raw += "?" + section.rawValue }
            return Self(rawValue: raw)
        }
        
        public static let network = network(nil)
        public static func network(_ section: NetworkSection?) -> Self {
            var raw = "com.apple.preference.network"
            if let section { raw += "?service=" + section.rawValue }
            return Self(rawValue: raw)
        }
        
        internal let rawValue: String
    }
    
    public struct SecuritySection {
        public static let location = Self(rawValue: "Privacy_LocationServices")
        public static let camera = Self(rawValue: "Privacy_Camera")
        public static let microphone = Self(rawValue: "Privacy_Microphone")
        public static let accessibility = Self(rawValue: "Privacy_Accessibility")
        public static let filesAndFolders = Self(rawValue: "Privacy_ApplicationData")
        public static let fileVault = Self(rawValue: "FileVault")
        public static let firewall = Self(rawValue: "Firewall")
        
        internal let rawValue: String
    }
    
    public struct NetworkSection {
        public static let wifi = Self(rawValue: "Wi-Fi")
        
        internal let rawValue: String
    }
    
    fileprivate let open: OpenURLAction
    
    public func callAsFunction(_ pane: Pane) {
        let raw = "x-apple.systempreferences:" + pane.rawValue
        guard let u = URL(string: raw) else { return }
        open(u)
    }
}

#endif

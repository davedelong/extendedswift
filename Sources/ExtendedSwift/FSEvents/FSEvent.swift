//
//  FSEvent.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/20/22.
//

import Foundation

#if os(macOS)

public enum FSEvent {
    case rescanRoot(FSFlags)
    
    case created(FSFlags, Path)
    case removed(FSFlags, Path)
    case modified(FSFlags, Path)
    case infoModified(FSFlags, Path)
    case renamed(FSFlags, Path, Path)
}

public struct FSFlags: OptionSet, CustomStringConvertible {
    public static let none = FSFlags(rawValue: kFSEventStreamEventFlagNone)
    public static let mustScanSubDirs = FSFlags(rawValue: kFSEventStreamEventFlagMustScanSubDirs)
    public static let userDropped = FSFlags(rawValue: kFSEventStreamEventFlagUserDropped)
    public static let kernelDropped = FSFlags(rawValue: kFSEventStreamEventFlagKernelDropped)
    public static let eventIdsWrapped = FSFlags(rawValue: kFSEventStreamEventFlagEventIdsWrapped)
    public static let historyDone = FSFlags(rawValue: kFSEventStreamEventFlagHistoryDone)
    public static let rootChanged = FSFlags(rawValue: kFSEventStreamEventFlagRootChanged)
    public static let mount = FSFlags(rawValue: kFSEventStreamEventFlagMount)
    public static let unmount = FSFlags(rawValue: kFSEventStreamEventFlagUnmount)
    public static let itemCreated = FSFlags(rawValue: kFSEventStreamEventFlagItemCreated)
    public static let itemRemoved = FSFlags(rawValue: kFSEventStreamEventFlagItemRemoved)
    public static let itemInodeMetaMod = FSFlags(rawValue: kFSEventStreamEventFlagItemInodeMetaMod)
    public static let itemRenamed = FSFlags(rawValue: kFSEventStreamEventFlagItemRenamed)
    public static let itemModified = FSFlags(rawValue: kFSEventStreamEventFlagItemModified)
    public static let itemFinderInfoMod = FSFlags(rawValue: kFSEventStreamEventFlagItemFinderInfoMod)
    public static let itemChangeOwner = FSFlags(rawValue: kFSEventStreamEventFlagItemChangeOwner)
    public static let itemXattrMod = FSFlags(rawValue: kFSEventStreamEventFlagItemXattrMod)
    public static let itemIsFile = FSFlags(rawValue: kFSEventStreamEventFlagItemIsFile)
    public static let itemIsDir = FSFlags(rawValue: kFSEventStreamEventFlagItemIsDir)
    public static let itemIsSymlink = FSFlags(rawValue: kFSEventStreamEventFlagItemIsSymlink)
    public static let ownEvent = FSFlags(rawValue: kFSEventStreamEventFlagOwnEvent)
    public static let itemIsHardlink = FSFlags(rawValue: kFSEventStreamEventFlagItemIsHardlink)
    public static let itemIsLastHardlink = FSFlags(rawValue: kFSEventStreamEventFlagItemIsLastHardlink)
    public static let itemCloned = FSFlags(rawValue: kFSEventStreamEventFlagItemCloned)

    
    private static let itemMetadataFlags: FSFlags = [.itemInodeMetaMod, .itemFinderInfoMod, .itemChangeOwner, .itemXattrMod]

    private static let itemFlags: FSFlags = [.itemCreated, .itemRemoved, .itemRenamed, .itemModified,
                                             .itemInodeMetaMod, .itemFinderInfoMod, .itemChangeOwner, .itemXattrMod]
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public var description: String {
        var pieces = Array<String>()

        if contains(.mustScanSubDirs) { pieces.append("mustScanSubDirs") }
        if contains(.userDropped) { pieces.append("userDropped") }
        if contains(.kernelDropped) { pieces.append("kernelDropped") }
        if contains(.eventIdsWrapped) { pieces.append("eventIdsWrapped") }
        if contains(.historyDone) { pieces.append("historyDone") }
        if contains(.rootChanged) { pieces.append("rootChanged") }
        if contains(.mount) { pieces.append("mount") }
        if contains(.unmount) { pieces.append("unmount") }
        if contains(.itemCreated) { pieces.append("itemCreated") }
        if contains(.itemRemoved) { pieces.append("itemRemoved") }
        if contains(.itemInodeMetaMod) { pieces.append("itemInodeMetaMod") }
        if contains(.itemRenamed) { pieces.append("itemRenamed") }
        if contains(.itemModified) { pieces.append("itemModified") }
        if contains(.itemFinderInfoMod) { pieces.append("itemFinderInfoMod") }
        if contains(.itemChangeOwner) { pieces.append("itemChangeOwner") }
        if contains(.itemXattrMod) { pieces.append("itemXattrMod") }
        if contains(.itemIsFile) { pieces.append("itemIsFile") }
        if contains(.itemIsDir) { pieces.append("itemIsDir") }
        if contains(.itemIsSymlink) { pieces.append("itemIsSymlink") }
        if contains(.ownEvent) { pieces.append("ownEvent") }
        if contains(.itemIsHardlink) { pieces.append("itemIsHardlink") }
        if contains(.itemIsLastHardlink) { pieces.append("itemIsLastHardlink") }
        if contains(.itemCloned) { pieces.append("itemCloned") }

        return "FSFlags(\(hex: rawValue): " + pieces.joined(separator: ", ") + ")"
    }
    
    public var isItemEvent: Bool { self.intersects(Self.itemFlags) }
    
    public var isItemMetadataEvent: Bool { self.intersects(Self.itemMetadataFlags) }
    
    public var originatesFromCurrentProcess: Bool { self.contains(.ownEvent) }
}

#endif

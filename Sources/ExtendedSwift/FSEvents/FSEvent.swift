//
//  FSEvent.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/20/22.
//

import Foundation

#if os(macOS)

public struct FSEvent: Identifiable, Hashable, Sendable {
    public typealias ID = FSEventStreamEventId
    
    public let id: ID
    public var flags: Flags
    
    public var url: URL
    public var newURL: URL?
    
    public var fileID: UInt64?
    public var docID: UInt64?
    
    public var rescanRoot: Bool {
        if flags.contains(.mustScanSubDirs) || flags.contains(.userDropped) || flags.contains(.kernelDropped) {
            return isItemEvent && !isItemMetadataEvent
        } else {
            return false
        }
    }
    
    public var isMetaEvent: Bool { flags.intersects(.anyMetaFlags) }
    public var isItemEvent: Bool { flags.intersects(.anyItemFlags) }
    public var isItemMetadataEvent: Bool { flags.intersects(.anyMetadataFlags) }
    public var originatesFromCurrentProcess: Bool { flags.contains(.ownEvent) }
    
    public var isDirectory: Bool { flags.contains(.isDir) }
    public var isFile: Bool { flags.contains(.isFile) }
    public var isRename: Bool { flags.contains(.renamed) }
    public var isDeletion: Bool { flags.contains(.removed) }
    public var isModification: Bool { flags.intersects(.anyModificationFlags) }
    public var isCreation: Bool { flags.contains(.created) || flags.contains(.cloned) }
    
    public struct Flags: OptionSet, CustomStringConvertible, Hashable, Sendable {
        public static let none = Flags(rawValue: kFSEventStreamEventFlagNone)
        public static let mustScanSubDirs = Flags(rawValue: kFSEventStreamEventFlagMustScanSubDirs)
        public static let userDropped = Flags(rawValue: kFSEventStreamEventFlagUserDropped)
        public static let kernelDropped = Flags(rawValue: kFSEventStreamEventFlagKernelDropped)
        public static let eventIdsWrapped = Flags(rawValue: kFSEventStreamEventFlagEventIdsWrapped)
        public static let historyDone = Flags(rawValue: kFSEventStreamEventFlagHistoryDone)
        public static let rootChanged = Flags(rawValue: kFSEventStreamEventFlagRootChanged)
        public static let mount = Flags(rawValue: kFSEventStreamEventFlagMount)
        public static let unmount = Flags(rawValue: kFSEventStreamEventFlagUnmount)
        
        public static let ownEvent = Flags(rawValue: kFSEventStreamEventFlagOwnEvent)
        
        public static let created = Flags(rawValue: kFSEventStreamEventFlagItemCreated)
        public static let removed = Flags(rawValue: kFSEventStreamEventFlagItemRemoved)
        public static let renamed = Flags(rawValue: kFSEventStreamEventFlagItemRenamed)
        public static let modified = Flags(rawValue: kFSEventStreamEventFlagItemModified)
        public static let cloned = Flags(rawValue: kFSEventStreamEventFlagItemCloned)
        public static let changedOwner = Flags(rawValue: kFSEventStreamEventFlagItemChangeOwner)
        
        public static let inodeMetadataModified = Flags(rawValue: kFSEventStreamEventFlagItemInodeMetaMod)
        public static let finderInfoModified = Flags(rawValue: kFSEventStreamEventFlagItemFinderInfoMod)
        public static let xattrModified = Flags(rawValue: kFSEventStreamEventFlagItemXattrMod)
        
        public static let isFile = Flags(rawValue: kFSEventStreamEventFlagItemIsFile)
        public static let isDir = Flags(rawValue: kFSEventStreamEventFlagItemIsDir)
        public static let isSymlink = Flags(rawValue: kFSEventStreamEventFlagItemIsSymlink)
        public static let isHardlink = Flags(rawValue: kFSEventStreamEventFlagItemIsHardlink)
        public static let isLastHardlink = Flags(rawValue: kFSEventStreamEventFlagItemIsLastHardlink)
        
        fileprivate static let anyMetaFlags: Flags = [.mustScanSubDirs, .userDropped, .kernelDropped, .eventIdsWrapped,
                                                      .historyDone, .rootChanged, .mount, .unmount]
        
        fileprivate static let anyItemFlags: Flags = [.created, .removed, .renamed, .modified, .cloned, .changedOwner,
                                                      .inodeMetadataModified, .finderInfoModified, .xattrModified]
        
        fileprivate static let anyMetadataFlags: Flags = [.inodeMetadataModified, .finderInfoModified, .changedOwner, .xattrModified]
        
        fileprivate static let anyModificationFlags: Flags = [.modified, .finderInfoModified, .xattrModified, .inodeMetadataModified]
        
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
            if contains(.ownEvent) { pieces.append("ownEvent") }
            
            if contains(.created) { pieces.append("itemCreated") }
            if contains(.removed) { pieces.append("itemRemoved") }
            if contains(.renamed) { pieces.append("itemRenamed") }
            if contains(.modified) { pieces.append("itemModified") }
            if contains(.cloned) { pieces.append("itemCloned") }
            if contains(.changedOwner) { pieces.append("itemChangeOwner") }
            
            if contains(.inodeMetadataModified) { pieces.append("itemInodeMetaMod") }
            if contains(.finderInfoModified) { pieces.append("itemFinderInfoMod") }
            if contains(.xattrModified) { pieces.append("itemXattrMod") }
            
            if contains(.isFile) { pieces.append("itemIsFile") }
            if contains(.isDir) { pieces.append("itemIsDir") }
            if contains(.isSymlink) { pieces.append("itemIsSymlink") }
            if contains(.isHardlink) { pieces.append("itemIsHardlink") }
            if contains(.isLastHardlink) { pieces.append("itemIsLastHardlink") }
            
            return "FSFlags(\(hex: rawValue): " + pieces.joined(separator: ", ") + ")"
        }
    }
}

#endif

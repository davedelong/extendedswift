//
//  NSFileObserver.swift
//  VideoLibrary
//
//  Created by Dave DeLong on 11/20/22.
//

import Foundation
import Combine

// internal while i still work on this
#warning("TODO: FileObserver")

struct Item: Identifiable, Hashable {
    let id: URL
    let displayName: String
//    let icon: NSImage
}

internal class FolderObserver: NSObject, NSFilePresenter {
    private let folder: URL
    
    internal var presentedItemURL: URL? { folder }
    internal var presentedItemOperationQueue = OperationQueue()
    let directoryChangedPublisher = PassthroughSubject<Array<Item>, Never>()
    
    private var hasAddedAsPresenter = false

    internal init(directory: Path) {
        self.folder = directory.fileURL
        super.init()
        self.performInitialScan()
    }

    deinit {
        if hasAddedAsPresenter {
            NSFileCoordinator.removeFilePresenter(self)
        }
    }

    private func performInitialScan() {
        DispatchQueue.global(qos: .userInitiated).async {
            let iter = FileManager.default.enumerator(at: self.folder,
                                                      includingPropertiesForKeys: [.nameKey])
            
            let a = iter?.compactMap { item -> Item? in
                guard let url = item as? URL else { return nil }
                let values = try? url.resourceValues(forKeys: [.nameKey])

                let name = values?.name ?? url.lastPathComponent
//                let icon = NSWorkspace.shared.icon(forFile: url.path)
                return Item(id: url, displayName: name)//, icon: icon)
            }

            self.directoryChangedPublisher.send(a ?? [])
        }
        
        hasAddedAsPresenter = true
        NSFileCoordinator.addFilePresenter(self)
    }
    
    internal func presentedItemDidChange() {
        print("\(#function)")
        if let url = presentedItemURL {
            print("Directory changed: \(url)")

            let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: [.skipsSubdirectoryDescendants])

            let items = contents?.map { url -> Item in
                let values = try? url.resourceValues(forKeys: [.nameKey])

                let name = values?.name ?? url.lastPathComponent
                return Item(id: url, displayName: name)
            }

            directoryChangedPublisher.send(items ?? [])
        }
    }

    internal func presentedSubitemDidChange(at url: URL) {
        print("\(#function): \(url)")
    }
}

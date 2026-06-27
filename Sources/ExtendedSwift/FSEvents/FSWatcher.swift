//
//  FSWatcher.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 6/27/26.
//

import Foundation

#if os(macOS)

internal class FSWatcher {
    private let url: URL
    fileprivate let report: (FSEvent) -> Void
    
    private var stream: FSEventStreamRef?
    
    private var strongSelf: FSWatcher?
    
    init(url: URL, report: @escaping (FSEvent) -> Void) {
        self.url = url
        self.report = report
        
        // retaining self makes using this with AsyncSequence a little bit nicer
        self.strongSelf = self
        start()
    }
    
    func cancel() { strongSelf = nil }
    
    private func start() {
        guard stream == nil else { return }
        
        var context = FSEventStreamContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = Unmanaged.passUnretained(self).toOpaque()
        
        stream = FSEventStreamCreate(kCFAllocatorDefault,
                                     fscallback,
                                     &context,
                                     NSArray(object: url.path(percentEncoded: false) as NSString) as CFArray,
                                     FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
                                     0.1,
                                     FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes |
                                                              kFSEventStreamCreateFlagUseExtendedData |
                                                              kFSEventStreamCreateFlagWatchRoot |
                                                              kFSEventStreamCreateFlagFileEvents |
                                                              kFSEventStreamCreateFlagMarkSelf))
        
        if let stream {
            let queue = DispatchQueue(label: "fswatcher-\(ObjectIdentifier(self))")
            FSEventStreamSetDispatchQueue(stream, queue)
            FSEventStreamStart(stream)
        }
        
    }
    
    deinit {
        if let stream {
            FSEventStreamStop(stream)
            FSEventStreamSetDispatchQueue(stream, nil)
        }
    }
}

private func fscallback(_ stream: ConstFSEventStreamRef, _ callbackInfo: UnsafeMutableRawPointer?, _ numberOfEvents: Int, _ eventDatas: UnsafeMutableRawPointer, _ flags: UnsafePointer<FSEventStreamEventFlags>, _ eventIDs: UnsafePointer<FSEventStreamEventId>) {
    
    let watcher = unsafeBitCast(callbackInfo, to: FSWatcher.self)
    guard let datas = unsafeBitCast(eventDatas, to: NSArray.self) as? [Dictionary<String, Any>] else { return }
    
    var index = 0
    while index < numberOfEvents {
        defer { index += 1 }
        
        let data = datas[index]
        let path = data[kFSEventStreamEventExtendedDataPathKey] as! String
        let flags = FSEvent.Flags(rawValue: Int(flags[index]))
        let this = URL(filePath: path)
        
        var event = FSEvent(id: eventIDs[index],
                            flags: flags,
                            url: this,
                            newURL: nil,
                            fileID: data[kFSEventStreamEventExtendedFileIDKey] as? UInt64,
                            docID: data[kFSEventStreamEventExtendedDocIDKey] as? UInt64)
        
        if flags.contains(.renamed) && (index + 1) > numberOfEvents {
            index += 1
            let nextData = datas[index]
            let nextPath = nextData[kFSEventStreamEventExtendedDataPathKey] as! String
            let newURL = URL(filePath: nextPath)
            event.newURL = newURL
        }
        
        watcher.report(event)
    }
    
}

#endif

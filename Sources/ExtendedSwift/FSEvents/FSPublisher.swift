//
//  FSPublisher.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 11/5/22.
//

import Foundation
import Combine

#if os(macOS)

public struct FSPublisher: Publisher {
    public typealias Output = FSEvent
    public typealias Failure = Never

    public var path: Path
    
    public init(path: Path) {
        self.path = path
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = FSSubscription(path: path.fileURL, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }

}

private class FSSubscription: Subscription {
    private let path: URL
    private var stream: FSEventStreamRef?
    private var started = false

    private let sendToSubscriber: (FSPublisher.Output) -> Subscribers.Demand
    private var currentDemand: Subscribers.Demand = .none

    init<T: Subscriber>(path: URL, subscriber: T) where T.Input == FSPublisher.Output, T.Failure == FSPublisher.Failure {
        self.path = path
        self.sendToSubscriber = { subscriber.receive($0) }

    }

    private func buildStreamIfNecessary() -> FSEventStreamRef? {
        if stream == nil {
            var context = FSEventStreamContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            context.info = Unmanaged.passUnretained(self).toOpaque()

            stream = FSEventStreamCreate(kCFAllocatorDefault,
                                         fscallback,
                                         &context,
                                         NSArray(object: path.path as NSString) as CFArray,
                                         FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
                                         1.0,
                                         FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes |
                                                                  kFSEventStreamCreateFlagWatchRoot |
                                                                  kFSEventStreamCreateFlagFileEvents |
                                                                  kFSEventStreamCreateFlagMarkSelf))

            if let s = stream {
                FSEventStreamSetDispatchQueue(s, .main)
            }
        }
        return stream
    }

    func request(_ demand: Subscribers.Demand) {
        self.currentDemand += demand

        if currentDemand > 0, started == false {
            if let stream = buildStreamIfNecessary() {
                started = FSEventStreamStart(stream)
            }
        }
    }

    func cancel() {
        if let stream = self.stream {
            if started == true { FSEventStreamStop(stream) }
            FSEventStreamSetDispatchQueue(stream, nil)
            started = false
            currentDemand = .none
            self.stream = nil
        }
    }

    fileprivate func send(_ event: FSEvent) {
        currentDemand = sendToSubscriber(event)
        if let s = stream, started == true, currentDemand <= .none {
            FSEventStreamStop(s)
            started = false
        }
    }
}

private func fscallback(_ stream: ConstFSEventStreamRef, _ callbackInfo: UnsafeMutableRawPointer?, _ numberOfEvents: Int, _ eventPaths: UnsafeMutableRawPointer, _ flags: UnsafePointer<FSEventStreamEventFlags>, _ eventIDs: UnsafePointer<FSEventStreamEventId>) {

    let subscription = unsafeBitCast(callbackInfo, to: FSSubscription.self)
    guard let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] else { return }

    var index = 0
    while index < numberOfEvents {
        defer { index += 1 }
        
        let data = paths[index]
        let flags = FSFlags(rawValue: Int(flags[index]))
        let this = Path(fileSystemPath: data)
        
        if flags.contains(.mustScanSubDirs) || flags.contains(.userDropped) || flags.contains(.kernelDropped) {
            if flags.isItemEvent {
                if !flags.isItemMetadataEvent {
                    subscription.send(.rescanRoot(flags))
                }
            } else {
                subscription.send(.rescanRoot(flags))
            }
        } else if flags.contains(.itemCreated) || flags.contains(.itemCloned) {
            subscription.send(.created(flags, this))
        } else if flags.contains(.itemRemoved) {
            subscription.send(.removed(flags, this))
        } else if flags.contains(.itemModified) {
            subscription.send(.modified(flags, this))
        } else if flags.contains(.itemFinderInfoMod) {
            subscription.send(.infoModified(flags, this))
        } else if flags.contains(.itemRenamed) && (index + 1) < numberOfEvents {
            index += 1
            let that = Path(fileSystemPath: paths[index])
            subscription.send(.renamed(flags, this, that))
        } else {
            print("SKIPPING UNKNOWN EVENT \(flags) @ \(data)")
        }
    }

}

#endif

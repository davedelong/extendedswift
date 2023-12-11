//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/9/23.
//

import Foundation
import SwiftUI

#if os(macOS)

public struct PathControl<Actions: View>: View {
    private let segments: Array<PathSegment>
    private let contextMenuBuilder: (ExtendedSwift.Path) -> Actions
    
    @State private var prioritizedPath: ExtendedSwift.Path?

    public init(_ path: URL) where Actions == EmptyView {
        self.init(path.absolutePath)
    }
    
    public init(_ path: URL, @ViewBuilder segmentActions: @escaping (URL) -> Actions) {
        self.init(path.absolutePath, segmentActions: { path in
            segmentActions(path.fileURL)
        })
    }
    
    public init(_ path: ExtendedSwift.Path) where Actions == EmptyView {
        self.segments = PathSegment.segments(from: path)
        self.contextMenuBuilder = { _ in EmptyView() }
    }
    
    public init(_ path: ExtendedSwift.Path, @ViewBuilder segmentActions: @escaping (ExtendedSwift.Path) -> Actions) {
        self.segments = PathSegment.segments(from: path)
        self.contextMenuBuilder = segmentActions
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(segments, id: \.path) { segment in
                label(for: segment)
                
                if segment.isLast == false {
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.secondary)
                }
            }
        }
        .transition(.slide)
        .help(segments.last?.displayName ?? "")
    }

    private func label(for segment: PathSegment) -> some View {
        let effectivePriority = segment.priority + (prioritizedPath == segment.path ? Double(segments.count) : 0)
        
        return Label(title: {
            Text(segment.displayName)
                .truncationMode(.tail)
                .lineLimit(1)
        }, icon: {
            Image(nsImage: segment.image)
                .resizable()
                .frame(width: 14, height: 14)
                .aspectRatio(1.0, contentMode: .fit)
        })
        .padding(.leading, segment.isFirst ? 0 : 2)
        .padding(.trailing, segment.isLast ? 0 : 2)
        .layoutPriority(effectivePriority)
        .onDrag { NSItemProvider(contentsOf: segment.path.fileURL)! }
        .contentShape(Rectangle())
        .contextMenu { contextMenuBuilder(segment.path) }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                self.prioritizedPath = (hovering ? segment.path : nil)
            }
        }
    }
    
}

private struct PathSegment {
    static func segments(from path: ExtendedSwift.Path) -> Array<PathSegment> {
        let home = Path.home.components

        var components = Array<ExtendedSwift.PathComponent>()
        
        let fm = FileManager.default
        let ws = NSWorkspace.shared
        
        let root = ExtendedSwift.Path(fileSystemPath: "/")
        var pieces = [
            PathSegment(path: root,
                        displayName: fm.displayName(at: root),
                        image: ws.icon(for: root),
                        priority: 0,
                        isFirst: false,
                        isLast: false)
        ]
        
        for component in path.components {
            components.append(component)
            
            if components == home { pieces.removeAll() }
            
            let thisPath = ExtendedSwift.Path(components)
            pieces.append(.init(path: thisPath,
                                displayName: fm.displayName(at: thisPath),
                                image: ws.icon(for: thisPath),
                                priority: 0,
                                isFirst: false,
                                isLast: false))
        }
        
        // segment priority:
        // 1. last
        // 2. second-to-last
        // 3. first
        // 4. everything else
                
        if pieces.count == 2 {
            // the last piece has priority over the first piece
            pieces[0].priority = 0
            pieces[1].priority = 1
        } else if pieces.count > 2 {
            let firstIndex = 0
            let lastIndex = pieces.lastIndex!
            let penultimateIndex = lastIndex - 1
            
            pieces[lastIndex].priority = Double(pieces.count)
            pieces[penultimateIndex].priority = Double(pieces.count - 1)
            pieces[firstIndex].priority = Double(pieces.count - 2)
            
            let everythingElse = (firstIndex + 1) ..< penultimateIndex
            for idx in everythingElse { pieces[idx].priority = Double(pieces.count - 3) }
        }
        
        // easy sentinel to know whether we should include the ">" separator
        if let firstIndex = pieces.firstIndex {
            pieces[firstIndex].isFirst = true
        }
        if let lastIndex = pieces.lastIndex {
            pieces[lastIndex].isLast = true
        }
        return pieces
    }
    
    let path: ExtendedSwift.Path
    let displayName: String
    let image: NSImage
    fileprivate var priority: Double
    fileprivate var isFirst: Bool
    fileprivate var isLast: Bool
}

#endif

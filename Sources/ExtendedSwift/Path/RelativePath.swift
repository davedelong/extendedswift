//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

public struct RelativePath: PathProtocol {
    public let components: Array<PathComponent>
    
    public var fileSystemPath: String {
        return components.map(\.pathString).joined(separator: PathSeparator)
    }
    
    public init(path: String) {
        let pieces = (path as NSString).pathComponents
        self.init(pieces)
    }
    
    public init(_ pieces: String...) {
        let components = pieces.filter { $0 != PathSeparator }.map { PathComponent($0) }
        self.init(components)
    }
    
    public init(_ pieces: Array<String>) {
        let components = pieces.filter { $0 != PathSeparator }.map { PathComponent($0) }
        self.init(components)
    }
    
    public init(_ components: Array<PathComponent> = []) {
        self.init(components, shouldReduce: true)
    }
    
    public init(_ components: Array<PathComponent> = [], shouldReduce: Bool) {
        if shouldReduce {
            self.components = PathComponent.reduce(components, allowRelative: true)
        } else {
            self.components = components
        }
    }
    
    public func resolve(against: Path) -> Path {
        return Path(against.components + components)
    }
}

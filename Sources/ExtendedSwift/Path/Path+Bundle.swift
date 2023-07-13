//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

extension Bundle {
    
    public var path: Path { return Path(bundleURL) }
    
    public convenience init?(path: Path) {
        self.init(url: path.fileURL)
    }
    
    public func absolutePath(forResource name: String?, withExtension ext: String?) -> Path? {
        guard let url = self.url(forResource: name, withExtension: ext) else { return nil }
        return Path(url)
    }
    
    public func absolutePath(forResource name: String?, withExtension ext: String?, subdirectory subpath: String?) -> Path? {
        guard let url = self.url(forResource: name, withExtension: ext, subdirectory: subpath) else { return nil }
        return Path(url)
    }
    
    public func absolutePath(forResource name: String?, withExtension ext: String?, subdirectory subpath: String?, localization localizationName: String?) -> Path? {
        guard let url = self.url(forResource: name, withExtension: ext, subdirectory: subpath, localization: localizationName) else { return nil }
        return Path(url)
    }
    
    public func absolutePaths(forResourcesWithExtension ext: String?, subdirectory subpath: String?) -> Array<Path>? {
        guard let urls = self.urls(forResourcesWithExtension: ext, subdirectory: subpath) else { return nil }
        return urls.map { Path($0) }
    }
    
    public func absolutePaths(forResourcesWithExtension ext: String?, subdirectory subpath: String?, localization localizationName: String?) -> Array<Path>? {
        guard let urls = self.urls(forResourcesWithExtension: ext, subdirectory: subpath, localization: localizationName) else { return nil }
        return urls.map { Path($0) }
    }
}

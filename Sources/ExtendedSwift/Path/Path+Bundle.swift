//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

extension Bundle {
    
    public var path: AbsolutePath { return AbsolutePath(bundleURL) }
    
    public convenience init?(path: AbsolutePath) {
        self.init(url: path.fileURL)
    }
    
    public func absolutePath(forResource name: String?, withExtension ext: String?) -> AbsolutePath? {
        guard let url = self.url(forResource: name, withExtension: ext) else { return nil }
        return AbsolutePath(url)
    }
    
    public func absolutePath(forResource name: String?, withExtension ext: String?, subdirectory subpath: String?) -> AbsolutePath? {
        guard let url = self.url(forResource: name, withExtension: ext, subdirectory: subpath) else { return nil }
        return AbsolutePath(url)
    }
    
    public func absolutePath(forResource name: String?, withExtension ext: String?, subdirectory subpath: String?, localization localizationName: String?) -> AbsolutePath? {
        guard let url = self.url(forResource: name, withExtension: ext, subdirectory: subpath, localization: localizationName) else { return nil }
        return AbsolutePath(url)
    }
    
    public func absolutePaths(forResourcesWithExtension ext: String?, subdirectory subpath: String?) -> Array<AbsolutePath>? {
        guard let urls = self.urls(forResourcesWithExtension: ext, subdirectory: subpath) else { return nil }
        return urls.map { AbsolutePath($0) }
    }
    
    public func absolutePaths(forResourcesWithExtension ext: String?, subdirectory subpath: String?, localization localizationName: String?) -> Array<AbsolutePath>? {
        guard let urls = self.urls(forResourcesWithExtension: ext, subdirectory: subpath, localization: localizationName) else { return nil }
        return urls.map { AbsolutePath($0) }
    }
}

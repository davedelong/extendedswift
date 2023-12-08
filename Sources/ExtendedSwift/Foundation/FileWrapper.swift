//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/7/23.
//

import Foundation
import UniformTypeIdentifiers

extension FileWrapper {
    
    public var contentsURL: URL? {
        guard let anyValue = self.value(forKey: "_contentsURL") else { return nil }
        return anyValue as? URL
    }
    
    public var fileType: UTType? {
        guard let anyValue = self.value(forKey: "_fileType") else { return nil }
        guard let idString = anyValue as? String else { return nil }
        return UTType(idString)
    }
    
}

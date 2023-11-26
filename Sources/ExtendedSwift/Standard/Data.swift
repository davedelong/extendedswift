//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/17/23.
//

import Foundation

extension Data {
    
    public var hexDescription: String {
        return self.map { String(format: "%02X", $0) }.joined()
    }
    
}

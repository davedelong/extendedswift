//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/29/23.
//

import Foundation

extension UUID {
    
    public static var timestampedUUID: Self { NSUUID.extended_timed() as UUID }
    
}

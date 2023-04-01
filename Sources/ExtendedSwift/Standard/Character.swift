//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Character {
    
    public var isASCIIDigit: Bool {
        return isASCII && isWholeNumber
    }
    
}

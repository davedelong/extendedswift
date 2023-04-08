//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/7/23.
//

import Foundation

extension Encoder {
    
    public func anyKeyedContainer() -> KeyedEncodingContainer<AnyCodingKey> {
        self.container(keyedBy: AnyCodingKey.self)
    }
    
}

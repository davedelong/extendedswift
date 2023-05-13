//
//  File.swift
//  
//
//  Created by Dave DeLong on 5/13/23.
//

import Foundation

extension DecodingError {
    
    public var context: DecodingError.Context? {
        switch self {
            case .typeMismatch(_, let ctx):
                return ctx
            case .valueNotFound(_, let ctx):
                return ctx
            case .keyNotFound(_, let ctx):
                return ctx
            case .dataCorrupted(let ctx):
                return ctx
            @unknown default:
                return nil
        }
    }
    
    public var codingPath: [CodingKey] {
        return self.context?.codingPath ?? []
    }
    
    public var codingPathDescription: String? {
        return self.context?.codingPathDescription
    }
    
}

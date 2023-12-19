//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/19/23.
//

import Foundation
import Combine

extension Subscriber {
    
    public func receive(_ result: Result<Input, Failure>) -> Subscribers.Demand {
        switch result {
            case .success(let input):
                return self.receive(input)
            case .failure(let failure):
                self.receive(completion: .failure(failure))
                return .none
        }
    }
    
}

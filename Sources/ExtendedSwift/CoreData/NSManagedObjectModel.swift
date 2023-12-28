//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/26/23.
//

import Foundation
import CoreData

extension NSManagedObjectModel {
    
    public convenience init(@ArrayBuilder<NSEntityDescription> entities: () -> Array<NSEntityDescription>) {
        self.init()
        self.entities = entities()
    }
    
}

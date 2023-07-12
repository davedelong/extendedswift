//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/10/23.
//

import Foundation
import CoreData

internal class ReadOnlyManagedObjectContext: NSManagedObjectContext {
    
    override func save() throws {
        throw CocoaError(.persistentStoreSave, userInfo: [
            NSLocalizedDescriptionKey: "This context is read-only"
        ])
    }
    
}

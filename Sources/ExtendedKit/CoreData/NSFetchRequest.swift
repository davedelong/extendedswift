//
//  File.swift
//  
//
//  Created by Dave DeLong on 7/9/23.
//

import Foundation
import CoreData

extension NSFetchRequest {
    
    @objc internal func update(toMatch other: NSFetchRequest<ResultType>) {
        
        self.update(\.predicate, to: other.predicate)
        self.update(\.sortDescriptors, to: other.sortDescriptors)
        self.update(\.fetchLimit, to: other.fetchLimit)
        self.update(\.affectedStores, to: other.affectedStores)
        self.update(\.includesSubentities, to: other.includesSubentities)
        
        self.update(\.includesPropertyValues, to: other.includesPropertyValues)
        self.update(\.returnsObjectsAsFaults, to: other.returnsObjectsAsFaults)
        self.update(\.relationshipKeyPathsForPrefetching, to: other.relationshipKeyPathsForPrefetching)
        self.update(\.includesPendingChanges, to: other.includesPendingChanges)
        self.update(\.returnsDistinctResults, to: other.returnsDistinctResults)
        
        self.update(\.fetchOffset, to: other.fetchOffset)
        self.update(\.fetchBatchSize, to: other.fetchBatchSize)
        self.update(\.shouldRefreshRefetchedObjects, to: other.shouldRefreshRefetchedObjects)
        
        self.update(\.havingPredicate, to: other.havingPredicate)
        
        // these are Array<Any> values and are not equatable
        self.propertiesToFetch = other.propertiesToFetch
        self.propertiesToGroupBy = other.propertiesToGroupBy
    }
    
}

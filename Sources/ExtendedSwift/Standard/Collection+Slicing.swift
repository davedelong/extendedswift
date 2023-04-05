//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension Collection {
    
    /// Slice a collection into multiple sub-collections
    ///
    /// Example: given `[0, 1, 2, 3, 4, 5]` and the indices `[1, 3]`, this returns
    /// `[[1, 2], [3, 4, 5]]`
    ///
    /// - Parameter indices: The indices where slices should begin
    /// - Returns: An array of subsequences
    public func slices(startingAt indices: Array<Index>) -> Array<SubSequence> {
        if indices.isEmpty { return [] }
        
        let starts = indices
        let ends = indices.dropFirst() + [self.endIndex]
        
        return zip(starts, ends).map {
            self[$0 ..< $1]
        }
    }
    
    /// Extract all contiguous subsequences whose elements match a predicate
    ///
    /// Example: given `"a1b2c34"` and the predicate `\.isDigit`, this returns
    /// `["1", "2", "34"]`
    ///
    /// - Parameter matches: The predicate to identify elements
    /// - Returns: An array of subsequences
    public func slices(where matches: (Element) -> Bool) -> Array<SubSequence> {
        guard isEmpty == false else { return [] }
        
        var final = Array<SubSequence>()
        
        var start = startIndex
        var current = start
        
        var currentSubSequenceMatches = matches(self[current])
        current = index(after: current)
        
        while current < endIndex {
            let thisMatches = matches(self[current])
            
            if thisMatches != currentSubSequenceMatches {
                final.append(self[start ..< current])
                start = current
                currentSubSequenceMatches = thisMatches
            }
            
            current = index(after: current)
        }
        
        if start < endIndex {
            final.append(self[start ..< endIndex])
        }
        
        return final
    }
    
    public func split(includingBoundary: Bool = false, onBoundary: (Element) -> Bool) -> Array<SubSequence> {
        var final = Array<SubSequence>()
        
        var start = self.startIndex
        var current = self.index(after: start)
        
        while current < self.endIndex {
            
            if onBoundary(self[current]) {
                final.append(self[start ..< current])
                
                if includingBoundary == false {
                    current = self.index(after: current)
                }
                
                start = current
            }
            
            if current < self.endIndex {
                current = self.index(after: current)
            }
        }
        
        if start < self.endIndex {
            final.append(self[start ..< current])
        }
        
        return final
    }
    
}

extension Collection where Element: Equatable {
    
    /// Locates all the places a slice occurs within a collection
    ///
    /// - Parameter slice: The collection of elements to locate within the receiver
    /// - Returns: The array of indices where the slice begins. Will be empty if `slice` does not occur in the collection.
    public func indices(of slice: some RandomAccessCollection<Element>) -> Array<Index> {
        var starts = Array<Index>()
        
        var mostRecentSliceStart: Index? = nil
        var sliceIndex = slice.startIndex
        
        for (index, element) in zip(indices, self) {
            if element == slice[sliceIndex] {
                slice.formIndex(after: &sliceIndex)
                if mostRecentSliceStart == nil { mostRecentSliceStart = index }
                
                if sliceIndex >= slice.endIndex {
                    sliceIndex = slice.startIndex
                    starts.append(mostRecentSliceStart!)
                    mostRecentSliceStart = nil
                }
            } else {
                sliceIndex = slice.startIndex
                mostRecentSliceStart = nil
            }
        }
        
        return starts
    }
    
}

//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/4/23.
//

import Foundation

extension Calendar {
    
    public func startOfNext(_ unit: Calendar.Component, after start: Date) -> Date {
        let range = self.range(of: unit, containing: start)
        return range.upperBound
    }
    
    public func next(_ unit: Calendar.Component, onOrAfter start: Date, where matches: (DateComponents) -> Bool) -> Date {
        var next = start
        
        while true {
            let components = self.dateComponents(in: self.timeZone, from: next)
            if matches(components) { return next }
            next = startOfNext(unit, after: next)
        }
    }
    
    public func range(of unit: Calendar.Component, containing date: Date) -> Range<Date> {
        if unit == .timeZone { fatalError("Asking for the timezone range is invalid") }
        if unit == .calendar { fatalError("Asking for the calendar range is invalid") }
        let dateInterval = self.dateInterval(of: unit, for: date) !! "This should always work"
        return dateInterval.start ..< dateInterval.end
    }
    
}

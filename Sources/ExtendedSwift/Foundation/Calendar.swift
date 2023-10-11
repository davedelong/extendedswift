//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/4/23.
//

import Foundation

public struct CalendarError: Error, CustomStringConvertible {
    
    public enum Code: Int {
        case invalidComponent
        case cannotOffset
        case cannotDetermineRange
    }
    
    public static func invalidComponent(_ component: Calendar.Component) -> CalendarError {
        return .init(code: .invalidComponent, description: ".\(component.caseName) is invalid in this context")
    }
    
    public static func cannotOffset(date: Date, by unit: Calendar.Component, value: Int) -> CalendarError {
        return .init(code: .cannotOffset, description: "Cannot offset \(date) by \(value) \(unit.caseName)")
    }
    
    public static func cannotDetermineRange(of unit: Calendar.Component, containing date: Date) -> CalendarError {
        return .init(code: .cannotDetermineRange, description: "Cannot determine range of \(unit.caseName) containing \(date)")
    }
    
    public let code: Code
    public let description: String
    
}

extension Calendar.Component {
    
    public var caseName: String {
        switch self {
            case .era: return "era"
            case .year: return "year"
            case .month: return "month"
            case .day: return "day"
            case .hour: return "hour"
            case .minute: return "minute"
            case .second: return "second"
            case .weekday: return "weekday"
            case .weekdayOrdinal: return "weekdayOrdinal"
            case .quarter: return "quarter"
            case .weekOfMonth: return "weekOfMonth"
            case .weekOfYear: return "weekOfYear"
            case .yearForWeekOfYear: return "yearForWeekOfYear"
            case .nanosecond: return "nanosecond"
            case .calendar: return "calendar"
            case .timeZone: return "timeZone"
            // for some reason, uncommenting this causes linking failures
//            case .isLeapMonth: return "isLeapMonth"
            @unknown default: return "unknown(\(self))"
        }
    }
    
    public func assertValidComponentForCalculations() throws {
        if self == .timeZone { throw CalendarError.invalidComponent(self) }
        if self == .calendar { throw CalendarError.invalidComponent(self) }
        // for some reason, uncommenting this causes linking failures
//        if self == .isLeapMonth { throw CalendarError.invalidComponent(self) }
    }
    
}

extension Calendar {
    
    // Base Functions:
    // These methods are built solely on Calendar-provided methods
    
    public func dateComponents(for date: Date) -> DateComponents {
        return self.dateComponents(in: self.timeZone, from: date)
    }
    
    public func range(of unit: Calendar.Component, containing date: Date) throws -> Range<Date> {
        try unit.assertValidComponentForCalculations()
        guard let interval = self.dateInterval(of: unit, for: date) else {
            throw CalendarError.cannotDetermineRange(of: unit, containing: date)
        }
        return interval.start ..< interval.end
    }
    
    // Added Functions:
    // These methods are built using custom logic and a mix of custom and Calendar-provided methods
    
    public func startOfPrevious(_ unit: Calendar.Component, before start: Date) throws -> Date {
        let range = try self.range(of: unit, containing: start)
        let startOfCurrent = range.lowerBound
        guard let startOfPrevious = self.date(byAdding: unit, value: -1, to: startOfCurrent) else {
            throw CalendarError.cannotOffset(date: startOfCurrent, by: unit, value: -1)
        }
        return startOfPrevious
    }
    
    public func startOfNext(_ unit: Calendar.Component, after start: Date) throws -> Date {
        let range = try self.range(of: unit, containing: start)
        return range.upperBound
    }
    
    public func previous(_ unit: Calendar.Component, onOrBefore start: Date, where matches: (DateComponents) -> Bool) throws -> Date {
        var next = start
        
        while true {
            let components = self.dateComponents(for: next)
            if matches(components) { return next }
            next = try startOfPrevious(unit, before: next)
        }
    }
    
    public func next(_ unit: Calendar.Component, onOrAfter start: Date, where matches: (DateComponents) -> Bool) throws -> Date {
        var next = start
        
        while true {
            let components = self.dateComponents(for: next)
            if matches(components) { return next }
            next = try startOfNext(unit, after: next)
        }
    }
    
}

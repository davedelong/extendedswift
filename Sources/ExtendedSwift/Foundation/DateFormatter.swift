//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

extension DateFormatter {
    public convenience init(dateStyle: Style) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = .none
    }
    
    public convenience init(timeStyle: Style) {
        self.init()
        self.dateStyle = .none
        self.timeStyle = timeStyle
    }
    
    public convenience init(dateStyle: Style, timeStyle: Style) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
    }
}

public class UnlocalizedDateFormatter: DateFormatter {
    
    private let df: DateFormatter
    
    /// Instantiate a new unlocalized date formatter
    /// - Parameters:
    ///   - dateFormat: The date format to be used for formatting
    ///   - calendar: The calendar to be used for formatting. If `nil`, the current calendar will be used
    ///   - locale: The locale to be used for formatting. If `nil`, the calendar's locale will be used, falling back to the current locale
    ///   - timeZone: The timezone to be used for formatting. If `nil`, the current timezone will be used
    public init(dateFormat: String, calendar: Calendar? = nil, locale: Locale? = nil, timeZone: TimeZone? = nil) {
        let key = CacheKey(format: dateFormat,
                           calendar: calendar ?? .current,
                           locale: locale ?? calendar?.locale ?? .current,
                           timeZone: timeZone ?? .current)
        
        cacheLock.lock()
        
        if let existing = cachedFormatters[key] {
            self.df = existing
        } else {
            let new = DateFormatter()
            new.calendar = key.calendar
            new.locale = key.locale
            new.timeZone = key.timeZone
            new.dateFormat = dateFormat
            
            cachedFormatters[key] = new
            self.df = new
        }
        
        cacheLock.unlock()
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func string(from date: Date) -> String { df.string(from: date) }
    public override func date(from string: String) -> Date? { df.date(from: string) }
    
}

private var cacheLock = NSLock()
private var cachedFormatters = Dictionary<CacheKey, DateFormatter>()

private struct CacheKey: Hashable {
    let format: String
    let calendar: Calendar
    let locale: Locale
    let timeZone: TimeZone
}

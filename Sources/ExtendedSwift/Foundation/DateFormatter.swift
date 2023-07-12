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
    
    /// Instantiate a new unlocalized date formatter
    /// - Parameters:
    ///   - dateFormat: The date format to be used for formatting
    ///   - calendar: The calendar to be used for formatting. If `nil`, the current calendar will be used
    ///   - locale: The locale to be used for formatting. If `nil`, the calendar's locale will be used, falling back to the current locale
    ///   - timeZone: The timezone to be used for formatting. If `nil`, the current timezone will be used
    public init(dateFormat: String, calendar: Calendar? = nil, locale: Locale? = nil, timeZone: TimeZone? = nil) {
        super.init()
        super.dateFormat = dateFormat
        super.calendar = calendar ?? .current
        super.locale = locale ?? .current
        super.timeZone = timeZone ?? .current
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var calendar: Calendar! {
        get { super.calendar }
        set { }
    }
    
    public override var timeZone: TimeZone! {
        get { super.timeZone }
        set { }
    }
    
    public override var locale: Locale! {
        get { super.locale }
        set { }
    }
    
    public override var dateStyle: DateFormatter.Style {
        get { super.dateStyle }
        set { }
    }
    
    public override var timeStyle: DateFormatter.Style {
        get { super.timeStyle }
        set { }
    }
    
    public override var dateFormat: String! {
        get { super.dateFormat }
        set { }
    }
    
}

public class POSIXDateFormatter: UnlocalizedDateFormatter {
    
    public init(dateFormat: String) {
        super.init(dateFormat: dateFormat,
                   calendar: Calendar(identifier: .gregorian),
                   locale: Locale(identifier: "en_US_POSIX"),
                   timeZone: TimeZone(secondsFromGMT: 0))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

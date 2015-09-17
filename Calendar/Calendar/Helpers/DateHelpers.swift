//
//  DateHelpers.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

public enum Month: Int {
    case January = 1
    case February = 2
    case March = 3
    case April = 4
    case May = 5
    case June = 6
    case July = 7
    case August = 8
    case September = 9
    case October = 10
    case November = 11
    case December = 12
    
    var daysPerMonth: Int {
        get {
            switch self {
            case .January:
                return 31
            case .February:
                return 29
            case .March:
                return 31
            case .April:
                return 30
            case .May:
                return 31
            case .June:
                return 30
            case .July:
                return 31
            case .August:
                return 31
            case .September:
                return 30
            case .October:
                return 31
            case .November:
                return 30
            case .December:
                return 31
            }
        }
    }
}

public enum Weekday: Int {
    case Sunday = 1
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
    case Saturday = 7
}

public class DateHelpers: NSObject {
    static func dayOfMonthForDate(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = NSCalendarUnit.Day
        return calendar.component(components, fromDate: date)
    }
    
    static func isDate(date: NSDate, sameDayAs otherDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let dayComponent = NSCalendarUnit.Day
        return calendar.component(dayComponent, fromDate: date) == calendar.component(dayComponent, fromDate: otherDate)
    }
    
    static func dayOfWeekForDate(date: NSDate) -> Weekday {
        let weekdayInt = NSCalendar.currentCalendar().component(NSCalendarUnit.Weekday, fromDate: date)
        return Weekday(rawValue: weekdayInt)!
    }
}

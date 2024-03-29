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
    
    var description: String {
        get {
            switch self {
            case .January:
                return "January"
            case .February:
                return "February"
            case .March:
                return "March"
            case .April:
                return "April"
            case .May:
                return "May"
            case .June:
                return "June"
            case .July:
                return "July"
            case .August:
                return "August"
            case .September:
                return "September"
            case .October:
                return "October"
            case .November:
                return "November"
            case .December:
                return "December"
            }
        }
    }
    
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
    
    var description: String {
        get {
            switch self {
            case .Sunday:
                return "Sunday"
            case .Monday:
                return "Monday"
            case .Tuesday:
                return "Tuesday"
            case .Wednesday:
                return "Wednesday"
            case .Thursday:
                return "Thursday"
            case .Friday:
                return "Friday"
            case .Saturday:
                return "Saturday"
            }
        }
    }
    
    var shortDescription: String {
        get {
            switch self {
            case .Sunday:
                return "SUN"
            case .Monday:
                return "MON"
            case .Tuesday:
                return "TUE"
            case .Wednesday:
                return "WED"
            case .Thursday:
                return "THU"
            case .Friday:
                return "FRI"
            case .Saturday:
                return "SAT"
            }
        }
    }
    
    static let allDays: [Weekday] = [.Sunday, .Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday]
}

public class DateHelpers: NSObject {
    static func dayOfMonthForDate(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = NSCalendarUnit.Day
        return calendar.component(components, fromDate: date)
    }
    
    static public func isDate(date: NSDate, sameDayAs otherDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let firstDateComponents = calendar.components(unitFlags, fromDate: date)
        let secondDateComponent = calendar.components(unitFlags, fromDate: otherDate)
        return firstDateComponents == secondDateComponent
    }
    
    static public func isDate(date: NSDate, beforeDayOfDate otherDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let firstDateComponents = calendar.components(unitFlags, fromDate: date)
        let secondDateComponent = calendar.components(unitFlags, fromDate: otherDate)
        
        if firstDateComponents.year < secondDateComponent.year {
            return true
        }
        
        if firstDateComponents.year > secondDateComponent.year {
            return false
        }
        
        //Same Year
        if firstDateComponents.month < secondDateComponent.month {
            return true
        }
        
        if firstDateComponents.month > secondDateComponent.month {
            return false
        }
        
        //Same Month
        if firstDateComponents.day < secondDateComponent.day {
            return true
        }
        
        //If same month, same year and day is same or greater
        return false
    }
    
    static func dayOfWeekForDate(date: NSDate) -> Weekday {
        let weekdayInt = NSCalendar.currentCalendar().component(NSCalendarUnit.Weekday, fromDate: date)
        return Weekday(rawValue: weekdayInt)!
    }
    
    public static func dateForDayMonthYear(day: Int, month: Int, year: Int) -> NSDate? {
        let components = NSDateComponents()
        components.day = day
        components.second = 0
        components.minute = 0
        components.hour = 1
        components.month = month
        components.year = year
        return NSCalendar.currentCalendar().dateFromComponents(components)
    }
    
    public static func monthForDate(date: NSDate) -> Month {
        let monthInt = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: date)
        return Month(rawValue: monthInt)!
    }
    
    public static func yearForDate(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: date)
    }
    
    static func previousMonthStartDate(startDate: NSDate) -> NSDate {
        let month = DateHelpers.monthForDate(startDate)
        var year = DateHelpers.yearForDate(startDate)
        var previousMonth = Month.January
        
        switch month {
            case .January:
                previousMonth = .December
                year -= 1
            default:
                previousMonth = Month(rawValue:month.rawValue - 1)!
        }
        
        return DateHelpers.dateForDayMonthYear(1, month: previousMonth.rawValue, year: year)!
    }
    
    static func nextMonthStartDate(startDate: NSDate) -> NSDate {
        let month = DateHelpers.monthForDate(startDate)
        var year = DateHelpers.yearForDate(startDate)
        var nextMonth = Month.January
        
        switch month {
        case .December:
            nextMonth = .January
            year += 1
        default:
            nextMonth = Month(rawValue:month.rawValue + 1)!
        }
        
        return DateHelpers.dateForDayMonthYear(1, month: nextMonth.rawValue, year: year)!
    }
    
    static func visibleWeeksForMonth(date: NSDate) -> Int {
        let dayOfWeek = DateHelpers.dayOfWeekForDate(date).rawValue
        let offsetDaysPerMonth = DateHelpers.monthForDate(date).daysPerMonth + dayOfWeek - 2
        let weeks = Int(ceil(Double(offsetDaysPerMonth) / 7.0))
        return weeks
    }
}

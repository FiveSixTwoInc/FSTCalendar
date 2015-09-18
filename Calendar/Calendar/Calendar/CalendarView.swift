//
//  CalendarView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

public class CalendarView: UIScrollView {
    
    var weekViews = [CalendarWeekView]()
    
    var startDate = NSDate()
    var endDate = NSDate()
    var month = Month.January
    var year = 1989
    
    var dayViewSeparation = 5.0
    
    //MARK: - Lifecycle
    override public func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview != nil {
            self.contentSize = self.bounds.size
        }
    }
    
    //MARK: - Setup
    public func setup(month: Month) {
        self.month = month
        self.year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: NSDate())
        self.startDate = DateHelpers.dateForDayMonthYear(1, month: month.rawValue, year: year) ?? NSDate()
        self.endDate = DateHelpers.dateForDayMonthYear(month.daysPerMonth, month: month.rawValue, year: year) ?? NSDate()
        self.layoutWeekViews()
    }
    
    //MARK: - Helpers
    private func layoutWeekViews() {
        for weekView in self.weekViews {
            weekView.removeFromSuperview()
        }
        
        self.weekViews = [CalendarWeekView]()
        
        let weeks = Int(ceil(Double(self.month.daysPerMonth) / 7.0))
        
        var startDay = 1
        var startDate = DateHelpers.dateForDayMonthYear(startDay, month: self.month.rawValue, year: self.year)!
        
        var dayOfWeek = DateHelpers.dayOfWeekForDate(startDate).rawValue
        var daysInWeek = 7 - dayOfWeek
        
        var endDay = startDay + daysInWeek

        for index in 1 ... weeks {
            var datesForWeek = [NSDate]()
            
            for dayIndex in startDay ... endDay {
                if let date = DateHelpers.dateForDayMonthYear(dayIndex, month: month.rawValue, year: self.year) {
                    datesForWeek.append(date)
                }
            }
            self.addWeekView(index, withDates: datesForWeek)
            
            startDay = endDay + 1
            startDate = DateHelpers.dateForDayMonthYear(startDay, month: self.month.rawValue, year: self.year)!
            
            dayOfWeek = DateHelpers.dayOfWeekForDate(startDate).rawValue
            daysInWeek = 7 - dayOfWeek
            
            endDay = min(startDay + daysInWeek, self.month.daysPerMonth)
        }
    }
    
    private func addWeekView(weekNumber: Int, withDates dates: [NSDate]) {
        let y = Double((weekNumber - 1) * 65)
        let frame = CGRect(x: 0.0, y: y, width: Double(self.bounds.width), height: 65.0)
        let weekView = CalendarWeekView(frame: frame)
        self.addSubview(weekView)
        weekView.setup(dates)
        self.weekViews.append(weekView)
    }
}

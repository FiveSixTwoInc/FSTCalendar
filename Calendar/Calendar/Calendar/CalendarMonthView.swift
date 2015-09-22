//
//  CalendarMonthView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

public class CalendarMonthView: UIView {
    
    var weekViews = [CalendarWeekView]()
    
    var startDate = NSDate()
    var endDate = NSDate()
    var month = Month.January
    var year = 1989
    
    var dayViewSeparation = 5.0
    var dayViewWidth = 50.0
    
    //MARK: - Setup
    public func setup(month: Month, year: Int) {
        let startDate = DateHelpers.dateForDayMonthYear(1, month: month.rawValue, year: year) ?? NSDate()
        self.setupWithStartDate(startDate)
    }
    
    public func setupWithStartDate(startDate: NSDate) {
        self.month = DateHelpers.monthForDate(startDate)
        self.year = DateHelpers.yearForDate(startDate)
        self.startDate = startDate
        self.endDate = DateHelpers.dateForDayMonthYear(month.daysPerMonth, month: month.rawValue, year: year) ?? NSDate()
        self.setupLayout()
        self.layoutWeekViews()
    }
    
    public func setupLayout() {
        let numberOfHorizontalSeparators = 8.0
        let numberOfVerticalSeparators = Double(DateHelpers.visibleWeeksForMonth(self.startDate)) + 1.0
        let dayViewWidth = (Double(self.bounds.width) - (numberOfHorizontalSeparators * self.dayViewSeparation))/7.0
        self.dayViewWidth = dayViewWidth
        
        let height = numberOfVerticalSeparators * self.dayViewSeparation + (6 * self.dayViewWidth)
        self.frame = CGRect(x: Double(self.frame.origin.x), y: Double(self.frame.origin.y), width: Double(self.bounds.width), height: height)
    }
        
    //MARK: - Helpers
    private func layoutWeekViews() {
        for weekView in self.weekViews {
            weekView.removeFromSuperview()
        }
        
        self.weekViews = [CalendarWeekView]()
        
        var startDay = 1
        var startDate = DateHelpers.dateForDayMonthYear(startDay, month: self.month.rawValue, year: self.year)!
        
        var dayOfWeek = DateHelpers.dayOfWeekForDate(startDate).rawValue
        
        let offsetDaysPerMonth = self.month.daysPerMonth + dayOfWeek - 2
        
        let weeks = Int(ceil(Double(offsetDaysPerMonth) / 7.0))

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
        let y = Double(weekNumber) * 5.0 + (Double(weekNumber - 1) * self.dayViewWidth)
        let frame = CGRect(x: 0.0, y: y, width: Double(self.bounds.width), height: self.dayViewWidth)
        let weekView = CalendarWeekView(frame: frame)
        weekView.dayViewSeparation = self.dayViewSeparation
        weekView.dayViewWidth = self.dayViewWidth
        self.addSubview(weekView)
        weekView.setup(dates)
        self.weekViews.append(weekView)
    }
}

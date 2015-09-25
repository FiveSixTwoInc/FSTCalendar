//
//  CalendarMonthView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

@objc protocol CalendarMonthViewDelegate: class {
    func calendarMonthView(monthView: CalendarMonthView, selectedDay dayView: CalendarDayView)
    optional func calendarMonthView(monthView: CalendarMonthView, laidOut dayView: CalendarDayView)
}

public class CalendarMonthView: UIView, CalendarDayViewDelegate, CalendarWeekViewDelegate {
    private var weekDayView: CalendarWeekdayView!
    
    weak var delegate: CalendarMonthViewDelegate?
    
    var weekViews = [CalendarWeekView]()
    
    public var startDate: NSDate {
        get {
            return self.p_startDate
        }
        set (date) {
            self.p_startDate = date
            self.p_month = DateHelpers.monthForDate(date)
            self.p_year = DateHelpers.yearForDate(date)
        }
    }
    private var p_startDate = NSDate()

    public var endDate: NSDate {
        get {
            return self.p_endDate
        }
        set (date) {
            self.p_endDate = date
        }
    }
    private var p_endDate = NSDate()
    
    public var month: Month {
        get {
            return self.p_month
        }
    }
    private var p_month = Month.January
    
    public var year: Int {
        get {
            return self.p_year
        }
    }
    private var p_year = 1989
    
    var dayViewHorizontalSeparation = 5.0
    var dayViewVerticalSeparation = 5.0
    var dayViewDimension = 50.0
    
    //MARK: - Public
    public func setupWithStartDate(startDate: NSDate) {
        self.setupWeekdayView()
        self.startDate = startDate
        self.endDate = DateHelpers.dateForDayMonthYear(month.daysPerMonth, month: month.rawValue, year: year) ?? NSDate()
        self.layoutWeekViews()
    }
    
    public func reloadData() {
        for weekView in self.weekViews {
            weekView.reloadData()
        }
    }
    
    //MARK: - Helpers
    private func setupWeekdayView() {
        let weekdayFrame = CGRect(x: 0.0, y: 0.0, width: Double(self.bounds.width), height: 50.0)
        let weekdayView = CalendarWeekdayView(frame: weekdayFrame)
        self.addSubview(weekdayView)
    }
    
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
        let y = Double(weekNumber) * self.dayViewVerticalSeparation + (Double(weekNumber - 1) * self.dayViewDimension) + self.dayViewDimension
        let frame = CGRect(x: 0.0, y: y, width: Double(self.bounds.width), height: self.dayViewDimension)
        let weekView = CalendarWeekView(frame: frame)
        weekView.dayViewHorizontalSeparation = self.dayViewHorizontalSeparation
        weekView.dayViewDimension = self.dayViewDimension
        weekView.delegate = self
        self.addSubview(weekView)
        weekView.setup(dates)
        weekView.dayViews.forEach{$0.delegate = self}
        self.weekViews.append(weekView)
    }
    
    //MARK: - CalendarDayViewDelegate
    public func calendarDayViewWasSelected(dayView: CalendarDayView) {
        self.delegate?.calendarMonthView(self, selectedDay: dayView)
    }
    
    //MARK: - CalendarWeekViewDelegate
    public func calendarWeekView(weekView: CalendarWeekView, isLayingOut dayView: CalendarDayView) {
        self.delegate?.calendarMonthView?(self, laidOut: dayView)
    }
}

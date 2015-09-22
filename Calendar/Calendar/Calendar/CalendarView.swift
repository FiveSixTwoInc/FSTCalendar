//
//  CalendarView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

public class CalendarView: UIScrollView, UIScrollViewDelegate {
    
    var visibleMonthView: CalendarMonthView?
    private var loadedMonthViews = [CalendarMonthView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    public func setup(startDate: NSDate) {
        for monthView in self.loadedMonthViews {
            monthView.removeFromSuperview()
        }
        var y: CGFloat = 0.0
        
        let previousMonthStartDate = DateHelpers.previousMonthStartDate(startDate)
        let nextMonthStartDate = DateHelpers.nextMonthStartDate(startDate)
        
        let previousMonthCalendarView = CalendarMonthView(frame: self.bounds)
        previousMonthCalendarView.setupWithStartDate(previousMonthStartDate)
        y += previousMonthCalendarView.bounds.height
        self.addSubview(previousMonthCalendarView)
        
        let currentMonthCalendarView = CalendarMonthView(frame: self.bounds)
        currentMonthCalendarView.frame.origin.y = y
        currentMonthCalendarView.setupWithStartDate(startDate)
        y += currentMonthCalendarView.bounds.height
        self.addSubview(currentMonthCalendarView)
        
        let nextMonthCalendarView = CalendarMonthView(frame: self.bounds)
        nextMonthCalendarView.frame.origin.y = y
        y += nextMonthCalendarView.bounds.height
        nextMonthCalendarView.setupWithStartDate(nextMonthStartDate)
        self.addSubview(nextMonthCalendarView)
        
        self.loadedMonthViews.append(previousMonthCalendarView)
        self.loadedMonthViews.append(currentMonthCalendarView)
        self.loadedMonthViews.append(nextMonthCalendarView)
    
        self.contentSize = CGSize(width: self.bounds.width, height: y)
        self.contentOffset = CGPointMake(0.0, self.bounds.height)
    }

}

//
//  CalendarWeekView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

@objc protocol CalendarWeekViewDelegate: class {
    optional func calendarWeekView(weekView: CalendarWeekView, isLayingOut dayView: CalendarDayView)
}

public class CalendarWeekView: UIView {
    weak var delegate: CalendarWeekViewDelegate?
    
    //MARK: - Visual Layout
    var dayViewHorizontalSeparation = 5.0
    var dayViewDimension = 50.0
    
    //MARK: - State
    var dayViews = [CalendarDayView]()
    var startDate = NSDate()
    var dates = [NSDate]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Setup
    func setup(dates: [NSDate]) {
        self.dates = dates
        self.setupDayViews()
    }
    
    private func setupDayViews() {
        for date in self.dates {
            let dayOfWeek = DateHelpers.dayOfWeekForDate(date)
            
            let x = (Double(dayOfWeek.rawValue) * self.dayViewHorizontalSeparation) + (Double((dayOfWeek.rawValue - 1)) * self.dayViewDimension)
            
            let dayView = CalendarDayView(frame: CGRect(x: x, y: 0, width: self.dayViewDimension, height: self.dayViewDimension))
            dayView.setup(date)
            self.addSubview(dayView)
            self.dayViews.append(dayView)
            
            self.delegate?.calendarWeekView?(self, isLayingOut: dayView)
        }
    }
}

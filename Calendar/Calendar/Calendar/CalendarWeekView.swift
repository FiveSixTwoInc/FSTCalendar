//
//  CalendarWeekView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

public class CalendarWeekView: UIView {
    
    //MARK: - Visual Layout
    var dayViewSeparation = 5.0
    
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
            let dayOfMonth = DateHelpers.dayOfMonthForDate(date)
            
            let numberOfSeparators = 8.0
            let dayViewWidth = 50.0
            
            self.dayViewSeparation = (Double(self.bounds.width) - (7.0 * 65.0))/numberOfSeparators
            let x = (Double(dayOfWeek.rawValue) * self.dayViewSeparation) + (Double((dayOfWeek.rawValue - 1)) * dayViewWidth)
            
            let dayView = CalendarDayView(frame: CGRect(x: x, y: 0, width: dayViewWidth, height: dayViewWidth))
            dayView.setupWithDay(dayOfMonth)
            self.addSubview(dayView)
            self.dayViews.append(dayView)
            
            if DateHelpers.isDate(NSDate(), sameDayAs: date) {
                dayView.viewBackgroundCircle.backgroundColor = UIColor.blueColor()
            }
        }
    }
}

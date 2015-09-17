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
    
    //MARK: - Setup
    func setup(startDate: NSDate) {
        self.startDate = startDate
        self.layoutDayViews()
    }
    
    private func layoutDayViews() {
        let weekDay = DateHelpers.dayOfWeekForDate(self.startDate).rawValue

        let dayViewWidth = (Double(self.bounds.width) - (8.0 * self.dayViewSeparation)) / 7.0
        
        for dayView in self.dayViews {
            dayView.removeFromSuperview()
        }
        
        self.dayViews = [CalendarDayView]()
        
        for index in weekDay ... 7 {
            let x = (Double(index) * self.dayViewSeparation) + (Double((index)) * dayViewWidth)
            let dayView = CalendarDayView(frame: CGRect(x: x, y: 0, width: dayViewWidth, height: dayViewWidth))
            dayView.setupWithDay(index + 1)
            self.addSubview(dayView)
            self.dayViews.append(dayView)
        }
    }
}

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
    var month = Month.January
    
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
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = NSDateComponents()
        dateComponents.month = month.rawValue
        dateComponents.second = 0
        dateComponents.hour = 1
        dateComponents.minute = 0
        dateComponents.day = 5
        if let firstDate = calendar.dateFromComponents(dateComponents) {
            self.startDate = firstDate
        }
        self.layoutWeekViews()
    }
    
    //MARK: - Helpers
    private func layoutWeekViews() {
        for weekView in self.weekViews {
            weekView.removeFromSuperview()
        }
        
        self.weekViews = [CalendarWeekView]()
        
        let weekView = CalendarWeekView()
        weekView.setup(self.startDate)
        self.addSubview(weekView)
        self.weekViews.append(weekView)
    }
}

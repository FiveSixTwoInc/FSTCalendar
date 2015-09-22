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
        
        self.visibleMonthView = currentMonthCalendarView
        
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
    
    //MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        print("Content Offset: \(scrollView.contentOffset)")
        if let visibleMonthView = self.visibleMonthView, visibleIndex = self.loadedMonthViews.indexOf(visibleMonthView) {
            let contentOffset = self.contentOffset
            let originY = visibleMonthView.frame.origin.y
            
            if (visibleIndex + 1) < self.loadedMonthViews.count {
                let nextView = self.loadedMonthViews[visibleIndex + 1]
                
                if contentOffset.y > (originY + 0.50 * visibleMonthView.frame.height) {
                    self.visibleMonthView = nextView
                    print("Set To Snap To Next Month")
                    return
                }
            }
            
            if (visibleIndex - 1) >= 0 {
                let previousView = self.loadedMonthViews[visibleIndex - 1]
                if contentOffset.y < (originY - 0.50 * visibleMonthView.frame.height) {
                    print("Set To Snap To Previous Month")
                    self.visibleMonthView = previousView
                    return
                }
            }
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let visibleMonthView = self.visibleMonthView {
            self.snapToCalendarView(visibleMonthView)
        }
    }
    
    public func snapToCalendarView(view: CalendarMonthView) {
        self.setContentOffset(CGPointMake(0.0, view.frame.origin.y), animated: true)
    }
}

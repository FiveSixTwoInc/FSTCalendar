//
//  CalendarView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

@objc public protocol CalendarViewDelegate: class {
    func calendarView(calendarView: CalendarVerticalView, selectedDayView dayView: CalendarDayView)
    optional func calendarView(calendarView: CalendarVerticalView, laidOutDayView dayView: CalendarDayView)
}

public class CalendarVerticalView: UIScrollView, UIScrollViewDelegate, CalendarMonthViewDelegate {
    public weak var calendarDelegate: CalendarViewDelegate? {
        get {
            return self.p_calendarDelegate
        }
        set(delegate) {
            self.p_calendarDelegate = delegate
            if let visibleMonthView = self.visibleMonthView {
                self.setup(visibleMonthView.startDate)
            }
        }
    }
    
    private weak var p_calendarDelegate: CalendarViewDelegate?
    
    public var calendarTitleView: CalendarTitleView?
    
    //MARK: - Configuration
    public var dayViewDimension = 50.0
    public var verticalDaySeparation = 5.0
    public var horizontalDaySeparation = 5.0
    
    //MARK: - State
    private var loadedMonthViews = [CalendarMonthView]()
    
    public var visibleMonthView: CalendarMonthView? {
        get {
            return self.p_visibleMonthView
        }
    }
    
    private var p_visibleMonthView: CalendarMonthView?
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.defaultSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.defaultSetup()
    }
    
    //MARK: - Setup
    public func setup(month: Month, year: Int) {
        let startDate = DateHelpers.dateForDayMonthYear(1, month: month.rawValue, year: year)!
        self.setup(startDate)
    }
    
    public func setup(startDate: NSDate) {
        self.clearMonthViews()
        self.setupLayout()
        
        let monthStartDate = DateHelpers.dateForDayMonthYear(1, month: DateHelpers.monthForDate(startDate).rawValue, year: DateHelpers.yearForDate(startDate))!
        let previousMonthStartDate = DateHelpers.previousMonthStartDate(startDate)
        let nextMonthStartDate = DateHelpers.nextMonthStartDate(startDate)

        let dates = [previousMonthStartDate, monthStartDate, nextMonthStartDate]
        
        var y: CGFloat = 0.0

        for date in dates {
            let calendarMonthView = self.monthViewWithStartDate(date)
            calendarMonthView.frame.origin.y = y
            y += calendarMonthView.bounds.height
            self.addSubview(calendarMonthView)
            
            self.loadedMonthViews.append(calendarMonthView)
            if (date == monthStartDate) {
                self.p_visibleMonthView = calendarMonthView
            }
        }
        
        self.contentSize = CGSize(width: self.bounds.width, height: y)
        self.contentOffset = CGPointMake(0.0, self.bounds.height)

        self.snapToCalendarView(self.visibleMonthView!)
        
        if let visibleMonthView = self.visibleMonthView, calendarTitleView = self.calendarTitleView {
            calendarTitleView.setup(visibleMonthView.month)
        }
    }
    
    private func defaultSetup() {
        self.delegate = self
        self.clipsToBounds = true
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.setup(NSDate())
    }
    
    private func setupLayout() {
        self.verticalDaySeparation = (Double(self.bounds.height) - (7.0 * self.dayViewDimension))/7.0
        self.horizontalDaySeparation = (Double(self.bounds.width) - (7.0 * self.dayViewDimension))/8.0
    }
    
    private func setNewVisibleMonthView(monthView: CalendarMonthView) {
        self.p_visibleMonthView = monthView
        self.calendarTitleView?.setup(monthView.month)
    }
    
    //MARK: - Month Helpers
    private func monthViewWithStartDate(startDate: NSDate) -> CalendarMonthView {
        let calendarMonthView = CalendarMonthView(frame: self.bounds)
        calendarMonthView.delegate = self
        calendarMonthView.dayViewVerticalSeparation = self.verticalDaySeparation
        calendarMonthView.dayViewHorizontalSeparation = self.horizontalDaySeparation
        calendarMonthView.setupWithStartDate(startDate)
        return calendarMonthView
    }
    
    private func clearMonthViews() {
        for monthView in self.loadedMonthViews {
            monthView.removeFromSuperview()
        }
        self.loadedMonthViews = [CalendarMonthView]()
    }
    
    //MARK: - Scroll Helpers
    public func snapToCalendarView(view: CalendarMonthView) {
        print("Snapping to Month View: \(view)")
        self.setContentOffset(CGPointMake(0.0, view.frame.origin.y), animated: true)
    }
    
    //MARK: - Month Paging Helpers
    private func loadPreviousMonth() {
        if let visibleMonthView = self.visibleMonthView, visibleMonthIndex = self.loadedMonthViews.indexOf(visibleMonthView) {
            
            let previousMonthStartDate = DateHelpers.previousMonthStartDate(visibleMonthView.startDate)
            
            let previousMonthView = self.monthViewWithStartDate(previousMonthStartDate)
            
            self.insertMonthViewAndReadjustScrollView(previousMonthView, atIndex: 0)
            
            let indexToRemove = visibleMonthIndex + 3
            if (indexToRemove) < self.loadedMonthViews.count {
                let monthViewToRemove = self.loadedMonthViews[indexToRemove]
                self.removeMonthViewAndReadjustScrollView(monthViewToRemove)
            }
        }
    }
    
    private func loadNextMonth() {
        if let visibleMonthView = self.visibleMonthView, visibleMonthIndex = self.loadedMonthViews.indexOf(visibleMonthView) {
            
            let indexToRemove = visibleMonthIndex - 2
            if (indexToRemove) >= 0 {
                let monthViewToRemove = self.loadedMonthViews[indexToRemove]
                self.removeMonthViewAndReadjustScrollView(monthViewToRemove)
            }
            
            let nextMonthStartDate = DateHelpers.nextMonthStartDate(visibleMonthView.startDate)
            
            let nextMonthView = self.monthViewWithStartDate(nextMonthStartDate)
            nextMonthView.frame.origin.y = visibleMonthView.frame.origin.y + visibleMonthView.frame.height
            self.loadedMonthViews.append(nextMonthView)
            self.addSubview(nextMonthView)
        }
    }
    
    private func insertMonthViewAndReadjustScrollView(monthView: CalendarMonthView, atIndex viewIndex: Int) {
        let offsetHeight = monthView.bounds.height
        
        for index in viewIndex ... self.loadedMonthViews.count - 1 {
            let view = self.loadedMonthViews[index]
            view.frame.origin.y += offsetHeight
        }
        
        monthView.frame.origin.y = CGFloat(viewIndex) * CGFloat(offsetHeight)
        self.loadedMonthViews.insert(monthView, atIndex: viewIndex)
        self.addSubview(monthView)
        
        if let visibleMonthView = self.visibleMonthView, visibleIndex = self.loadedMonthViews.indexOf(visibleMonthView) where visibleIndex > viewIndex {
            self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + offsetHeight)
        }
    }
    
    private func removeMonthViewAndReadjustScrollView(monthView: CalendarMonthView) {
        if let viewIndex = self.loadedMonthViews.indexOf(monthView) {
            monthView.removeFromSuperview()
            let offsetHeight = monthView.bounds.height
            self.loadedMonthViews.removeAtIndex(viewIndex)
            
            if viewIndex >= self.loadedMonthViews.count {
                return
            }

            for index in viewIndex ... self.loadedMonthViews.count - 1 {
                let view = self.loadedMonthViews[index]
                view.frame.origin.y -= offsetHeight
            }
            
            if let visibleMonthView = self.visibleMonthView, visibleIndex = self.loadedMonthViews.indexOf(visibleMonthView) where visibleIndex >= viewIndex {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y - offsetHeight)
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if let visibleMonthView = self.visibleMonthView, visibleIndex = self.loadedMonthViews.indexOf(visibleMonthView) {
            let contentOffset = self.contentOffset
            let originY = visibleMonthView.frame.origin.y
            
            if (visibleIndex + 1) < self.loadedMonthViews.count {
                let nextView = self.loadedMonthViews[visibleIndex + 1]
                
                if contentOffset.y > (originY + 0.50 * visibleMonthView.frame.height) {
                    if self.visibleMonthView != nextView {
                        self.setNewVisibleMonthView(nextView)
                        self.loadNextMonth()
                    }
                    return
                }
            }
            
            if (visibleIndex - 1) >= 0 {
                let previousView = self.loadedMonthViews[visibleIndex - 1]
                if contentOffset.y < (originY - (0.50 * visibleMonthView.frame.height)) {
                    if self.visibleMonthView != previousView {
                        self.setNewVisibleMonthView(previousView)
                        self.loadPreviousMonth()
                    }
                    return
                }
            }
        }
    }
    
    //MARK: - CalendarMonthViewDelegate
    func calendarMonthView(monthView: CalendarMonthView, selectedDay dayView: CalendarDayView) {
        self.calendarDelegate?.calendarView(self, selectedDayView: dayView)
    }
    
    func calendarMonthView(monthView: CalendarMonthView, laidOut dayView: CalendarDayView) {
        self.calendarDelegate?.calendarView?(self, laidOutDayView: dayView)
    }
}

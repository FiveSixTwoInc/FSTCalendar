//
//  CalendarVerticalView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

private typealias MonthYear = (month: Month, year: Int)

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
    private var upperMonthYearLimit: MonthYear?
    private var lowerMonthYearLimit: MonthYear?
    
    public var dayViewDimension = 50.0
    public var verticalDaySeparation = 5.0
    public var horizontalDaySeparation = 5.0
    
    //MARK: - State
    private var monthViews = [CalendarMonthView]()
    
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
    
    //MARK: - Public
    public func reloadData() {
        for monthView in self.monthViews {
            monthView.reloadData()
        }
    }
    
    //MARK: - Setup
    public func setup(month: Month, year: Int) {
        let startDate = DateHelpers.dateForDayMonthYear(1, month: month.rawValue, year: year)!
        self.setup(startDate)
    }
    
    public func setUpperRange(month: Month, year: Int) {
        self.upperMonthYearLimit = (month, year)
    }
    
    public func setLowerRange(month: Month, year: Int) {
        self.lowerMonthYearLimit = (month, year)
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
            
            self.monthViews.append(calendarMonthView)
            if (date == monthStartDate) {
                self.p_visibleMonthView = calendarMonthView
            }
        }
        
        self.contentSize = CGSize(width: self.bounds.width, height: y)
        self.contentOffset = CGPointMake(0.0, self.bounds.height)

        self.snapToCalendarView(self.visibleMonthView!)
        
        if let visibleMonthView = self.visibleMonthView, calendarTitleView = self.calendarTitleView {
            calendarTitleView.setup(visibleMonthView.startDate)
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
    
    //MARK: - Month Helpers
    private func setNewVisibleMonthView(monthView: CalendarMonthView) {
        self.p_visibleMonthView = monthView
        self.calendarTitleView?.setup(monthView.startDate)
    }
    
    private func monthViewWithStartDate(startDate: NSDate) -> CalendarMonthView {
        let calendarMonthView = CalendarMonthView(frame: self.bounds)
        calendarMonthView.delegate = self
        calendarMonthView.dayViewVerticalSeparation = self.verticalDaySeparation
        calendarMonthView.dayViewHorizontalSeparation = self.horizontalDaySeparation
        calendarMonthView.setupWithStartDate(startDate)
        return calendarMonthView
    }
    
    private func clearMonthViews() {
        for monthView in self.monthViews {
            monthView.removeFromSuperview()
        }
        self.monthViews = [CalendarMonthView]()
    }
    
    //MARK: - Scroll Helpers
    public func snapToCalendarView(view: CalendarMonthView) {
        print("Snapping to Month View: \(view)")
        self.setContentOffset(CGPointMake(0.0, view.frame.origin.y), animated: true)
    }
    
    //MARK: - Month Paging Helpers
    private func loadPreviousMonth() {
        if let visibleMonthView = self.visibleMonthView, visibleMonthIndex = self.monthViews.indexOf(visibleMonthView) {
            
            let previousMonthStartDate = DateHelpers.previousMonthStartDate(visibleMonthView.startDate)
            
            let previousMonthView = self.monthViewWithStartDate(previousMonthStartDate)
            
            self.insertMonthViewAndReadjustScrollView(previousMonthView, atIndex: 0)
            
            let indexToRemove = visibleMonthIndex + 3
            if self.monthViews.count >= 3 && (indexToRemove) < self.monthViews.count {
                let monthViewToRemove = self.monthViews[indexToRemove]
                self.removeMonthViewAndReadjustScrollView(monthViewToRemove)
            }
        }
    }
    
    private func loadNextMonth() {
        if let visibleMonthView = self.visibleMonthView, visibleMonthIndex = self.monthViews.indexOf(visibleMonthView) {
            
            let indexToRemove = visibleMonthIndex - 2
            if self.monthViews.count >= 3 && (indexToRemove) >= 0 {
                let monthViewToRemove = self.monthViews[indexToRemove]
                self.removeMonthViewAndReadjustScrollView(monthViewToRemove)
            }
            
            let nextMonthStartDate = DateHelpers.nextMonthStartDate(visibleMonthView.startDate)
            
            let nextMonthView = self.monthViewWithStartDate(nextMonthStartDate)
            nextMonthView.frame.origin.y = visibleMonthView.frame.origin.y + visibleMonthView.frame.height
            self.monthViews.append(nextMonthView)
            self.addSubview(nextMonthView)
        }
    }
    
    private func insertMonthViewAndReadjustScrollView(monthView: CalendarMonthView, atIndex viewIndex: Int) {
        let offsetHeight = monthView.bounds.height
        
        for index in viewIndex ... self.monthViews.count - 1 {
            //Adjust all monthViews below the new monthView downward
            let view = self.monthViews[index]
            view.frame.origin.y += offsetHeight
        }
        
        monthView.frame.origin.y = CGFloat(viewIndex) * CGFloat(offsetHeight)
        self.monthViews.insert(monthView, atIndex: viewIndex)
        self.addSubview(monthView)
        
        if let visibleMonthView = self.visibleMonthView, visibleIndex = self.monthViews.indexOf(visibleMonthView) where visibleIndex > viewIndex {
            //Adjust the contentOffset so the users viewpoint remains stationary
            self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + offsetHeight)
        }
    }
    
    private func removeMonthViewAndReadjustScrollView(monthView: CalendarMonthView) {
        if let viewIndex = self.monthViews.indexOf(monthView) {
            monthView.removeFromSuperview()
            let offsetHeight = monthView.bounds.height
            self.monthViews.removeAtIndex(viewIndex)
            
            if viewIndex >= self.monthViews.count {
                //If we removed the bottom-most month we don't need to adjust anything
                return
            }

            for index in viewIndex ... self.monthViews.count - 1 {
                //Adjust the frames for all remaining month views upwards so they fill the remaining content area
                let view = self.monthViews[index]
                view.frame.origin.y -= offsetHeight
            }
            
            if let visibleMonthView = self.visibleMonthView, visibleIndex = self.monthViews.indexOf(visibleMonthView) where visibleIndex >= viewIndex {
                //Adjust the contentOffset so the users viewpoint remains stationary
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y - offsetHeight)
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if let visibleMonthView = self.visibleMonthView, visibleIndex = self.monthViews.indexOf(visibleMonthView){
            let contentOffset = self.contentOffset
            let originY = visibleMonthView.frame.origin.y
            
            if contentOffset.y > (originY + 0.50 * visibleMonthView.frame.height) && (visibleIndex + 1) < self.monthViews.count {
                let nextView = self.monthViews[visibleIndex + 1]

                if self.visibleMonthView != nextView {
                    var shouldLoadNext = true
                    
                    if let upperMonthYearLimit = self.upperMonthYearLimit, upperLimitDate = DateHelpers.dateForDayMonthYear(1, month: upperMonthYearLimit.month.rawValue, year: upperMonthYearLimit.year) {
                        //Check to see if the first day of the month for the month we would be potentially loading is within our range of months to load
                        let followingMonthStart = DateHelpers.nextMonthStartDate(nextView.startDate)
                        switch followingMonthStart.compare(upperLimitDate) {
                            case .OrderedDescending:
                                shouldLoadNext = false
                            default:
                                break;
                        }
                    }

                    self.setNewVisibleMonthView(nextView)
                    if shouldLoadNext && visibleIndex + 1 == self.monthViews.count - 1 {
                        //We should only load new pages when we haven't hit our lower limit and when we are scrolling into the MonthView currently on the edge
                        self.loadNextMonth()
                    }
                }
                return
            }
            
            if contentOffset.y < (originY - (0.50 * visibleMonthView.frame.height)) && (visibleIndex - 1) >= 0{
                let previousView = self.monthViews[visibleIndex - 1]

                if self.visibleMonthView != previousView {
                    var shouldLoadPrevious = true
                    
                    if let lowerMonthYearLimit = self.lowerMonthYearLimit, lowerLimitDate = DateHelpers.dateForDayMonthYear(1, month: lowerMonthYearLimit.month.rawValue, year: lowerMonthYearLimit.year) {
                        //Check to see if the first day of the month for the month we would be potentially loading is within our range of months to load
                        let previousMonthStart = DateHelpers.previousMonthStartDate(previousView.startDate)
                        switch previousMonthStart.compare(lowerLimitDate) {
                            case .OrderedAscending:
                                shouldLoadPrevious = false
                            default:
                                break;
                        }
                    }
                    
                    self.setNewVisibleMonthView(previousView)
                    
                    if shouldLoadPrevious && visibleIndex - 1 == 0 {
                        //We should only load new pages when we haven't hit our lower limit and when we are scrolling into the MonthView currently on the edge
                        self.loadPreviousMonth()
                    }
                }
            return
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

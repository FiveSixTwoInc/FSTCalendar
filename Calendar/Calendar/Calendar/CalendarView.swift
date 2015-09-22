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
    
    var lockScrollChecking = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.decelerationRate = UIScrollViewDecelerationRateNormal
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
        self.snapToCalendarView(currentMonthCalendarView)
    }
    
    //MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.lockScrollChecking {
            return
        }
        if let visibleMonthView = self.visibleMonthView, visibleIndex = self.loadedMonthViews.indexOf(visibleMonthView) {
            let contentOffset = self.contentOffset
            let originY = visibleMonthView.frame.origin.y
            
            if (visibleIndex + 1) < self.loadedMonthViews.count {
                let nextView = self.loadedMonthViews[visibleIndex + 1]
                
                if contentOffset.y > (originY + 0.25 * visibleMonthView.frame.height) {
                    if self.visibleMonthView != nextView {
                        self.visibleMonthView = nextView
                        print("Set To Snap To Next Month")
                        self.loadNextMonth()
                    }
                    return
                }
            }
            
            if (visibleIndex - 1) >= 0 {
                let previousView = self.loadedMonthViews[visibleIndex - 1]
                if contentOffset.y < (originY - 0.25 * visibleMonthView.frame.height) {
                    if self.visibleMonthView != previousView {
                        print("Set To Snap To Previous Month")
                        self.visibleMonthView = previousView
                        self.loadPreviousMonth()
                    }
                    return
                }
            }
        }
    }
    
    private func adjustContentSize() {
        let lastMonth = self.loadedMonthViews[self.loadedMonthViews.count - 1]
        self.contentSize = CGSize(width: self.bounds.width, height: lastMonth.frame.origin.y + lastMonth.frame.height)

    }
    
    private func loadPreviousMonth() {
        print("Loading Previous Month View")
        if let visibleMonthView = self.visibleMonthView, visibleMonthIndex = self.loadedMonthViews.indexOf(visibleMonthView) {
            
            let previousMonthStartDate = DateHelpers.previousMonthStartDate(visibleMonthView.startDate)
            
            let previousMonthView = CalendarMonthView(frame: self.bounds)
            previousMonthView.frame.origin.y = 0
            previousMonthView.setupWithStartDate(previousMonthStartDate)
            
            self.insertMonthViewAndReadjustScrollView(previousMonthView, atIndex: 0)
            
            let indexToRemove = visibleMonthIndex + 3
            if (indexToRemove) < self.loadedMonthViews.count {
                let monthViewToRemove = self.loadedMonthViews[indexToRemove]
                self.removeMonthViewAndReadjustScrollView(monthViewToRemove)
            }
            
            self.adjustContentSize()
        }
    }
    
    private func loadNextMonth() {
        print("Loading Next Month View")
        if let visibleMonthView = self.visibleMonthView, visibleMonthIndex = self.loadedMonthViews.indexOf(visibleMonthView) {
            
            let indexToRemove = visibleMonthIndex - 3
            if (indexToRemove) >= 0 {
                let monthViewToRemove = self.loadedMonthViews[indexToRemove]
                self.removeMonthViewAndReadjustScrollView(monthViewToRemove)
            }
            
            let nextMonthStartDate = DateHelpers.nextMonthStartDate(visibleMonthView.startDate)
            
            let nextMonthView = CalendarMonthView(frame: self.bounds)
            nextMonthView.frame.origin.y = visibleMonthView.frame.origin.y + visibleMonthView.frame.height
            nextMonthView.setupWithStartDate(nextMonthStartDate)
            self.loadedMonthViews.append(nextMonthView)
            self.addSubview(nextMonthView)
            
            self.adjustContentSize()
        }
    }
    
    private func insertMonthViewAndReadjustScrollView(monthView: CalendarMonthView, atIndex viewIndex: Int) {
        self.lockScrollChecking = true
        let offsetHeight = monthView.bounds.height
        self.loadedMonthViews.insert(monthView, atIndex: viewIndex)
        self.addSubview(monthView)
        
        if viewIndex >= self.loadedMonthViews.count {
            self.lockScrollChecking = false
            return
        }
        for index in viewIndex + 1 ... self.loadedMonthViews.count - 1 {
            let view = self.loadedMonthViews[index]
            view.frame.origin.y += offsetHeight
        }
        
        self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + offsetHeight)
        self.lockScrollChecking = false
    }
    
    private func removeMonthViewAndReadjustScrollView(monthView: CalendarMonthView) {
        self.lockScrollChecking = true
        if let viewIndex = self.loadedMonthViews.indexOf(monthView) {
            monthView.removeFromSuperview()
            let offsetHeight = monthView.bounds.height
            self.loadedMonthViews.removeAtIndex(viewIndex)

            if viewIndex >= self.loadedMonthViews.count {
                self.lockScrollChecking = false
                return
            }
            for index in viewIndex ... self.loadedMonthViews.count - 1 {
                let view = self.loadedMonthViews[index]
                view.frame.origin.y -= offsetHeight
            }
            
            self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y - offsetHeight)
            self.lockScrollChecking = false
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let visibleMonthView = self.visibleMonthView {
            self.snapToCalendarView(visibleMonthView)
        }
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.contentOffset = self.contentOffset
    }
    
    private func stopScrolling() {
        var offset = self.contentOffset
        offset.x -= 1.0
        offset.y -= 1.0
        self.contentOffset = offset
        offset.x += 1.0
        offset.y += 1.0
        self.contentOffset = offset
    }
    
    public func snapToCalendarView(view: CalendarMonthView) {
        print("Snapping to Month View: \(view)")
        self.contentOffset = self.contentOffset
        self.setContentOffset(CGPointMake(0.0, view.frame.origin.y), animated: true)
    }
}

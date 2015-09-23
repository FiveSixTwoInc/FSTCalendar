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
    
    //MARK: - Lifecycle
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
    
    //MARK: - Setup
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
    
    //MARK: - Scroll Helpers
    private func stopScrolling() {
        var offset = self.contentOffset
        offset.x -= 1.0
        offset.y -= 1.0
        self.setContentOffset(offset, animated: true)
        offset.x += 1.0
        offset.y += 1.0
        self.setContentOffset(offset, animated: true)
    }
    
    public func snapToCalendarView(view: CalendarMonthView) {
        print("Snapping to Month View: \(view)")
        self.setContentOffset(CGPointMake(0.0, view.frame.origin.y), animated: true)
    }
    
    //MARK: - Month Paging Helpers
    private func loadPreviousMonth() {
        self.lockScrollChecking = true
        if let visibleMonthView = self.visibleMonthView, visibleMonthIndex = self.loadedMonthViews.indexOf(visibleMonthView) {
            
            let previousMonthStartDate = DateHelpers.previousMonthStartDate(visibleMonthView.startDate)
            
            let previousMonthView = CalendarMonthView(frame: self.bounds)
            previousMonthView.setupWithStartDate(previousMonthStartDate)
            
            self.insertMonthViewAndReadjustScrollView(previousMonthView, atIndex: 0)
            
            let indexToRemove = visibleMonthIndex + 3
            if (indexToRemove) < self.loadedMonthViews.count {
                let monthViewToRemove = self.loadedMonthViews[indexToRemove]
                self.removeMonthViewAndReadjustScrollView(monthViewToRemove)
            }
        }
        self.lockScrollChecking = false
    }
    
    private func loadNextMonth() {
        if let visibleMonthView = self.visibleMonthView, visibleMonthIndex = self.loadedMonthViews.indexOf(visibleMonthView) {
            
            let indexToRemove = visibleMonthIndex - 2
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
        }
    }
    
    private func insertMonthViewAndReadjustScrollView(monthView: CalendarMonthView, atIndex viewIndex: Int) {
        self.lockScrollChecking = true
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
            
            if let visibleMonthView = self.visibleMonthView, visibleIndex = self.loadedMonthViews.indexOf(visibleMonthView) where visibleIndex >= viewIndex {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y - offsetHeight)
            }
            self.lockScrollChecking = false
        }
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
                
                if contentOffset.y > (originY + 0.35 * visibleMonthView.frame.height) {
                    if self.visibleMonthView != nextView {
                        print("Set To Snap To Next Month - Visible Month: \(visibleMonthView) - Current Offset: \(scrollView.contentOffset)")
                        self.visibleMonthView = nextView
                        self.loadedMonthViews.forEach{$0.backgroundColor = UIColor.clearColor()}
                        nextView.backgroundColor = UIColor.yellowColor()
                        self.loadNextMonth()
                    }
                    return
                }
            }
            
            if (visibleIndex - 1) >= 0 {
                let previousView = self.loadedMonthViews[visibleIndex - 1]
                if contentOffset.y < (originY - (0.65 * visibleMonthView.frame.height)) {
                    if self.visibleMonthView != previousView {
                        print("Set To Snap To Previous Month - Visible Month: \(visibleMonthView) - Current Offset: \(scrollView.contentOffset)")
                        self.visibleMonthView = previousView
                        self.loadedMonthViews.forEach{$0.backgroundColor = UIColor.clearColor()}
                        previousView.backgroundColor = UIColor.yellowColor()
                        self.loadPreviousMonth()
                    }
                    return
                }
            }
        }
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.stopScrolling()
        if let visibleMonthView = self.visibleMonthView {
            self.snapToCalendarView(visibleMonthView)
        }
    }
}

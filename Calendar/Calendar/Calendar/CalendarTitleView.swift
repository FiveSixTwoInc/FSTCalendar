//
//  CalendarTitleView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/22/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

public class CalendarTitleView: UIView {
    public var labelTitle: UILabel!
    
    //MARK: - Lifecycle
    override public func layoutSubviews() {
        super.layoutSubviews()
        if let labelTitle = self.labelTitle {
            labelTitle.frame = self.bounds
        }
    }
    
    //MARK: - Setup
    public func setup(date: NSDate) {
        if self.labelTitle == nil {
            self.labelTitle = UILabel(frame: self.bounds)
            self.labelTitle.textAlignment = NSTextAlignment.Center
            self.labelTitle.font = UIFont.boldSystemFontOfSize(16.0)
            self.addSubview(self.labelTitle)
        }
        let month = DateHelpers.monthForDate(date)
        self.labelTitle.text = "\(month.description) \(DateHelpers.yearForDate(date))"
    }
}

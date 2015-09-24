//
//  CalendarWeekdayView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/23/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

class CalendarWeekdayView: UIView {
    private var labelsWeekdays = [UILabel]()
    
    var labelWidth = 50.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        let separation = (Double(self.bounds.width) - (7.0 * self.labelWidth)) / 8.0
        var x = separation
        for day in Weekday.allDays {
            let labelFrame = CGRect(x: x, y: 0.0, width: self.labelWidth, height: Double(self.frame.height))
            let label = UILabel(frame: labelFrame)
            label.text = day.shortDescription
            label.enabled = false
            label.font = UIFont.systemFontOfSize(14.0)
            label.textAlignment = NSTextAlignment.Center
            self.labelsWeekdays.append(label)
            self.addSubview(label)
            x += separation + self.labelWidth
        }
    }
}

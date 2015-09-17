//
//  CalendarDayView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

class CalendarDayView: UIView {
    private var labelDayNumber: UILabel!
    private var viewBackgroundCircle: UIView!
    
    var date = NSDate()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
    }
    
    //MARK: - Lifecycle
    func initialSetup() {
        self.viewBackgroundCircle = UIView(frame: self.bounds)
        self.viewBackgroundCircle.layer.cornerRadius = self.bounds.height/2.0
        self.viewBackgroundCircle.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(self.viewBackgroundCircle)
        
        self.labelDayNumber = UILabel(frame: self.bounds)
        self.labelDayNumber.textAlignment = NSTextAlignment.Center
        self.labelDayNumber.font = UIFont.systemFontOfSize(14.0)
        self.addSubview(self.labelDayNumber)
    }
    
    //MARK: - Setup
    func setup(date: NSDate) {
        self.date = date
        self.labelDayNumber.text = "\(DateHelpers.dayOfMonthForDate(date))"
    }
    
    func setupWithDay(day: Int) {
        self.labelDayNumber.text = "\(day)"
    }
}

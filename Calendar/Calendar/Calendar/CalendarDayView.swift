//
//  CalendarDayView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/17/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

public protocol CalendarDayViewDelegate: class {
    func calendarDayViewWasSelected(dayView: CalendarDayView)
}

public class CalendarDayView: UIView {
    weak var delegate: CalendarDayViewDelegate?
    
    //MARK: - UI
    public var viewBackgroundCircle: UIView!
    
    public var textColor: UIColor? {
        get {
            return self.labelDayNumber?.textColor
        }
        set (color) {
            if let labelDayNumber = self.labelDayNumber {
                labelDayNumber.textColor = color
            }
        }
    }
    
    public var isDayEnabled: Bool {
        get {
            return self.internalIsDayEnabled
        }
        set (value) {
            self.internalIsDayEnabled = value
            self.userInteractionEnabled = value
            self.labelDayNumber.enabled = value
        }
    }
    
    private var internalIsDayEnabled = true
    
    private var labelDayNumber: UILabel!
    
    lazy var gestureRecognizerSelect: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CalendarDayView.didTapDayView))
        return gestureRecognizer
    }()
    
    //MARK: - State
    public var date: NSDate {
        get {
            return self.internalDate
        }
    }
    
    private var internalDate = NSDate()
    
    var isSelected = false
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
    }
    
    //MARK: - Lifecycle
    func initialSetup() {
        self.viewBackgroundCircle = UIView(frame: self.bounds)
        self.viewBackgroundCircle.layer.cornerRadius = self.bounds.height/2.0
        self.viewBackgroundCircle.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.viewBackgroundCircle)
        
        self.labelDayNumber = UILabel(frame: self.bounds)
        self.labelDayNumber.textAlignment = NSTextAlignment.Center
        self.labelDayNumber.font = UIFont.systemFontOfSize(16.0)
        self.addSubview(self.labelDayNumber)
        self.addGestureRecognizer(self.gestureRecognizerSelect)
    }
    
    //MARK: - Setup
    func setup(date: NSDate) {
        self.internalDate = date
        self.labelDayNumber.text = "\(DateHelpers.dayOfMonthForDate(date))"
    }
    
    func setupWithDay(day: Int) {
        self.labelDayNumber.text = "\(day)"
    }
    
    //MARK: - Helpers
    @objc private func didTapDayView() {
        self.isSelected = !self.isSelected
        self.delegate?.calendarDayViewWasSelected(self)
    }
}

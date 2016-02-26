//
//  CalendarTitleView.swift
//  FSTCalendar
//
//  Created by Jackson Beachwood on 9/22/15.
//  Copyright © 2015 FiveSixTwo. All rights reserved.
//

import UIKit

private let backArrowImage = UIImage(named: "BackArrow", inBundle: NSBundle(forClass: CalendarTitleView.self), compatibleWithTraitCollection: nil)
private let forwardArrowImage = UIImage(named: "ForwardArrow", inBundle: NSBundle(forClass: CalendarTitleView.self), compatibleWithTraitCollection: nil)

public protocol CalendarTitleViewDelegate: class {
    func calendarTitleViewHitPreviousButton()
    func calendarTitleViewHitNextButton()
}

public class CalendarTitleView: UIView {
    public var labelTitle: UILabel!
    public weak var delegate: CalendarTitleViewDelegate?
    
    private var buttonPrevious: UIButton!
    private var buttonNext: UIButton!
    
    //MARK: - Lifecycle
    override public func layoutSubviews() {
        super.layoutSubviews()
        if let labelTitle = self.labelTitle {
            labelTitle.frame = self.bounds
        }
        if self.buttonPrevious == nil && self.buttonNext == nil {
            self.setupButtons()
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
    
    private func setupButtons() {
        let height = self.bounds.height - 6.0
        let buttonPrevious = UIButton(type: UIButtonType.System)
        buttonPrevious.setImage(backArrowImage, forState: .Normal)
        buttonPrevious.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        buttonPrevious.contentHorizontalAlignment = .Left
        buttonPrevious.bounds = CGRectMake(0.0, 0.0, 85.0, height)
        buttonPrevious.center = CGPoint(x: 8.0 + Double((buttonPrevious.bounds.width/2.0)), y: Double(self.bounds.height/2.0))
        buttonPrevious.addTarget(self, action: #selector(CalendarTitleView.buttonPressedPrevious(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        let buttonNext = UIButton(type: UIButtonType.System)
        buttonNext.setImage(forwardArrowImage, forState: .Normal)
        buttonNext.contentHorizontalAlignment = .Right
        buttonNext.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        buttonNext.bounds = CGRectMake(0.0, 0.0, 85.0, height)
        buttonNext.center = CGPoint(x: Double(self.bounds.width) - 8.0 - Double((buttonNext.bounds.width/2.0)), y: Double(self.bounds.height/2.0))
        buttonNext.addTarget(self, action: #selector(CalendarTitleView.buttonPressedNext(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(buttonNext)

        self.addSubview(buttonPrevious)
        
        self.buttonNext = buttonNext
        self.buttonPrevious = buttonPrevious
    }
    
    @objc private func buttonPressedNext(sender: UIButton) {
        self.delegate?.calendarTitleViewHitNextButton()
    }
    
    @objc private func buttonPressedPrevious(sender: UIButton) {
        self.delegate?.calendarTitleViewHitPreviousButton()
    }
}

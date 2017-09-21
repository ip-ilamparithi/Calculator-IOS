//
//  ViewController.swift
//  Calculator
//
//  Created by Michel Deiman on 11/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class ViewController: UIViewController
{
	@IBOutlet fileprivate weak var display: UILabel!
//	@IBOutlet weak var descriptionDisplay: UILabel!
	
	fileprivate var brain = CalculatorBrain()
	
	fileprivate var userIsInTheMiddleOfTyping = false {
		didSet {
			useInitialNullValueAsOperand = false
		}
	}
	fileprivate var useInitialNullValueAsOperand = true


	@IBAction fileprivate func touchDigit(_ sender: UIButton) {
		let digit = sender.currentTitle!
		if userIsInTheMiddleOfTyping
		{	display.text = display.text! + digit
		} else
		{	display.text = digit
			userIsInTheMiddleOfTyping = true
		}
	}
	
	@IBAction fileprivate func floatingPoint()
	{	if !userIsInTheMiddleOfTyping {
			display.text = "0."
		} else
		if display.text?.range(of: ".") == nil {
			display.text = display.text! + "."
		}
		userIsInTheMiddleOfTyping = true
	}

	fileprivate var displayValue: Double? {
		get {
			return Double(display.text!)
		}
		set {
			display.text = String(describing: newValue!)
		}
	}

	@IBAction fileprivate func clearAll()
	{	brain.clear()
		displayValue = brain.result
		useInitialNullValueAsOperand = true
	}
	
	@IBAction fileprivate func backSpace()
	{	guard userIsInTheMiddleOfTyping else { return }
		if display.text?.characters.count <= 1
		{	displayValue = nil
			userIsInTheMiddleOfTyping = false
			return
		}
		display.text = String(display.text!.characters.dropLast())
	}

	@IBAction fileprivate func performOperation(_ sender: UIButton) {		
		if userIsInTheMiddleOfTyping || useInitialNullValueAsOperand {
			brain.setOperand(displayValue!)
			userIsInTheMiddleOfTyping = false
		}
		let mathematicalSymbol = sender.currentTitle
		brain.performOperation(mathematicalSymbol!)
		displayValue = brain.result
		let postfixDescription = brain.isPartialResult ? "..." : "="
//		descriptionDisplay.text = brain.description + postfixDescription
	}
	
	fileprivate var numberFormatter = NumberFormatter()
			
	override func viewDidLoad() {
		super.viewDidLoad()
		numberFormatter.alwaysShowsDecimalSeparator = false
		numberFormatter.maximumFractionDigits = 6
		numberFormatter.minimumFractionDigits = 0
		numberFormatter.minimumIntegerDigits = 1
		brain.numberFormatter = numberFormatter
	}
}


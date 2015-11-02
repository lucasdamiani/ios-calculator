//
//  ViewController.swift
//  Calculator
//
//  Created by Lucas Damiani on 13/09/15.
//  Copyright © 2015 Lucas Damiani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var expression: UILabel!
    private let errorMessage = " "
    private var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    private var displayValue: Double? {
        get {
            if let displayText = display.text, let number = NSNumberFormatter().numberFromString(displayText) {
                return number.doubleValue
            } else {
                return nil
            }
        }
        set {
            if let value = newValue {
                let number = NSNumber(double: value)
                display.text = number.isInteger ? "\(number.integerValue)" : "\(number.doubleValue)"
            } else {
                display.text = errorMessage
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            display.text = display.text! + digit
        } else {
            userIsInTheMiddleOfTyping = true
            display.text = digit
        }
    }
    
    @IBAction func appendDecimal(sender: AnyObject) {
        if !hasDecimalPoint() {
            display.text = display.text! + "."
        }
    }
    
    @IBAction func performOperation(sender: UIButton) {
        if let operation = sender.currentTitle {
            if userIsInTheMiddleOfTyping {
                enter()
            }
            
            displayValue = brain.performOperation(operation)
            setExpression(brain.description)
        }
    }
    
    @IBAction func enter() {
        if let value = displayValue {
            displayValue = brain.pushOperand(value)
            userIsInTheMiddleOfTyping = false
            setExpression(brain.description)
        }
    }
    
    @IBAction func backSpace() {
        if let displayText = display.text where !displayText.isEmpty {
            display.text = displayText.substringToIndex(displayText.endIndex.predecessor())
            if display.text?.isEmpty ?? true {
                resetUI()
            }
        }
    }
    
    @IBAction func clear() {
        brain.clear()
        resetUI()
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        if let variable = sender.currentTitle {
            if userIsInTheMiddleOfTyping {
                enter()
            }
            
            brain.pushOperand(variable)
            enterVariable()
        }
    }
    
    @IBAction func setVariable(sender: UIButton) {
        if let variable = sender.currentTitle?.substringFromIndex(sender.currentTitle!.endIndex.predecessor()) {
            brain.variableValues[variable] = displayValue
            enterVariable()
        }
    }
    
    
    private func resetUI() {
        displayValue = 0
        setExpression(" ")
        userIsInTheMiddleOfTyping = false
    }
    
    private func hasDecimalPoint() -> Bool {
        return display.text?.containsString(".") ?? false
    }
    
    private func setExpression(expressionText: String?) {
        expression.text = expressionText
    }
    
    private func enterVariable() {
        displayValue = brain.evaluate()
        setExpression(brain.description)
        userIsInTheMiddleOfTyping = false
    }
}


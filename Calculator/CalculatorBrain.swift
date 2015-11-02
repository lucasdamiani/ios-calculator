//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Lucas Damiani on 13/09/15.
//  Copyright © 2015 Lucas Damiani. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    enum Op : CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Variable(String)
        case Constant(String, Double)
        
        var description : String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let operation, _):
                    return operation
                case .BinaryOperation(let operation, _):
                    return operation
                case .Variable(let symbol):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    var variableValues = [String:Double]()
    var description : String {
        get {
            let expressions = prettifyExpressions(identifyExpressions())
            return expressions.joinWithSeparator(",")
        }
    }
    
    typealias PropertyList = AnyObject
    var program : PropertyList { // guaranteed to be a property list
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                
                opStack = newOpStack
            }
        }
    }
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("±") { $0 * -1 })
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.Constant("π", M_PI))
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(operation: String) -> Double? {
        if let operation = knownOps[operation] {
            opStack.append(operation)
            return evaluate()
        }
        
        return nil
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func clear() {
        opStack.removeAll()
        variableValues.removeAll()
    }
    
    private func evaluate(remainder: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !remainder.isEmpty {
            var remainingOps = remainder
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let operandEvaluation1 = evaluate(remainingOps)
                if let operand1 = operandEvaluation1.result {
                    let operandEvaluation2 = evaluate(operandEvaluation1.remainingOps)
                    if let operand2 = operandEvaluation2.result {
                        return (operation(operand1, operand2), operandEvaluation2.remainingOps)
                    }
                }
            case .Variable(let symbol):
                let variableValue = variableValues[symbol]
                return (variableValue, remainingOps)
            case .Constant(_, let value):
                return (value, remainingOps)
            }
        }
        
        return (nil, remainder)
    }
    
    private func prettifyOperand(operand: Double) -> String {
        let number = operand as NSNumber
        return number.isInteger ? "\(number.integerValue)" : "\(number.doubleValue)"
    }
    
    private func identifyExpressions() -> [String] {
        var expressions = [String]()
        for op in opStack {
            switch op {
            case .Operand(let operand):
                expressions.append(prettifyOperand(operand))
            case .UnaryOperation(let symbol, _):
                expressions.append("\(symbol)(\(expressions.removeLast()))")
            case .BinaryOperation(let symbol, _):
                let operand2 = expressions.removeLast()
                var operand1 = "?"
                if !expressions.isEmpty {
                    operand1 = expressions.removeLast()
                }
                
                expressions.append("(\(operand1) \(symbol) \(operand2))")
            case .Variable(let symbol):
                expressions.append(symbol)
            case .Constant(let symbol, _):
                expressions.append(symbol)
            }
        }
        
        return expressions
    }
    
    private func prettifyExpressions(expressions: [String]) -> [String] {
        var prettifiedExpressions = expressions
        for index in 0..<prettifiedExpressions.count {
            let expression = prettifiedExpressions[index]
            if expression.hasPrefix("(") && expression.hasSuffix(")") {
                prettifiedExpressions[index] = expression.substringWithRange(Range<String.Index>(start: expression.startIndex.successor(), end: expression.endIndex.predecessor()))
            }
        }
        
        return prettifiedExpressions
    }
}
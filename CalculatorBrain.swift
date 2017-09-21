//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michel Deiman on 11/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import Foundation

class CalculatorBrain  {
	
	fileprivate var accumulator = 0.0
	fileprivate var internalProgram = [AnyObject]()
	
	func setOperand(_ operand: Double) {
		if pending == nil {
			clear()
		}
		accumulator = operand
		internalProgram.append(operand as AnyObject)
	}
	
	
	fileprivate var operations: [String: Operation] = [
		"×"		: Operation.binaryOperation(*),
		"÷"		: Operation.binaryOperation(/),  // { $0 / $1 },
		"+"		: Operation.binaryOperation(+),
		"−"		: Operation.binaryOperation { $0 - $1 },
		"√"		: Operation.unaryOperation(.prefix("√"), sqrt),
		"¹∕ⅹ"	: Operation.unaryOperation(.postfix("⁻¹")) { 1/$0 },
		"x²"	: Operation.unaryOperation(.postfix("²")) { $0 * $0 },
		"Rand"	: Operation.constant(drand48()),
		"%"		: Operation.unaryOperation(.postfix("%")) { $0 / 100 },
		"sin"	: Operation.unaryOperation(.prefix("sin"), sin),
		"cos"	: Operation.unaryOperation(.prefix("cos"), cos),
		"tan"	: Operation.unaryOperation(.prefix("tan"), tan),
		"±"		: Operation.unaryOperation(.postfix("x -1")) { -$0 },
		"π"		: Operation.constant(M_PI),
		"e"		: Operation.constant(M_E),
		"="		: Operation.equals
	]
	
	// Operand == contant in 2016
	fileprivate enum Operation //: CustomStringConvertible
	{	case constant(Double)
		case unaryOperation(PrintSymbol, (Double) -> Double)
		case binaryOperation((Double, Double) -> Double)
		case equals
	
		enum PrintSymbol {
			case prefix(String)
			case postfix(String)
		}
	}
	
	func performOperation(_ symbol: String) {
		if let operation = operations[symbol]
		{	switch operation {
			case .constant(let value):
				if pending == nil {	clear() }
				accumulator = value
			case .unaryOperation(_, let f):
				accumulator = f(accumulator)
			case .binaryOperation(let f):
				executePendingBinaryOperation()
				pending = PendingBinaryOperationInfo(binaryFunction: f, firstOperand: accumulator)
			case .equals:
				executePendingBinaryOperation()
			}
			internalProgram.append(symbol as AnyObject)
		}
	}
	
	fileprivate func executePendingBinaryOperation()
	{	if let pending = pending {
			accumulator = pending.binaryFunction(pending.firstOperand, accumulator)
			self.pending = nil
		}
	}
	
	var isPartialResult: Bool
	{	return pending != nil
	}
	
	fileprivate var pending: PendingBinaryOperationInfo?
	
	fileprivate struct PendingBinaryOperationInfo {
		var binaryFunction: (Double, Double) -> Double
		var firstOperand: Double
	}
	
	var numberFormatter: NumberFormatter?
	
	var description: String {
		var targetString = ""
		for property in internalProgram
		{	if let operand = property as? Double {
				let stringToAppend = String(operand)
				targetString = targetString + stringToAppend
			} else if let symbol = property as? String
			{	if let operation = operations[symbol]
				{	switch operation {
					case .constant, .binaryOperation:
						targetString = targetString + symbol
					case .unaryOperation(let printSymbol, _):
						switch printSymbol {
						case .postfix(let symbol):
							targetString = "(" + targetString + ")" + symbol
						case .prefix(let symbol):
							targetString = symbol + "(" + targetString + ")"
						}
					default:
						break
					}
				}
			}
		}
		return targetString
	}
	
	func clear() {
		accumulator = 0.0
		pending = nil
		internalProgram = []
	}
	
	var result: Double {
		return accumulator
	}
		
}

//
//  Magic.swift
//  FreshExpress
//
//  Created by Nathan Flurry on 7/22/16.
//  Copyright © 2016 NathanFlurry. All rights reserved.
//

import Foundation

struct OptionalUnwrapError: ErrorProtocol, CustomStringConvertible {
	var parameter: String? = nil
	
	var description: String {
		return parameter != nil ? "Could not unwrap parameter \(parameter)." : "Optional unwrap error."
	}
}

extension Optional {
	func unwrap(_ parameter: String? = nil) throws -> Wrapped {
		switch self {
		case .some(let data):
			return data
		case .none:
			throw OptionalUnwrapError(parameter: parameter)
		}
	}
}

extension Date {
	func isSameDay(date: Date) -> Bool {
		// Create the component flags
		let flags: Calendar.Unit = [Calendar.Unit.day, Calendar.Unit.month, Calendar.Unit.year]
		
		// Extract the components
		var a = Calendar.current.components(flags, from: self)
		var b = Calendar.current.components(flags, from: date)
		
		// Compare
		return a.day == b.day && a.month == b.month && a.year == b.year
	}
}

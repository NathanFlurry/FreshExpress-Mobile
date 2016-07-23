//
//  Server.swift
//  FreshExpress
//
//  Created by Nathan Flurry on 7/22/16.
//  Copyright © 2016 NathanFlurry. All rights reserved.
//

import Foundation
import Alamofire

enum HandlerResponse<DataType> {
	case success(DataType), error(ErrorProtocol)
}

typealias ServerCallback<DataType> = (HandlerResponse<DataType>) -> Void

class ScheduleItem {
	var id: Int
	var startDate: Date
	var endDate: Date
	
	init(serialized: [String: AnyObject]) throws {
		id = try (serialized["Id"] as? Int).unwrap("Id")
		startDate = Date(timeIntervalSince1970: try (serialized["StartDate"] as? Double).unwrap("StartDate"))
		endDate = Date(timeIntervalSince1970: try (serialized["EndDate"] as? Double).unwrap("EndDate"))
	}
}

class FoodItem {
	
}

class BusStop {
	
}

enum ServerError: ErrorProtocol {
	case invalidData(AnyObject?), missingValue(String)
}

class Server {
	static let serverAddress = "http://localhost:8080/"
//	static let dateFormatter: DateFormatter = {
//		let dateFormatter = DateFormatter()
//		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
//		return dateFormatter
//	}()
	
	static func getSchedule(handler: ServerCallback<[ScheduleItem]>) {
		request(.GET, "\(serverAddress)/schedule").responseJSON { response in
			do {
				switch response.result {
				case .success(let value):
					// Cast to JSON
					guard let json = value as? [String: AnyObject] else {
						throw ServerError.invalidData(value)
					}
					
					// Get the items
					guard let items = json["items"] as? [[String: AnyObject]] else {
						throw ServerError.missingValue("items")
					}
					
					// Map the schedule and call the handler
					let schedule = try items.map { try ScheduleItem(serialized: $0) }
					handler(.success(schedule))
				case .failure(let error):
					throw error
				}
			} catch {
				handler(.error(error))
			}
		}
	}
}

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
	var stop: BusStop?
	
	init(serialized: [String: AnyObject]) throws {
		id = try (serialized["Id"] as? Int).unwrap("Id")
		startDate = Date(timeIntervalSince1970: try (serialized["StartDate"] as? Double).unwrap("StartDate"))
		endDate = Date(timeIntervalSince1970: try (serialized["EndDate"] as? Double).unwrap("EndDate"))
		stop = serialized["Stop"] != nil ? try BusStop(serialized: (serialized["Stop"] as? [String: AnyObject]).unwrap("Stop")) : nil
	}
}

class FoodItem {
	var id: Int
	var name: String
	var description: String
	var cost: Float
	
	init(serialized: [String: AnyObject]) throws {
		id = try (serialized["Id"] as? Int).unwrap("Id")
		name = try (serialized["Name"] as? String).unwrap("Name")
		description = try (serialized["Description"] as? String).unwrap("Description")
		cost = try (serialized["Cost"] as? Float).unwrap("Cost")
	}
}

class BusStop {
	var id: Int
	var schedule: [ScheduleItem]?
	var locationName: String
	var address: String
	
	init(serialized: [String: AnyObject]) throws {
		id = try (serialized["Id"] as? Int).unwrap("Id")
		locationName = try (serialized["LocationName"] as? String).unwrap("LocationName")
		address = try (serialized["Address"] as? String).unwrap("Address")
	}
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
	
	// MARK: Endpoints
	static func getGpsInsightToken(handler: ServerCallback<String>) {
		// Get the token
		request(.GET, "https://api.gpsinsight.com/v2/userauth/login?username=fresh_api&app_token=57925fb8ef075").responseJSON { response in
			do {
				switch response.result {
				case .success(let value):
					// Cast to JSON
					guard let json = value as? [String: AnyObject] else {
						throw ServerError.invalidData(value)
					}
					
					// Get the items
					guard let data = json["data"] as? [String: AnyObject], let token = data["token"] as? String else {
						throw ServerError.missingValue("items or token")
					}
					
					handler(.success(token))
				case .failure(let error):
					throw error
				}
			} catch {
				handler(.error(error))
			}
		}
	}
	
	static func getVehicleLocation(handler: ServerCallback<(Double, Double)>) {
		getGpsInsightToken { response in
			switch response {
			case .success(let token):
				request(.GET, "https://api.gpsinsight.com/v2/vehicle/location?token=\(token)").responseJSON { response in
					do {
						switch response.result {
						case .success(let value):
							// Cast to JSON
							guard let json = value as? [String: AnyObject] else {
								throw ServerError.invalidData(value)
							}
							
							// Get the items
							guard let data = json["data"] as? [[String: AnyObject]],
								let lat = data[0]["latitude"] as? Double,
								let long = data[0]["longitude"] as? Double else {
								throw ServerError.missingValue("items")
							}
							
							// Map the schedule and call the handler
							handler(.success((lat, long)))
						case .failure(let error):
							throw error
						}
					} catch {
						handler(.error(error))
					}
				}
			case .error(let error):
				handler(.error(error))
			}
		}
	}
	
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
	
	static func getStops(handler: ServerCallback<[BusStop]>) {
		request(.GET, "\(serverAddress)/stops").responseJSON { response in
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
					let schedule = try items.map { try BusStop(serialized: $0) }
					handler(.success(schedule))
				case .failure(let error):
					throw error
				}
			} catch {
				handler(.error(error))
			}
		}
	}
	
	static func getStop(id: Int, handler: ServerCallback<BusStop>) {
		request(.GET, "\(serverAddress)/stop/\(id)").responseJSON { response in
			do {
				switch response.result {
				case .success(let value):
					// Cast to JSON
					guard let json = value as? [String: AnyObject] else {
						throw ServerError.invalidData(value)
					}
					
					// Get the items
					guard let item = json["stop"] as? [String: AnyObject] else {
						throw ServerError.missingValue("stop")
					}
					
					// Map the schedule and call the handler
					let stop = try BusStop(serialized: item)
					handler(.success(stop))
				case .failure(let error):
					throw error
				}
			} catch {
				handler(.error(error))
			}
		}
	}
	
	static func getFoods(handler: ServerCallback<[FoodItem]>) {
		request(.GET, "\(serverAddress)/foods").responseJSON { response in
			do {
				switch response.result {
				case .success(let value):
					// Cast to JSON
					guard let json = value as? [String: AnyObject] else {
						throw ServerError.invalidData(value)
					}
					
					// Get the items
					guard let items = json["foods"] as? [[String: AnyObject]] else {
						throw ServerError.missingValue("foods")
					}
					
					// Map the schedule and call the handler
					let foods = try items.map { try FoodItem(serialized: $0) }
					handler(.success(foods))
				case .failure(let error):
					throw error
				}
			} catch {
				handler(.error(error))
			}
		}
	}
	
	// MARK: Cart
	static var cartItems: [FoodItem] = []
	static var cartHandler: (() -> Void)?
	
	static func add(item: FoodItem) {
		cartItems += [ item ]
		
		cartHandler?()
	}
	
	static func getCartTotal() -> Float {
		var total: Float = 0
		for item in cartItems {
			total += item.cost
		}
		return total
	}
}

//
//  BusStopViewController.swift
//  FreshExpress
//
//  Created by Nathan Flurry on 7/22/16.
//  Copyright © 2016 NathanFlurry. All rights reserved.
//

import UIKit
import MapKit

class BusStopViewController: UIViewController, CLLocationManagerDelegate {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var directionsButton: UIButton!
	@IBOutlet weak var mapView: MKMapView!

	var locationManager = CLLocationManager()
	
	var item: BusStop!
	var placemark: MKPlacemark?
	var userLocation: CLLocation?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Register locaiton manager events
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		
        // Clear UI
		titleLabel.text = ""
		addressLabel.text = ""
		distanceLabel.text = ""
		directionsButton.isEnabled = false
    }
	
	// MARK: Data
	func loadStop(id: Int) {
		print("load \(id)")
		Server.getStop(id: id) { response in
			print("got response \(response)")
			switch response {
			case .success(let data):
				self.processData(data: data)
			case .error(let error):
				print("Could not load data due to error \(error)")
			}
		}
	}
	
	func processData(data: BusStop) {
		// Save the data
		item = data
		
		// Update the labels
		titleLabel.text = data.locationName
		addressLabel.text = data.address
		
		// Get the longitude and latitude]
		CLGeocoder().geocodeAddressString(item.address + " Phoenix") { placemarks, error in
			guard let clPlacemark = placemarks?.last, error == nil else {
				print("There was an error getting the item \(data).")
				return
			}
			
			// Get the MKPlacemark
			self.placemark = MKPlacemark(placemark: clPlacemark)
			
			// Enable directions button
			self.directionsButton.isEnabled = true
			
			// Update the distance
			self.updateDistance()
		}
	}
	
	func updateDistance() {
		if let userLocation = userLocation, let placemark = placemark {
			let placemarkLocation = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
			let distance = userLocation.distance(from: placemarkLocation) * 0.000621371 // Distance converted from meters to miles
			distanceLabel.text = String(format: "%.1f", distance) + " miles"
		}
	}
	
	// MARK: Location manager
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		userLocation = locations[0]
		updateDistance()
	}
	
	// MARK: UI events
	@IBAction func getDirections(_ sender: AnyObject) {
		// Open the URL in maps
		UIApplication.shared().open(
			URL(string: "http://maps.apple.com/?ll=\(placemark!.coordinate.latitude),\(placemark!.coordinate.longitude)")!,
			options: [:],
			completionHandler: nil
		)
	}
}

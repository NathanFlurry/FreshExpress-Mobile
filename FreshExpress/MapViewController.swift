//
//  MapViewController.swift
//  FreshExpress
//
//  Created by Nathan Flurry on 7/22/16.
//  Copyright © 2016 NathanFlurry. All rights reserved.
//

import UIKit
import MapKit

class BusAnnotation: MKPointAnnotation {
	
}

class MapViewController: UIViewController, MKMapViewDelegate {
	let pinReuseId = "Pin"
	let busReuseId = "Bus"
	
	@IBOutlet weak var mapView: MKMapView!

	var items: [BusStop] = []
	var mapAnnotations: [MKAnnotation] = []
	
	var selectedId = -1
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Set the delegate
		mapView.delegate = self
		
		// Load the bus location
		Server.getVehicleLocation { response in
			switch response {
			case .success(let data):
				// Create the annotation
				let annotation = BusAnnotation()
				annotation.coordinate = CLLocationCoordinate2D(latitude: data.0, longitude: data.1)
				annotation.title = "The Magic Food Bus"
				
				// Add the annotation
				self.mapView.addAnnotation(annotation)
			case .error(let error):
				print("Could not get vehicle location because of error \(error)")
			}
		}
		
		// Load the items
        loadItems()
    }
	
	// MARK: Data
	func loadItems() {
		// Clear previous items
		items = []
		
		// Get the schedule
		Server.getStops { response in
			// Deal with response
			switch response {
			case .success(let items):
				self.processItems(items: items)
			case .error(let error):
				print("Could not load data due to error \(error)")
			}
		}
	}
	
	func processItems(items rawItems: [BusStop]) {
		// Save the items
		items = rawItems
		
		// Add all the stops
		for item in items {
			addStop(item: item)
		}
	}
	
	func addStop(item: BusStop) {
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(item.address + " Phoenix") { placemarks, error in
			guard let clPlacemark = placemarks?.last, error == nil else {
				print("There was an error getting the item \(item).")
				return
			}
			
			// Get the MKPlacemark
			let placemark = MKPlacemark(placemark: clPlacemark)
			
			// Create the annotation
			let annotation = MKPointAnnotation()
			annotation.coordinate = placemark.coordinate
			annotation.title = item.locationName
			annotation.subtitle = item.address
			
			// Add the annotation
			self.mapView.addAnnotation(annotation)
			self.mapAnnotations.append(annotation)
			
			// Check if all pins have been laid
			if self.mapAnnotations.count == self.items.count {
				self.mapView.showAnnotations(self.mapAnnotations, animated: true)
			}
		}
	}
	
	// MARK: Map view
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		// Make sure it's not the user's location pin
		guard !(annotation is MKUserLocation) else {
			return nil
		}
		
		if annotation is BusAnnotation { // Is a bus pin
			let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: busReuseId)
			annotationView.canShowCallout = true
			annotationView.image = UIImage(named: "Bus")
			return annotationView
		} else { // Is a bus stop pin
			let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinReuseId) as? MKPinAnnotationView ??
					MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinReuseId)
			annotationView.pinTintColor = ThemeColor
			annotationView.canShowCallout = true
			annotationView.animatesDrop = true
			
			// Create the accessory
			let button = UIButton(type: .detailDisclosure)
			button.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
			button.contentVerticalAlignment = .center
			button.contentHorizontalAlignment = .center
			
			// Set the accessory
			annotationView.rightCalloutAccessoryView = button
			
			return annotationView
		}
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		guard let annotationTitle = view.annotation?.title else {
			print("No annotation.")
			return
		}
		
		// Find the item with the same name to get its id
		for item in items { // TODO: Find a better way of uniquely identifying pins
			if annotationTitle == item.locationName {
				selectedId = item.id
				performSegue(withIdentifier: "BusStop", sender: self)
				return
			}
		}
		
		// If we're here, there was no valid pin
		print("Invalid pin selected.")
	}
	
	// MARK: UI events
	override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "BusStop" {
			let vc = segue.destinationViewController as! BusStopViewController
			vc.loadStop(id: selectedId)
			selectedId = -1
		}
	}
}

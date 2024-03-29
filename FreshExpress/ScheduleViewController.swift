//
//  ScheduleViewController.swift
//  FreshExpress
//
//  Created by Nathan Flurry on 7/22/16.
//  Copyright © 2016 NathanFlurry. All rights reserved.
//

import UIKit

class ScheduleViewController: UITableViewController {
	let cellReuseId = "Cell"
	
	let timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .none
		formatter.timeStyle = .short
		return formatter
	}()
	
	let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		return formatter
	}()
	
	var items: [[ScheduleItem]] = []
	
	var selectedId = -1
	
	// MARK: View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		loadItems()
    }
	
	// MARK: Data
	func loadItems() {
		// Clear previous items
		items = []
		tableView.reloadData()
		
		// Get the schedule
		Server.getSchedule { response in
			// Stop refreshing
			self.refreshControl?.endRefreshing()
			
			// Deal with response
			switch response {
			case .success(let items):
				self.processItems(items: items)
			case .error(let error):
				print("Could not load data due to error \(error)")
			}
		}
	}
	
	func processItems(items rawItems: [ScheduleItem]) {
		// Process the items
		var previousDate: Date?
		for item in rawItems {
			// If not the same day or the first item, then add another array of items to the items list
			if !(previousDate?.isSameDay(date: item.startDate) ?? false) {
				items += [[]]
			}
			
			// Add to the last array
			items[items.count - 1] += [ item ]
			
			// Save the previous date
			previousDate = item.startDate
		}
		
		self.tableView.reloadData()
	}
	
	// MARK: Table view
	override func numberOfSections(in tableView: UITableView) -> Int {
		return items.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return dateFormatter.string(from: items[section][0].startDate)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items[section].count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
		
		// Get the data
		let item = items[indexPath.section][indexPath.row]
		
		// Get the stop
		guard let stop = item.stop else {
			print("No bus stop.")
			return cell
		}
		
		// Process the dates
		let start = timeFormatter.string(from: item.startDate)
		let end = timeFormatter.string(from: item.endDate)
		
		// Update the cell
		cell.textLabel?.text = stop.locationName
		cell.detailTextLabel?.text = "From \(start) until \(end)"
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedId = items[indexPath.section][indexPath.row].id
		performSegue(withIdentifier: "BusStop", sender: self)
	}
	
	// MARK: UI events
	@IBAction func didRefresh(_ sender: UIRefreshControl) {
		loadItems()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "BusStop" {
			let vc = segue.destinationViewController as! BusStopViewController
			vc.loadStop(id: selectedId)
			selectedId = -1
		}
	}
}

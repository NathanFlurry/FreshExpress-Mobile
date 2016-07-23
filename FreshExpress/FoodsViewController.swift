//
//  FoodsViewController.swift
//  FreshExpress
//
//  Created by Nathan Flurry on 7/22/16.
//  Copyright © 2016 NathanFlurry. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {
	var handler: ((FoodTableViewCell) -> Void)?
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var addButton: RoundButton!
	
	@IBAction func addPressed(_ sender: AnyObject) {
		handler?(self)
	}
}

class FoodsViewController: UITableViewController {
	let cellReuseId = "Cell"
	
	var items: [FoodItem] = []
	
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
		Server.getFoods { response in
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
	
	func processItems(items rawItems: [FoodItem]) {
		// Process the items
		self.items = rawItems
		self.tableView.reloadData()
	}
	
	// MARK: Table view
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath) as! FoodTableViewCell
		
		// Get the data
		let item = items[indexPath.row]
		
		// Update the cell
		cell.nameLabel.text = item.name
		cell.priceLabel.text = String(format: "$%.2f", item.cost)
		
		// Add an event
		cell.handler = addPressed
		
		return cell
	}
	
	func addPressed(cell: FoodTableViewCell) {
		guard let indexPath = tableView.indexPath(for: cell) else {
			print("No index path for cell \(cell)")
			return
		}
		
		Server.add(item: items[indexPath.row])
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
	// MARK: UI events
	@IBAction func didRefresh(_ sender: UIRefreshControl) {
		loadItems()
	}
}

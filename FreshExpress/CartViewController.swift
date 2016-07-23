//
//  CartViewController.swift
//  FreshExpress
//
//  Created by Nathan Flurry on 7/23/16.
//  Copyright © 2016 NathanFlurry. All rights reserved.
//

import UIKit

class CartCheckoutCell: UITableViewCell {
	var handler: ((CartCheckoutCell) -> Void)?
	
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var checkoutButton: UIButton!
	
	@IBAction func checkoutTapped(_ sender: AnyObject) {
		handler?(self)
	}
}

class CartViewController: UITableViewController {
	let itemCellId = "ItemCell"
	let checkoutCellId = "CheckoutCell"
	
	var cartItems: [FoodItem] {
		return Server.cartItems
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Automatically size rows
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 44
		
		// For deletion
		tableView.allowsSelectionDuringEditing = false
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Register the cart handler
		Server.cartHandler = cartUpdate
		
		// Update badge
		updateBadge()
	}
	
	// MARK: Data
	func cartUpdate() {
		// Reload data
		tableView.reloadData()
		
		// Update badge
		updateBadge()
	}
	
	func updateBadge() {
		navigationController?.tabBarItem.badgeValue = cartItems.count > 0 ? String(cartItems.count) : nil
	}
	
	// MARK: Table view
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Server.cartItems.count + 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row < cartItems.count {
			let cell = tableView.dequeueReusableCell(withIdentifier: itemCellId, for: indexPath)
			
			// Get the data
			let item = cartItems[indexPath.row]
			
			// Set the data
			cell.textLabel?.text = "A pound of " + item.name
			cell.detailTextLabel?.text = String(format: "$%.2f", item.cost)
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: checkoutCellId, for: indexPath) as! CartCheckoutCell
			
			// Set the total
			cell.totalLabel.text = String(format: "$%.2f", Server.getCartTotal())
			
			// Enable if enough items
			cell.checkoutButton.isEnabled = cartItems.count > 0
			
			// Set the handler
			cell.handler = checkoutTapped
			
			return cell
		}
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return indexPath.row != cartItems.count
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == UITableViewCellEditingStyle.delete {
			// Remove the item
			Server.cartItems.remove(at: indexPath.row)
			
			// Reload
			tableView.reloadData()
			updateBadge()
		}
	}
	
	func checkoutTapped(cell: CartCheckoutCell) {
		let alertController = UIAlertController(title: "Order Placed", message: "Please pick up your order at the nearest location.", preferredStyle: .alert)
		alertController.addAction(
			UIAlertAction(title: "OK", style: .cancel) { alert in
				// Clear the cart
				Server.cartItems = []
				Server.cartHandler?()
			}
		)
		present(alertController, animated: true, completion: nil)
	}
}

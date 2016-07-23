//
//  RoundButton.swift
//  FreshExpress
//
//  Created by Nathan Flurry on 7/23/16.
//  Copyright © 2016 NathanFlurry. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let cornerRadius: CGFloat
		if bounds.width < bounds.height {
			cornerRadius = bounds.width / 2
		} else {
			cornerRadius = bounds.height / 2
		}
		layer.cornerRadius = cornerRadius
		layer.masksToBounds = true
	}
}

//
//  AnimatedTractorView.swift
//  FreshExpress
//
//  Created by Nathan Flurry on 7/23/16.
//  Copyright © 2016 NathanFlurry. All rights reserved.
//

import UIKit
import SpriteKit

class AnimatedTractorView: SKView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	private func setup() {
		// Setup scene
		allowsTransparency = true
		backgroundColor = UIColor.clear()
		
		// Load the scene
		let scene = SKScene(fileNamed: "FreshExpressScene.sks")
		scene?.backgroundColor = UIColor.clear()
		presentScene(scene)
	}
}

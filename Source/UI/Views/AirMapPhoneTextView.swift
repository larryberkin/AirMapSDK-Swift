//
//  AirMapPhoneTextView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

class AirMapPhoneTextView: UITextView {
	
	// Prevent the user from performing the following actions
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		if action == #selector(UITextView.select)
			|| action == #selector(UITextView.selectAll)
			|| action == #selector(UITextView.cut)
			|| action == #selector(UITextView.paste(_:))
			|| action == #selector(UITextView.delete)
		{
			return false
		} else {
			return super.canPerformAction(action, withSender: sender)
		}
	}
}

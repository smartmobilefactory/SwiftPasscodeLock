//
//  PasscodeSignButton.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

public class PasscodeSignButton: UIButton {
    
    public var passcodeSign: String = "1"
	public var customTintColor: UIColor? = UIColor(red: 0, green: 100/255, blue: 165/255, alpha: 1)

	public override func awakeFromNib() {
		super.awakeFromNib()

		self.tintColor = customTintColor
	}
}

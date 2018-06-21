//
//  SetPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import UIKit

struct SetPasscodeState: PasscodeLockStateType {
    
    let title				: String
    let description			: String
    let isCancellableAction = true
    var isTouchIDAllowed 	= false
	var tintColor			: UIColor?
	var font				: UIFont?
    
	init(title: String, description: String, tintColor: UIColor?, font: UIFont?) {

		let defaultColor = defaultCustomColor()
        self.title = title
        self.description = description
		self.tintColor = (tintColor ?? defaultColor)
		self.font = (font ?? UIFont.systemFont(ofSize: 16))
    }

	init(stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {

		let defaultColor = defaultCustomColor()
        self.title = (stringsToShow?.passcodeLockSetTitle ?? localizedStringFor("PasscodeLockSetTitle", comment: "Set passcode title"))
        self.description = (stringsToShow?.passcodeLockSetDescription ?? localizedStringFor("PasscodeLockSetDescription", comment: "Set passcode description"))
		self.tintColor = (tintColor ?? defaultColor)
		self.font = (font ?? UIFont.systemFont(ofSize: 16))
    }
    
	func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
        
		let nextState = ConfirmPasscodeState(passcode: passcode, stringsToShow: stringsToShow, tintColor: tintColor, font: font)
        lock.changeStateTo(nextState)
    }
}

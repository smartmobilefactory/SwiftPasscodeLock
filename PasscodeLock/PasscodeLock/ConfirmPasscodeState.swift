//
//  ConfirmPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import UIKit

struct ConfirmPasscodeState: PasscodeLockStateType {
    
    let title				: String
    let description			: String
    let isCancellableAction = true
    var isTouchIDAllowed 	= false
	var tintColor			: UIColor?
	var font				: UIFont?
    
    fileprivate var passcodeToConfirm: [String]
    
	init(passcode: [String], stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {

		let defaultColor = defaultCustomColor()
        self.passcodeToConfirm = passcode
        self.title = (stringsToShow?.passcodeLockConfirmTitle ?? localizedStringFor("PasscodeLockConfirmTitle", comment: "Confirm passcode title"))
        self.description = (stringsToShow?.passcodeLockConfirmDescription ?? localizedStringFor("PasscodeLockConfirmDescription", comment: "Confirm passcode description"))
		self.tintColor = (tintColor ?? defaultColor)
		self.font = (font ?? UIFont.systemFont(ofSize: 16))
    }
    
	func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
        
        if (passcode == passcodeToConfirm) {
            lock.repository.savePasscode(passcode)
            lock.delegate?.passcodeLockDidSucceed(lock)
        
        } else {
            
            let mismatchTitle = (stringsToShow?.passcodeLockMismatchTitle ?? localizedStringFor("PasscodeLockMismatchTitle", comment: "Passcode mismatch title"))
            let mismatchDescription = (stringsToShow?.passcodeLockMismatchDescription ?? localizedStringFor("PasscodeLockMismatchDescription", comment: "Passcode mismatch description"))
			let nextState = SetPasscodeState(title: mismatchTitle, description: mismatchDescription, tintColor: tintColor, font: font)
            lock.changeStateTo(nextState)
            lock.delegate?.passcodeLockDidFail(lock)
        }
    }
}

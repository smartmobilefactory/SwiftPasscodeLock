//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

public let PasscodeLockIncorrectPasscodeNotification = "passcode.lock.incorrect.passcode.notification"

struct EnterPasscodeState: PasscodeLockStateType {
    
    let title				: String
    let description			: String
    let isCancellableAction	: Bool
    var isTouchIDAllowed 	= true
	var tintColor			: UIColor?
	var font				: UIFont?
    
    fileprivate var inccorectPasscodeAttempts = 0
    fileprivate var isNotificationSent = false
    
	init(allowCancellation: Bool = false, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {

		let defaultColor = defaultCustomColor()
        self.isCancellableAction = allowCancellation
        self.title = (stringsToShow?.passcodeLockEnterTitle ?? localizedStringFor("PasscodeLockEnterTitle", comment: "Enter passcode title"))
        self.description = (stringsToShow?.passcodeLockEnterDescription ?? localizedStringFor("PasscodeLockEnterDescription", comment: "Enter passcode description"))
		self.tintColor = (tintColor ?? defaultColor)
		self.font = (font ?? UIFont.systemFont(ofSize: 16))
    }
    
	mutating func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
        
        guard let currentPasscode = lock.repository.passcode else {
            return
        }
        
        if (passcode == currentPasscode) {
            lock.delegate?.passcodeLockDidSucceed(lock)
            
        } else {
            
            inccorectPasscodeAttempts += 1
            if (inccorectPasscodeAttempts >= lock.configuration.maximumInccorectPasscodeAttempts) {
                postNotification()
            }
            
            lock.delegate?.passcodeLockDidFail(lock)
        }
    }
    
    fileprivate mutating func postNotification() {
        
        guard !isNotificationSent else { return }
            
        let center = NotificationCenter.default
        center.post(name: Notification.Name(rawValue: PasscodeLockIncorrectPasscodeNotification), object: nil)
        self.isNotificationSent = true
    }
}

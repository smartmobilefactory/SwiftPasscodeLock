//
//  FakePasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import PasscodeLock

class FakePasscodeState: PasscodeLockStateType {

    var title = "A"
    var description = "B"
    var isCancellableAction = true
    var isTouchIDAllowed = true
	var tintColor: UIColor?

    var acceptPaccodeCalled = false
    var acceptedPasscode = [String]()
    var numberOfAcceptedPasscodes = 0

    init() {}

	func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
		acceptedPasscode = passcode
		acceptPaccodeCalled = true
		numberOfAcceptedPasscodes += 1
	}
}

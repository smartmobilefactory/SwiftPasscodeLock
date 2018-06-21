//
//  FakePasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import PasscodeLock

class FakePasscodeLock: PasscodeLockType {

    weak var delegate: PasscodeLockTypeDelegate?
    let configuration: PasscodeLockConfigurationType
    var repository: PasscodeRepositoryType { return configuration.repository }
    var state: PasscodeLockStateType { return lockState }
    let isTouchIDAllowed = false
    var lockState: PasscodeLockStateType
	var isPincodeEmpty: Bool = false
    
    var changeStateCalled = false
    
    init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType) {
        
        self.lockState = state
        self.configuration = configuration
    }
    
	func addSign(_ sign: String, stringsToBeDisplayed: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
        
    }
    
    func removeSign() {
        
    }
    
    func changeStateTo(_ state: PasscodeLockStateType) {
        
        lockState = state
        changeStateCalled = true
        delegate?.passcodeLockDidChangeState(self)
    }

	func authenticateWithBiometrics(_ stringsToShow: StringsToBeDisplayed?) {
        
    }
}

//
//  PasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit
import LocalAuthentication

open class PasscodeLock: PasscodeLockType {
    
    open weak var delegate: PasscodeLockTypeDelegate?
    open let configuration: PasscodeLockConfigurationType
    
    open var repository: PasscodeRepositoryType {
        return configuration.repository
    }
    
    open var state: PasscodeLockStateType {
        return lockState
    }
    
    open var isTouchIDAllowed: Bool {
        return isTouchIDEnabled() && configuration.isTouchIDAllowed && lockState.isTouchIDAllowed
    }

	open var isPincodeEmpty: Bool {
		return passcode.isEmpty
	}
    
    fileprivate var lockState: PasscodeLockStateType
    fileprivate lazy var passcode = [String]()
    
    public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType) {
        
        precondition(configuration.passcodeLength > 0, "Passcode length sould be greather than zero.")
        
        self.lockState = state
        self.configuration = configuration
    }
    
	open func addSign(_ sign: String, stringsToBeDisplayed: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
        
        passcode.append(sign)
        delegate?.passcodeLock(self, addedSignAtIndex: passcode.count - 1)
        
        if (passcode.count >= configuration.passcodeLength) {

			self.lockState.acceptPasscode(self.passcode, fromLock: self, stringsToShow: stringsToBeDisplayed, tintColor: tintColor, font: font)
			self.passcode.removeAll(keepingCapacity: true)
        }
    }
    
    open func removeSign() {
        
        guard passcode.count > 0 else { return }
        
        passcode.removeLast()
        delegate?.passcodeLock(self, removedSignAtIndex: passcode.count)
    }
    
    open func changeStateTo(_ state: PasscodeLockStateType) {
        
        lockState = state
        delegate?.passcodeLockDidChangeState(self)
    }
    
	open func authenticateWithBiometrics(_ stringsToShow: StringsToBeDisplayed?) {
        
        guard isTouchIDAllowed else { return }
        
        let context = LAContext()
        let reason = (stringsToShow?.passcodeLockTouchIDReason ?? localizedStringFor("PasscodeLockTouchIDReason", comment: "TouchID authentication reason"))

        context.localizedFallbackTitle = (stringsToShow?.passcodeLockTouchIDButton ?? localizedStringFor("PasscodeLockTouchIDButton", comment: "TouchID authentication fallback button"))
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            success, error in
            
            self.handleTouchIDResult(success)
        }
    }
    
    fileprivate func handleTouchIDResult(_ success: Bool) {
        
        DispatchQueue.main.async {
            
            if success {
                
                self.delegate?.passcodeLockDidSucceed(self)
            }
        }
    }
    
    fileprivate func isTouchIDEnabled() -> Bool {
        
        let context = LAContext()
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}

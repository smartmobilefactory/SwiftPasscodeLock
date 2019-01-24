//
//  PasscodeLockPresenter.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

public struct StringsToBeDisplayed {

	public var passcodeLockEnterTitle: 				String?
	public var passcodeLockEnterDescription:		String?
	public var passcodeLockSetTitle:				String?
	public var passcodeLockSetDescription:			String?
	public var passcodeLockConfirmTitle:			String?
	public var passcodeLockConfirmDescription: 		String?

	public var passcodeLockChangeTitle: 			String?
	public var passcodeLockChangeDescription: 		String?
	public var passcodeLockMismatchTitle:			String?
	public var passcodeLockMismatchDescription:		String?
	public var passcodeLockTouchIDReason:			String?
	public var passcodeLockTouchIDButton:			String?

	public var cancel:								String?
	public var delete:								String?
	public var useTouchID:							String?
	public var useFaceID:							String?

	public init(passcodeLockEnterTitle: String?, passcodeLockEnterDescription: String?, passcodeLockSetTitle: String?, passcodeLockSetDescription: String?, passcodeLockConfirmTitle: String?, passcodeLockConfirmDescription: String?, passcodeLockChangeTitle: String?,  passcodeLockChangeDescription: String?, passcodeLockMismatchTitle: String?, passcodeLockMismatchDescription: String?, passcodeLockTouchIDReason: String?, passcodeLockTouchIDButton: String?, cancel: String?, delete: String?, useTouchID: String?, useFaceID: String?) {

		self.passcodeLockEnterTitle = passcodeLockEnterTitle
		self.passcodeLockEnterDescription = passcodeLockEnterDescription
		self.passcodeLockSetTitle = passcodeLockSetTitle
		self.passcodeLockSetDescription = passcodeLockSetDescription
		self.passcodeLockConfirmTitle = passcodeLockConfirmTitle
		self.passcodeLockConfirmDescription = passcodeLockConfirmDescription
		self.passcodeLockChangeTitle = passcodeLockChangeTitle
		self.passcodeLockChangeDescription = passcodeLockChangeDescription
		self.passcodeLockMismatchTitle = passcodeLockMismatchTitle
		self.passcodeLockMismatchDescription = passcodeLockMismatchDescription
		self.passcodeLockTouchIDReason = passcodeLockTouchIDReason
		self.passcodeLockTouchIDButton = passcodeLockTouchIDButton
		self.cancel = cancel
		self.delete = delete
		self.useTouchID = useTouchID
		self.useFaceID = useFaceID
	}
}

open class PasscodeLockPresenter {
    
    fileprivate var mainWindow: UIWindow?
    
    open lazy var passcodeLockWindow: UIWindow = {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.windowLevel = UIWindow.Level.normal
        window.makeKeyAndVisible()
        
        return window
    }()
    
    fileprivate let passcodeConfiguration: PasscodeLockConfigurationType
    open var isPasscodePresented = false
    public let passcodeLockVC: PasscodeLockViewController
	open var stringsToBeDisplayed: StringsToBeDisplayed?
    
    public init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType, viewController: PasscodeLockViewController) {
        
        mainWindow = window
        passcodeConfiguration = configuration
        passcodeLockVC = viewController
    }

	public convenience init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
        
		let passcodeLockVC = PasscodeLockViewController(state: .enterPasscode, configuration: configuration, stringsToShow: stringsToShow, tintColor: tintColor, font: font)

        self.init(mainWindow: window, configuration: configuration, viewController: passcodeLockVC)
    }
    
	open func presentPasscodeLock(withImage image: UIImage? = nil, configuration config: PasscodeLockConfigurationType? = nil, andStrings stringsToShow: StringsToBeDisplayed? = nil, tintColor: UIColor?, font: UIFont?, dismissCompletionBlock: (() -> Void)? = nil) {
        
        guard passcodeConfiguration.repository.hasPasscode else { return }
        guard !isPasscodePresented else { return }
        
        isPasscodePresented = true
        
        passcodeLockWindow.windowLevel = UIWindow.Level.statusBar
        passcodeLockWindow.isHidden = false
        
        mainWindow?.endEditing(true)

		let passcodeLockVC = PasscodeLockViewController(state: .enterPasscode, configuration: (config ?? passcodeConfiguration), stringsToShow: stringsToShow, tintColor: tintColor, font: font)
		if (image != nil) {
			passcodeLockVC.customImage = image
		}
        let userDismissCompletionCallback = passcodeLockVC.dismissCompletionCallback
        
        passcodeLockVC.dismissCompletionCallback = { [weak self] in
			dismissCompletionBlock?()
            userDismissCompletionCallback?()
            self?.dismissPasscodeLock()

        }
        
        passcodeLockWindow.rootViewController = passcodeLockVC
    }
    
    open func dismissPasscodeLock(animated: Bool = true) {
        
        isPasscodePresented = false
        mainWindow?.makeKeyAndVisible()
        
        if animated {
        
            animatePasscodeLockDismissal()
            
        } else {
            
            passcodeLockWindow.windowLevel = UIWindow.Level.normal
            passcodeLockWindow.rootViewController = nil
			passcodeLockWindow.isHidden = true
        }
    }
    
    internal func animatePasscodeLockDismissal() {
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: UIView.AnimationOptions(),
            animations: { [weak self] in
                
                self?.passcodeLockWindow.alpha = 0
            },
            completion: { [weak self] _ in
                
                self?.passcodeLockWindow.windowLevel = UIWindow.Level.normal
                self?.passcodeLockWindow.rootViewController = nil
				self?.passcodeLockWindow.isHidden = true
                self?.passcodeLockWindow.alpha = 1
            }
        )
    }
}

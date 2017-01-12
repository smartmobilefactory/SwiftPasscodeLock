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

	public init(passcodeLockEnterTitle: String?, passcodeLockEnterDescription: String?, passcodeLockSetTitle: String?, passcodeLockSetDescription: String?, passcodeLockConfirmTitle: String?, passcodeLockConfirmDescription: String?, passcodeLockChangeTitle: String?,  passcodeLockChangeDescription: String?, passcodeLockMismatchTitle: String?, passcodeLockMismatchDescription: String?, passcodeLockTouchIDReason: String?, passcodeLockTouchIDButton: String?, cancel: String?, delete: String?, useTouchID: String?) {

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
	}
}

public class PasscodeLockPresenter {
    
    private var mainWindow: UIWindow?
    
    private lazy var passcodeLockWindow: UIWindow = {
        
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window.windowLevel = 0
        window.makeKeyAndVisible()
        
        return window
    }()
    
    private let passcodeConfiguration: PasscodeLockConfigurationType
    public var isPasscodePresented = false
    public let passcodeLockVC: PasscodeLockViewController
	public var stringsToBeDisplayed: StringsToBeDisplayed?
    
    public init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType, viewController: PasscodeLockViewController) {
        
        mainWindow = window
        mainWindow?.windowLevel = 1
        passcodeConfiguration = configuration
        passcodeLockVC = viewController
    }

	public convenience init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
        
		let passcodeLockVC = PasscodeLockViewController(state: .EnterPasscode, configuration: configuration, stringsToShow: stringsToShow, tintColor: tintColor, font: font)

        self.init(mainWindow: window, configuration: configuration, viewController: passcodeLockVC)
    }
    
	public func presentPasscodeLock(withImage image: UIImage? = nil, andStrings stringsToShow: StringsToBeDisplayed? = nil, tintColor: UIColor?, font: UIFont?, dismissCompletionBlock: (() -> Void)? = nil) {
        
        guard passcodeConfiguration.repository.hasPasscode else { return }
        guard !isPasscodePresented else { return }
        
        isPasscodePresented = true
        
        passcodeLockWindow.windowLevel = 2
        passcodeLockWindow.hidden = false
        
        mainWindow?.windowLevel = 1
        mainWindow?.endEditing(true)

		let passcodeLockVC = PasscodeLockViewController(state: .EnterPasscode, configuration: passcodeConfiguration, stringsToShow: stringsToShow, tintColor: tintColor, font: font)
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
    
    public func dismissPasscodeLock(animated animated: Bool = true) {
        
        isPasscodePresented = false
        mainWindow?.windowLevel = 1
        mainWindow?.makeKeyAndVisible()
        
        if animated {
        
            animatePasscodeLockDismissal()
            
        } else {
            
            passcodeLockWindow.windowLevel = 0
            passcodeLockWindow.rootViewController = nil
        }
    }
    
    internal func animatePasscodeLockDismissal() {
        
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.CurveEaseInOut],
            animations: { [weak self] in
                
                self?.passcodeLockWindow.alpha = 0
            },
            completion: { [weak self] _ in
                
                self?.passcodeLockWindow.windowLevel = 0
                self?.passcodeLockWindow.rootViewController = nil
                self?.passcodeLockWindow.alpha = 1
            }
        )
    }
}

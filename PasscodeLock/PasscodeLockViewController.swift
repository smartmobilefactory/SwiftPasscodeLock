//
//  PasscodeLockViewController.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit
import LocalAuthentication

open class PasscodeLockViewController: UIViewController, PasscodeLockTypeDelegate {
    
    public enum LockState {
        case enterPasscode
        case setPasscode
        case changePasscode
        case removePasscode
        
		func getState(_ stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) -> PasscodeLockStateType {
            
            switch self {
			case .enterPasscode: 	return EnterPasscodeState(stringsToShow: stringsToShow, tintColor: tintColor, font: font)
			case .setPasscode: 		return SetPasscodeState(stringsToShow: stringsToShow, tintColor: tintColor, font: font)
			case .changePasscode: 	return ChangePasscodeState(stringsToShow: stringsToShow, tintColor: tintColor, font: font)
			case .removePasscode: 	return EnterPasscodeState(allowCancellation: true, stringsToShow: stringsToShow, tintColor: tintColor, font: font)
            }
        }
    }
    
	@IBOutlet open var passcodeButtons				: [PasscodeSignButton]?
    @IBOutlet open weak var titleLabel				: UILabel?
	@IBOutlet open weak var customImageView			: UIImageView?
    @IBOutlet open weak var descriptionLabel			: UILabel?
    @IBOutlet open var placeholders					: [PasscodeSignPlaceholderView] = [PasscodeSignPlaceholderView]()
	@IBOutlet open weak var cancelDeleteButton		: UIButton?
    @IBOutlet open weak var touchIDButton				: UIButton?
    @IBOutlet open weak var placeholdersX				: NSLayoutConstraint?
    
    open var successCallback							: ((_ lock: PasscodeLockType) -> Void)?
	open var customImage 								: UIImage?
    open var dismissCompletionCallback				: (()->Void)?
    open var animateOnDismiss							: Bool
    open var notificationCenter						: NotificationCenter?
	open var stringsToShow							: StringsToBeDisplayed?
	open var closingView								: Bool = false
    
    internal let passcodeConfiguration					: PasscodeLockConfigurationType
    internal var passcodeLock							: PasscodeLockType
    internal var isPlaceholdersAnimationCompleted 		= true
    
    fileprivate var shouldTryToAuthenticateWithBiometrics 	= true
	fileprivate var customTintColor							: UIColor?
	fileprivate var font 									: UIFont?
    
    // MARK: - Initializers
    
	public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true, stringToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {

		self.stringsToShow = stringToShow
        self.animateOnDismiss = animateOnDismiss
		self.font = (font ?? UIFont.systemFont(ofSize: 16))
		self.customTintColor = (tintColor ?? UIColor(red: 0, green: 100/255, blue: 165/255, alpha: 1))
        passcodeConfiguration = configuration
        passcodeLock = PasscodeLock(state: state, configuration: configuration)
        let nibName = "PasscodeLockView"
        let bundle: Bundle = bundleForResource(nibName, ofType: "nib")
        
        super.init(nibName: nibName, bundle: bundle)
        passcodeLock.delegate = self
        notificationCenter = NotificationCenter.default
    }
    
	public convenience init(state: LockState, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true, stringsToShow: StringsToBeDisplayed?, tintColor: UIColor?, font: UIFont?) {
        
        self.init(state: state.getState(stringsToShow, tintColor: tintColor, font: font), configuration: configuration, animateOnDismiss: animateOnDismiss, stringToShow: stringsToShow, tintColor: tintColor, font: font)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        clearEvents()
    }
    
    // MARK: - View
    
    open override func viewDidLoad() {
        super.viewDidLoad()

		self.configurePasscodeButtons()
        self.updatePasscodeView()
        self.setupEvents()
    }

	fileprivate func configurePasscodeButtons() {

		self.placeholders.forEach { (passcodePlaceHolder: PasscodeSignPlaceholderView) in
			if let _customTintColor = self.customTintColor {
				passcodePlaceHolder.activeColor = _customTintColor
			}
			passcodePlaceHolder.setupView()
		}
	}
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldTryToAuthenticateWithBiometrics {
            authenticateWithBiometrics()
        }
    }
    
	internal func updatePasscodeView() {

		self.customImageView?.image = self.customImage
		self.titleLabel?.text = passcodeLock.state.title
		self.titleLabel?.font = self.font
		self.titleLabel?.textColor = self.customTintColor
		self.descriptionLabel?.text = passcodeLock.state.description
		self.touchIDButton?.isHidden = !passcodeLock.isTouchIDAllowed

		var useBiometrics: String = localizedStringFor("UseTouchId", comment: "")
		var useBiomatricsToShow: String? = self.stringsToShow?.useTouchID
		if #available(iOS 11.0, *) {
			let context = LAContext()
			context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
			let bioType = context.biometryType
			if (bioType == .faceID) {
				useBiometrics = localizedStringFor("UseFaceId", comment: "")
				useBiomatricsToShow = self.stringsToShow?.useFaceID
			}
		}

		self.touchIDButton?.setTitle((useBiomatricsToShow ?? useBiometrics), for: UIControl.State())
		self.passcodeButtons?.forEach({ (passcodeButton: PasscodeSignButton) in
			passcodeButton.tintColor = self.customTintColor
		})

		self.cancelDeleteButtonSetup()
	}
    
    // MARK: - Events
    
    fileprivate func setupEvents() {
        
        notificationCenter?.addObserver(self, selector: #selector(self.appWillEnterForegroundHandler(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appDidEnterBackgroundHandler(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    fileprivate func clearEvents() {
        
        notificationCenter?.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter?.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc open func appWillEnterForegroundHandler(_ notification: Notification) {
        
        authenticateWithBiometrics()
    }
    
    @objc open func appDidEnterBackgroundHandler(_ notification: Notification) {
        
        shouldTryToAuthenticateWithBiometrics = false
    }
    
    // MARK: - Actions
    
    @IBAction func passcodeSignButtonTap(_ sender: PasscodeSignButton) {
        
        guard isPlaceholdersAnimationCompleted else {
			return
		}
        
        passcodeLock.addSign(sender.passcodeSign, stringsToBeDisplayed: self.stringsToShow, tintColor: customTintColor, font: font)
    }
    
    @IBAction func cancelButtonTap(_ sender: UIButton) {
        
        dismissPasscodeLock(passcodeLock)
    }
    
    @IBAction func deleteSignButtonTap(_ sender: UIButton) {

		if (passcodeLock.isPincodeEmpty == true && passcodeLock.state.isCancellableAction == true) {
			dismissPasscodeLock(passcodeLock)

		} else {
			passcodeLock.removeSign()
		}
    }
    
    @IBAction func touchIDButtonTap(_ sender: UIButton) {
        
        passcodeLock.authenticateWithBiometrics(self.stringsToShow)
    }
    
    fileprivate func authenticateWithBiometrics() {
        
        if (passcodeConfiguration.shouldRequestTouchIDImmediately == true && passcodeLock.isTouchIDAllowed == true) {
            passcodeLock.authenticateWithBiometrics(self.stringsToShow)
        }
    }
    
    internal func dismissPasscodeLock(_ lock: PasscodeLockType, completionHandler: (() -> Void)? = nil) {
        
        // if presented as modal
        if (presentingViewController?.presentedViewController == self) {
            
            dismiss(animated: animateOnDismiss, completion: { [weak self] in
                self?.dismissCompletionCallback?()
                completionHandler?()
            })
            
            return
            
        // if pushed in a navigation controller
        } else if navigationController != nil {
            navigationController?.popViewController(animated: animateOnDismiss)
        }
        
        dismissCompletionCallback?()
        completionHandler?()
    }
    
    // MARK: - Animations
    
    internal func animateWrongPassword() {

		self.cancelDeleteButtonSetup()
        isPlaceholdersAnimationCompleted = false
        
        animatePlaceholders(placeholders, toState: .error)
        
        placeholdersX?.constant = -40
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: {
                self.placeholdersX?.constant = 0
                self.view.layoutIfNeeded()

		}, completion: { completed in
                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(self.placeholders, toState: .inactive)
        })
    }
    
    internal func animatePlaceholders(_ placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {
        
        for placeholder in placeholders {
            placeholder.animateState(state)
        }
    }
    
    fileprivate func animatePlacehodlerAtIndex(_ index: Int, toState state: PasscodeSignPlaceholderView.State) {
        
        guard (index < placeholders.count && index >= 0) else {
			return
		}

        placeholders[index].animateState(state)
    }

    // MARK: - PasscodeLockDelegate
    
    open func passcodeLockDidSucceed(_ lock: PasscodeLockType) {

		self.cancelDeleteButtonSetup()
        animatePlaceholders(placeholders, toState: .inactive)
        dismissPasscodeLock(lock, completionHandler: { [weak self] in
            self?.successCallback?(lock)
        })
    }
    
    open func passcodeLockDidFail(_ lock: PasscodeLockType) {
        
        animateWrongPassword()
    }
    
    open func passcodeLockDidChangeState(_ lock: PasscodeLockType) {
        
        updatePasscodeView()
        animatePlaceholders(placeholders, toState: .inactive)
		self.cancelDeleteButtonSetup()
    }
    
    open func passcodeLock(_ lock: PasscodeLockType, addedSignAtIndex index: Int) {
        
        animatePlacehodlerAtIndex(index, toState: .active)
		self.cancelDeleteButtonSetup()
    }
    
    open func passcodeLock(_ lock: PasscodeLockType, removedSignAtIndex index: Int) {
        
        animatePlacehodlerAtIndex(index, toState: .inactive)
        
        if (index == 0) {
            self.cancelDeleteButtonSetup()
        }
    }

	open func cancelDeleteButtonSetup() {
		
		let cancelButton = ((self.passcodeLock.isPincodeEmpty == true) ? (self.stringsToShow?.cancel ?? localizedStringFor("Cancel", comment: "")) : (self.stringsToShow?.delete ?? localizedStringFor("Delete", comment: "")))
		let titleForButton = ((self.passcodeLock.state.isCancellableAction == true) ? cancelButton : (self.stringsToShow?.delete ?? localizedStringFor("Delete", comment: "")))
		self.cancelDeleteButton?.setTitle(titleForButton, for: UIControl.State())
		self.cancelDeleteButton?.setTitleColor(self.customTintColor, for: UIControl.State())
		self.cancelDeleteButton?.setTitleColor(self.customTintColor?.withAlphaComponent(0.5), for: .disabled)
		self.cancelDeleteButton?.titleLabel?.font = self.font

		if (self.passcodeLock.isPincodeEmpty == true && self.passcodeLock.state.isCancellableAction == false) {
			self.cancelDeleteButton?.isEnabled = false
		} else {
			self.cancelDeleteButton?.isEnabled = true
		}
	}
}

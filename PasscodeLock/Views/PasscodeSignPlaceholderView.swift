//
//  PasscodeSignPlaceholderView.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

@IBDesignable
open class PasscodeSignPlaceholderView: UIView {
    
    public enum State {
        case inactive
        case active
        case error
    }

	@IBInspectable
	open var inactiveColor: UIColor = UIColor.white {
		didSet {
			self.setupView()
		}
	}

	@IBInspectable
	open var activeColor: UIColor = UIColor.gray {
		didSet {
			self.setupView()
		}
	}

	@IBInspectable
	open var errorColor: UIColor = UIColor.red {
		didSet {
			self.setupView()
		}
	}

	var currentState = State.inactive

    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    open override var intrinsicContentSize : CGSize {
        
        return CGSize(width: 16, height: 16)
    }
    
	func setupView() {
        
        layer.cornerRadius = 7
        layer.borderWidth = 1
        layer.borderColor = activeColor.cgColor
        backgroundColor = inactiveColor
    }
    
    fileprivate func colorsForState(_ state: State) -> (backgroundColor: UIColor, borderColor: UIColor) {
        
        switch state {
        case .inactive: return (inactiveColor, activeColor)
        case .active: return (activeColor, activeColor)
        case .error: return (errorColor, errorColor)
        }
    }
    
	open func animateState(_ state: State, completion: (() -> Void)? = nil) {

		self.currentState = state
		let colors = colorsForState(state)

		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { [weak self] in
			self?.backgroundColor = colors.backgroundColor
			self?.layer.borderColor = colors.borderColor.cgColor

		}, completion: nil)
	}

}


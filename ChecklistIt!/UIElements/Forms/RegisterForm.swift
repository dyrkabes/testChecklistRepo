//
//  RegisterForm.swift
//  ChecklistIt!
//
//  Created by Anastasia Pavel Stepanov on 06.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

// TODO: Refactor this to be reusable.
// TODO: dispose when hidden. Or reuse with singleton
// This view is a mess. Trying to refactor it

//TODO: Label shifts from left below
class RegisterForm: UIView {
	var state: RegisterFormState = .noState
	
	weak var parentView: UIView!
	
	var usernameField = UITextField()
	var passwordField = UITextField()
	var submitButton = UIButton()
	var blurEffectView: UIVisualEffectView!
    
    var tapParentGestureRecognizer: UITapGestureRecognizer?
    
	
    // For the first time animation
	let caption = UILabel()
	
	let disposeBag = DisposeBag()
	
// separate
    // not sure it is a good practice. 
	func addToParentView(parentView: UIView, peeking: Bool = false) {
//		super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		self.parentView = parentView
		parentView.addSubview(self)
		
		if peeking {
			createPeekingRegisterView()
			self.addSubview(caption)
			caption.snp.makeConstraints{
				(make) -> Void in
				make.height.equalTo(33)
				make.centerY.equalTo(self.snp.centerY)
				make.centerX.equalTo(self.snp.centerX)
			}
			self.parentView.layoutIfNeeded()
		} else {
			createFlatRegisterView()
		}
	}

// MARK:- Peeking. With Animation
// Appears only on the first start
	func createPeekingRegisterView() {
		self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
		
		self.state = .peeks
		DesignConfigurator.designPeekingRegisterView(self)
		parentView.bringSubview(toFront: self)
		
		self.translatesAutoresizingMaskIntoConstraints = false
		self.snp.makeConstraints{
			(make) -> Void in
			make.width.equalTo(parentView.snp.width).offset(-120)
			make.centerX.equalTo(parentView.snp.centerX)
			make.bottom.equalTo(parentView.snp.bottom).offset(-33)
			make.height.equalTo(44)
		}
        
        self.addSubview(caption)
        self.caption.snp.remakeConstraints {
            (make) -> Void in
            make.centerX.equalTo(self.snp.centerX)
        }
		
		// to go thru state switch
		let tapSelfGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterForm.registerViewTapped(_:)))
		self.addGestureRecognizer(tapSelfGestureRecognizer)
	}

	// switches RegView's states
	func registerViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
		switch state {
		case .peeks:
			// Was peeking. Now floating above NavBar
			state = .tappable
			UIView.animate(withDuration: 0.8, animations: {
				self.changeConstraintsToState(state: self.state)
				self.caption.text = "Tap to login or register"
				self.caption.textColor = UIColor.clear
				self.layoutIfNeeded()
			}) 
			
			// animation for the text
			UIView.transition(with: caption, duration: 0.8, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
				self.caption.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
				}, completion: nil)
			
			
			// TODO: is hanging there forever ! Remove all gestures on close
            // Adding gesture recognizer for dismissing
            
			tapParentGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterForm.hideRegisterView(_:)))
			self.parentView.addGestureRecognizer(tapParentGestureRecognizer!)
			
		case .tappable:
			// Full size
			state = .large
			caption.removeFromSuperview()
            expandRegisterView()
		case .large:
			passwordField.resignFirstResponder()
			usernameField.resignFirstResponder()
        case .noState, .flat:
			print("Should not occur at all")
		}

	}
    
    func expandRegisterView() {
        // color
        configureTextField(usernameField)
        configureTextField(passwordField)
        configureSubmitButton()
        
        submitButton.addTarget(self, action: #selector(RegisterForm.didEndEntering), for: .touchDown)
        
        fillTextFieldsWithUsernameAndPassword()
        
        setupTextFieldObserver(usernameField)
        setupTextFieldObserver(passwordField)
        
        // place everything outside
        prepareForAnimation()
        
        UIView.animate(withDuration: 0.8, animations: {
            self.changeConstraintsToState(state: self.state)
        })
        blurEffectView = DesignConfigurator.createBlurBackgroundForParentView(parentView, andView: self)
    }
	
	
// MARK:- Animations and constraints
    func changeConstraintsToState(state: RegisterFormState) {
        if state == .tappable {
            self.snp.remakeConstraints {
                (make) -> Void in
                make.width.equalTo(self.parentView.snp.width).offset(-120)
                make.centerX.equalTo(self.parentView.snp.centerX)
                make.height.equalTo(44)
                make.bottom.equalTo(self.parentView.snp.bottom).offset(-60)
            }
        } else if state == .large {
            self.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            self.placeEverythingOnDestinationPositions()
            self.snp.remakeConstraints {
                $0.left.equalTo(self.parentView.snp.left).offset(20)
                $0.height.equalTo(230)
                // offset should be = height of panel
                $0.centerY.equalTo(self.parentView.snp.centerY).offset(-52)
                $0.centerX.equalTo(self.parentView.snp.centerX)
            }
        }
		self.parentView.layoutIfNeeded()
	}

    // before expanding to large
    func prepareForAnimation() {
        submitButton.snp.makeConstraints{
            $0.bottom.equalTo(self.snp.bottom).offset(400)
            $0.centerX.equalTo(self.snp.centerX)
        }
        
        usernameField.snp.makeConstraints {
            $0.left.equalTo(self.snp.left).offset(-200)
            $0.top.equalTo(self.snp.top).offset(61)
        }
        
        passwordField.snp.makeConstraints {
            $0.right.equalTo(self.parentView.snp.right).offset(200)
            $0.top.equalTo(self.snp.top).offset(18)
        }
        self.layoutIfNeeded()
    }

    // meaning for submit or just to show regView
    func configureSubmitButton() {
        self.addSubview(submitButton)
        DesignConfigurator.configureRegisterLoginButton(submitButton: submitButton)
    }

	func hideRegisterView(_ gestureRecognizer: UITapGestureRecognizer?=nil) {
		// very bad decision
		// falls if done from Netwview
        if let gr = tapParentGestureRecognizer {
            self.parentView.removeGestureRecognizer(gr)
        }
//		self.parentView.removeGestureRecognizer(self.parentView.gestureRecognizers![0])
		if state == .tappable {
			state = .noState
			UIView.animate(withDuration: 0.3, animations: {
				
				self.snp.remakeConstraints {
					(make) -> Void in
					make.width.equalTo(self.parentView.snp.width).offset(-120)
					make.centerX.equalTo(self.parentView.snp.centerX)
					make.height.equalTo(44)
					make.top.equalTo(self.parentView.snp.bottom).offset(-110)
				}
				self.parentView.layoutIfNeeded()
			}) 
			
			UIView.animate(withDuration: 0.8, delay: 0.3, options: [], animations: {
				
				self.snp.updateConstraints {
					(make) -> Void in
					make.top.equalTo(self.parentView.snp.bottom).offset(0)
				}
				self.parentView.layoutIfNeeded()},
			                           completion: nil)
        } else if state == .flat {
            state = .noState
            let underlyingParentView = parentView.superview!
            UIView.animate(withDuration: 0.8, animations: {
                self.snp.remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(underlyingParentView.snp.bottom).offset(30)
                    make.height.equalTo(44)
                    make.left.equalTo(underlyingParentView.snp.left).offset(20)
                    make.centerX.equalTo(underlyingParentView.snp.centerX)
                }
                
                (self.parentView as! NetworkStatusView).hide()
                
                underlyingParentView.layoutIfNeeded()
            })
        
        }
        else {
			state = .noState
			UIView.animate(withDuration: 0.8, animations: {
				self.snp.remakeConstraints {
					(make) -> Void in
					make.top.equalTo(self.parentView.snp.bottom).offset(30)
					make.height.equalTo(44)
					make.left.equalTo(self.parentView.snp.left).offset(20)
					make.centerX.equalTo(self.parentView.snp.centerX)
				}
				self.parentView.layoutIfNeeded()
			}) 
			hideKeyboard()
            
            self.blurEffectView.removeFromSuperview()
            tapParentGestureRecognizer = nil
		}
	}
	


	
	
// MARK:- Embeded
	func createFlatRegisterView() {
		// shire texty
		// pass vstabit'
		configureTextField(usernameField, withClearColor: true)
        configureTextField(passwordField, withClearColor: true)
		
		configureSubmitButton()
		
        submitButton.addTarget(self, action: #selector(RegisterForm.didEndEntering), for: .touchDown)
        
		fillTextFieldsWithUsernameAndPassword()
		
		setupTextFieldObserver(usernameField)
		setupTextFieldObserver(passwordField)
		

		self.snp.remakeConstraints {
			(make) -> Void in
			make.height.equalTo(170)
//			make.centerX.equalTo(self.parentView.snp.centerX)
			make.width.equalTo(self.parentView.snp.width).dividedBy(1.1)
		}
		
		placeEverythingOnDestinationPositions(withFlatView: true)
		
		self.layer.cornerRadius = 16
		self.layer.borderColor = ResourceManager.getColor(.navBarColor).cgColor
		self.layer.borderWidth = 1
        
        state = .flat
        
	}
    
    
// MARK:- Common methods
    // todo: signal to button
    // lights the textfield's border with red color if is empty
    func setupTextFieldObserver(_ textField: UITextField) {
        textField
            .rx
            .text.orEmpty.subscribe( onNext: {
                text in
                let color: CGColor
                if text.characters.count == 0 {
                    color = ResourceManager.getColor(.warningBGColor).cgColor
                } else {
                    color = ResourceManager.getColor(.navBarColor).cgColor
                }
                textField.layer.borderColor = color
            }
            ).addDisposableTo(disposeBag)
    }
    
    // submit button pressed
    func didEndEntering() {
        guard Validator.notEmptyTextField(usernameField) && usernameField.text != "username" else {
            InfoMessageHelper.createInfoMessageWithText("Please fill the username", andStyle: .error)
            return
        }
        
        guard Validator.notEmptyTextField(passwordField) && passwordField.text != "password" else {
            InfoMessageHelper.createInfoMessageWithText("Please fill the password", andStyle: .error)
            return
        }
        
        DefaultsHelper.setUsername(usernameField.text!)
        DefaultsHelper.setPassword(passwordField.text!)
        
        
        DefaultsHelper.resetSyncedUserDefaults()
        NetworkHelper.syncManager.resetParameters()
        
        NetworkHelper.register()
        hideRegisterView()
    }
    
    // layouts textFields and button
    func placeEverythingOnDestinationPositions(withFlatView flat: Bool = false) {
        // textFields look too short when creating a flat view
        let flatOffset = flat ? 30 : 0
        
        ConstrainsConfigurator.constraintsFor(submitButton: submitButton, withViewToRelate: self)
        
        self.passwordField.snp.remakeConstraints{
            (make) -> Void in
            make.height.equalTo(33)
            make.top.equalTo(self.snp.top).offset(61)
            
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-60 + flatOffset)
        }
        
        self.usernameField.snp.remakeConstraints{
            (make) -> Void in
            make.height.equalTo(33)
            make.top.equalTo(self.snp.top).offset(18)
            
            make.width.equalTo(self.snp.width).offset(-60 + flatOffset)
            make.centerX.equalTo(self.snp.centerX)
        }
    }
    
    func fillTextFieldsWithUsernameAndPassword() {
        if DefaultsHelper.getDefaultByKey(.UsernameIsTemporary) as! Bool {
            usernameField.placeholder = "username"
            passwordField.placeholder = "password"
        } else {
            (usernameField.text!, passwordField.text!) = DefaultsHelper.getUsernameAndPassword()
        }
    }
    
    func configureTextField(_ textField: UITextField, withClearColor: Bool = false) {
        self.addSubview(textField)
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.backgroundColor = withClearColor ? UIColor.clear : UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func hideKeyboard() {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }

    

    
}

enum RegisterFormState {
	case noState
	case peeks
	case tappable
	case large
    case flat
}

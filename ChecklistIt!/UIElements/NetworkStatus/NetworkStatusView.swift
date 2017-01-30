//
//  File.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 26.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


//in dev
// Needs lots of refactor obv
class NetworkStatusView: UIView {
    // instead of creating a new singlton
    var isShown = false
    
	var blurEffectView = UIView()
	var parentViewController: UIViewController!
	let connectionStatusLabelWithName = UILabel()
	let connectionStatusLabel = UILabel()
	let dataIsActualLabelWithText = UILabel()
    
    let registerOfferButton = UIButton()
    var registerForm: RegisterForm?
    
    // TODO: think about it
    // a view that is placed right to label with text and takes all the place. To find out where center is
    let indicatorAndLabelBufferView = UIView()
    
    let activityIndicator = UIActivityIndicatorView()
    
	let disposeBag = DisposeBag()

	// register offer needed
	func showWithParentView(_ parentViewController: UIViewController) {
        // for the situation when user opened NetworkStatusView on one controller, didt close and then
        // tried to open it on another. This "if" saves lots of calls on hide VC functions
        if self.parentViewController != parentViewController {
            hide()
        }
        
        guard !isShown else {
            hide()
            return
        }
        
        isShown = true
        
        self.parentViewController = parentViewController
		let parentView = parentViewController.view!
		parentView.addSubview(self)
		
		DesignConfigurator.roundCorners(self, value: 16)
		self.backgroundColor = UIColor.white
		
        // layouts the NetworkStatusView instance
		self.snp.makeConstraints {
			(make) -> Void in
			make.width.equalTo(parentView.snp.width).dividedBy(1.3)
			make.height.equalTo(parentView.snp.height).dividedBy(1.7)
			make.centerX.equalTo(parentView.snp.centerX)
			make.centerY.equalTo(parentView.snp.centerY)
		}
        
		setupContent()
    
        // makes network request
        getCurrentSyncStatus()

		blurEffectView = DesignConfigurator.createBlurBackgroundForParentView(parentView, andView: self)
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NetworkStatusView.hide))
		blurEffectView.addGestureRecognizer(gestureRecognizer)
		
	}
	
	func setupContent() {
        // layout left static label
		self.addSubview(connectionStatusLabelWithName)
		self.addSubview(connectionStatusLabel)
		connectionStatusLabelWithName.snp.remakeConstraints {
			(make) -> Void in
			make.left.equalTo(self.snp.left).offset(10)
			make.top.equalTo(self.snp.top).offset(20)
		}
		connectionStatusLabelWithName.text = "Connection status"
		connectionStatusLabelWithName.sizeToFit()
		
		
        // layout a buffer view to the right of static label
        self.addSubview(indicatorAndLabelBufferView)
        indicatorAndLabelBufferView.snp.remakeConstraints {
            (make) -> Void in
            make.left.equalTo(connectionStatusLabelWithName.snp.right)
            make.right.equalTo(self.snp.right)
            make.centerY.equalTo(connectionStatusLabelWithName.snp.centerY)
            make.height.equalTo(connectionStatusLabelWithName.snp.height)
            
        }
        
        // layout conenction status label which contains text
        connectionStatusLabel.snp.remakeConstraints {
            (make) -> Void in
            make.centerX.equalTo(indicatorAndLabelBufferView.snp.centerX)
            make.centerY.equalTo(connectionStatusLabelWithName.snp.centerY)
        }
        connectionStatusLabel.text = "?"
        connectionStatusLabel.alpha = 0
        
        // layout activity indicator
        self.addSubview(activityIndicator)
        activityIndicator.snp.remakeConstraints {
            (make) -> Void in
            make.width.equalTo(20)
            make.height.equalTo(20)

            make.centerX.equalTo(indicatorAndLabelBufferView.snp.centerX)
            make.centerY.equalTo(connectionStatusLabel.snp.centerY)

        }
        activityIndicator.startAnimating()
        activityIndicator.alpha = 1
        activityIndicator.color = ResourceManager.getColor(.secondaryColor)
		
        // layout bottom label concerning data being actual
		self.addSubview(dataIsActualLabelWithText)
		dataIsActualLabelWithText.snp.remakeConstraints {
			(make) -> Void in
			make.centerX.equalTo(self.snp.centerX)
			make.top.equalTo(connectionStatusLabel.snp.bottom).offset(20)
			
		}
		dataIsActualLabelWithText.text = " "
        
        /// +++++++++ to func or class

        addSubview(registerOfferButton)
        
        
        DesignConfigurator.configureRegisterLoginButton(submitButton: registerOfferButton)
        registerOfferButton.snp.remakeConstraints {
            $0.top.equalTo(self.dataIsActualLabelWithText.snp.bottom).offset(32)
            $0.centerX.equalTo(self.snp.centerX)
            // more precise would be nice. So it is equal to real submit button
            $0.width.equalTo(self.snp.width).dividedBy(1.3)
        }
        
        registerOfferButton.addTarget(self, action: #selector(NetworkStatusView.layoutRegisterView), for: .touchDown)
        
	}
    
    func layoutRegisterView() {
        // mb fake view? i perekidyvat' tol'ko ego togda
        // or peredelat' init, chtoby sozdal, podgotovil, a potom na mesto
        self.registerForm = RegisterForm()
        registerForm!.addToParentView(parentView: self)
        
        // preanimation
        registerForm!.snp.makeConstraints {
            $0.left.equalTo(self.snp.left).offset(-300)
            $0.top.equalTo(self.dataIsActualLabelWithText.snp.bottom).offset(32)
        }
        layoutIfNeeded()

        // not the best
        UIView.animate(withDuration: 0.8) {
            self.registerForm!.snp.remakeConstraints {
                $0.height.equalTo(170)
                $0.width.equalTo(self.snp.width).dividedBy(1.1)
                $0.top.equalTo(self.dataIsActualLabelWithText.snp.bottom).offset(32)
                $0.centerX.equalToSuperview()
            }
            self.registerOfferButton.removeFromSuperview()
            self.layoutIfNeeded()
        }
        
        let tapNetworkStatusViewGR = UITapGestureRecognizer(target: self.registerForm, action: #selector(RegisterForm.hideKeyboard))
        self.addGestureRecognizer(tapNetworkStatusViewGR)
    }
    
    // move below
    
    
    // checks actualization with RX style
    func getCurrentSyncStatus() {
            //TODO: When user is not authorised, has no temp name, should write
        NetworkHelper.getActualizationDateWithRX()
//            .debug()
            .subscribe(
                onNext: {
                    actualization in
                    let connectionStatus: String
                    if let _ = actualization  {
                        connectionStatus = ConnectionStatusConstants.ok
                    } else {
                        connectionStatus = ConnectionStatusConstants.error
                    }
//                    // init new sync process as new actuazliation has arrived
//                    NetworkHelper.syncManager.processSync()
                    // TODO: old issue: bc of act date rewrite when new data arrives after 1st sync process server's date is a bit older so it needs another round but of upload only
                    // TODO: would be nice to set some type of observer to
                    
                    self.updateConnectionStatuslabels(connectionStatus: connectionStatus)
                    
                    
            }, onError: {
                (error) -> Void in
                self.updateConnectionStatuslabels(connectionStatus: "Error")
            }
            ).addDisposableTo(disposeBag)
    }
	

    

    
    func updateConnectionStatuslabels(connectionStatus: String) {
        DispatchQueue.main.async {
            // switch what is hidden
            self.animateActivityAndStatusLabel(connectionStatus: connectionStatus)
            UIView.transition(with: self.dataIsActualLabelWithText, duration: 0.4, options: [.curveEaseOut, .transitionFlipFromTop], animations: {
                if !(DefaultsHelper.getDefaultByKey(.UsernameIsTemporary) as! Bool) {
                    self.dataIsActualLabelWithText.text =
                        NetworkHelper.syncManager.getSyncStatus() ?
                            DatatStateConstants.dataIsSynchronized :
                            DatatStateConstants.dataIsNotSynchronized
                } else {
                    self.dataIsActualLabelWithText.text = DatatStateConstants.userIsNotLoggedIn
                }
            }, completion: nil)

        }
    }
    
    func hide() {
        blurEffectView.removeFromSuperview()
        self.removeFromSuperview()
        self.registerForm?.removeFromSuperview()
        self.registerForm = nil
        isShown = false
    }
    
    
// MARK:- Animations
    func animateActivityAndStatusLabel(connectionStatus: String) {
        UIView.transition(with: self.activityIndicator, duration: 0.2, options: [.curveEaseOut, .transitionFlipFromBottom], animations: {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.alpha = 0
            //            self.activityIndicator.color = UIColor.clear
        }) {
            _ -> Void in
            UIView.transition(with: self.connectionStatusLabel, duration: 0.2, options: [.curveEaseOut, .transitionFlipFromTop], animations: {
                self.connectionStatusLabel.alpha = 1
                self.connectionStatusLabel.text = connectionStatus
                self.connectionStatusLabel.sizeToFit()
            }, completion: nil)
        }
    }
}

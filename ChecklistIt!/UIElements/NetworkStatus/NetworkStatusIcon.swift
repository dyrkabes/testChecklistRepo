//
//  NetworkStatusIcon.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 24.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class NetworkStatusIcon: NSObject {
    let networkStatusView = NetworkStatusView()
    
	let notLoggedInImage = UIImage(named: "NetworkNotLoggedIn")!
	let normalImage = UIImage(named: "Network")!
	let processngImage = UIImage(named: "NetworkProcessing")!
	let button = UIBarButtonItem()
	
	weak var parentViewController: UIViewController?
	var state: NetworkStatusIconState = .notLoggedIn
    
	// button view i mean
	func setUpView() {
		self.processStateChange()
		button.target = self
		button.action = #selector(NetworkStatusIcon.showNetworkView)
		
		button.imageInsets = UIEdgeInsetsMake(4, 4, 4, 4)

	}
	
	// Icon can be applied on any navBar
	func show(_ parentViewController: UIViewController) {
		// to avoid icon duplication
		let navBarRightButtons = self.parentViewController?.navigationItem.rightBarButtonItems
		if navBarRightButtons?.count > 1 {
			self.parentViewController?.navigationItem.rightBarButtonItems = []
			self.parentViewController?.navigationItem.rightBarButtonItem = navBarRightButtons![0]
		}
		
		self.parentViewController = parentViewController
		let navBarRightButton = parentViewController.navigationItem.rightBarButtonItems?[0]
		
		if navBarRightButton == nil || navBarRightButton == button {
			parentViewController.navigationItem.rightBarButtonItems = [button]
		} else {
			parentViewController.navigationItem.rightBarButtonItems = [navBarRightButton!, button]
		}
		self.processStateChange()
	}
	
	func changeNetworkStatusIconState(_ state: NetworkStatusIconState) {
		self.state = state
        DispatchQueue.main.async {
            self.processStateChange()
        }
	}
	
	fileprivate func processStateChange() {
        
		switch state {
		case .notLoggedIn:
			button.tintColor = ResourceManager.getColor(.networkStatusIconNotLoggedIn)
			button.image = notLoggedInImage
		case .inactive:
			button.tintColor = ResourceManager.getColor(.networkStatusIconInactive)
			button.image = normalImage
		case .active:
			button.tintColor = ResourceManager.getColor(.networkStatusIconActive)
			button.image = processngImage
		}
	}
	
	
	func showNetworkView() {
//		let networkStatusView = NetworkStatusView()
		networkStatusView.showWithParentView(parentViewController!)
	}
}

enum NetworkStatusIconState {
	case notLoggedIn
	case inactive
	case active
}

//
//  InfoMessageHelper.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 09.11.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import UIKit

class InfoMessageHelper {
	// we want only one instance
	static var infoView: UIView?
	
	static func createInfoMessageWithText(_ text: String, andStyle style: InfoMessageType) {
		// little view with info message below
//		let infoView = UIView()
		
		guard infoView == nil else {
			return
		}
		
		infoView = UIView()
		if let parentViewController = UIApplication.topViewController(),
		  let infoView = infoView {
			let parentView = parentViewController.view!
			parentView.addSubview(infoView)
			infoView.layer.cornerRadius = 8
            infoView.alpha = 0
			
			infoView.backgroundColor = style == .error ? ResourceManager.getColor(ColorName.warningBGColor) : ResourceManager.getColor(ColorName.secondaryColor)
			
			
			let label = UILabel()
			label.text = text
			label.textColor = UIColor(white: 0, alpha: 0)
			infoView.addSubview(label)
			
			
			infoView.snp.makeConstraints{
				(make) -> Void in
				make.height.equalTo(28)
				
				// remake obv. bardek :D
				if parentViewController is AllChecklistsViewController || parentViewController is MapViewController ||
					parentViewController is StatisticsViewController || parentViewController is SettingsViewController
                || parentViewController is FeedbackViewController {
					make.bottom.equalTo(parentView.snp.bottom).offset(-60)
				} else { make.bottom.equalTo(parentView.snp.bottom).offset(-20) }
				
                
				make.width.equalTo(parentView.snp.width).offset(-60)
				make.centerX.equalTo(parentView.snp.centerX)
				
			}

			label.snp.makeConstraints {
				(make) -> Void in
				make.centerX.equalTo(infoView.snp.centerX)
				make.centerY.equalTo(infoView.snp.centerY)

			}
			label.textColor = ResourceManager.getColor(ColorName.warningTextColor)
            
			parentView.layoutIfNeeded()
			
			InfoMessageHelper.animateAppearenceWithParentView(parentView, infoView: infoView)
			

		}
		
		
		
		
		
	}
	
	fileprivate static func animateAppearenceWithParentView(_ parentView: UIView, infoView: UIView) {
		OperationQueue.main.addOperation {
			
			
			// appearence
			UIView.animate(withDuration: 1, animations: {
				
                infoView.alpha = 1
				parentView.layoutIfNeeded()
			}) 
			
			
			//text animation
//			if let label = infoView.subviews[0] as? UILabel {
//				UIView.transition(with: label, duration: 1, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
//					label.textColor = ResourceManager.getColor(ColorName.warningTextColor)
//					}, completion: nil)
//			}

			
			// dissapearence
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
				UIView.animate(withDuration: 1, animations: {
//					infoView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                    infoView.alpha = 0
					parentView.layoutIfNeeded()
				}) 
				
				
//				// and for the text
//				if let label = infoView.subviews[0] as? UILabel {
//					UIView.transition(with: label, duration: 1, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
//						label.textColor = UIColor(white: 0, alpha: 0)
//						}, completion: nil)
//				}
			}
			
			
			// temporary. Removing
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
				infoView.removeFromSuperview()
				InfoMessageHelper.infoView = nil
			}
			
		}
	}
	
}

enum InfoMessageType {
	case success
	case error
}

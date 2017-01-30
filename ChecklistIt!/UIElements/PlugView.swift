//
//  PlugView.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 11/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import UIKit

class PlugView: UIView {
    var animatedIcons: [UIImageView] = []
    var animationStarted = false
    
    weak var parentViewController: UIViewController?
    
    func spreadIcons() {
        let images = ResourceManager.getImages()
        
        for _ in 0...30 {
            addIcon(image: images[
                Int(arc4random_uniform(UInt32(images.count)))
                ]
            )
        }
        if !animationStarted {
            startAnimation()
        }
    }
    
    private func animateIcon(icon: UIImageView) {
        createMovementAnimation(forIcon: icon)
        createOpacityAnimation(forIcon: icon)
    }
    
    internal func createMovementAnimation(forIcon icon: UIImageView) {
        let x = Int(arc4random_uniform(300))
        let y = Int(arc4random_uniform(300))
        let movementDuration = CFTimeInterval(arc4random_uniform(10)) + 10
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.fromValue = icon.layer.position
        moveAnimation.toValue = CGPoint(x: x, y: y)
        moveAnimation.duration = movementDuration
        moveAnimation.setValue("movement", forKey: "name")
        moveAnimation.delegate = self
        
        moveAnimation.setValue(icon, forKey: "view")
        
        icon.layer.add(moveAnimation, forKey: nil)
        
        icon.layer.position = moveAnimation.toValue as! CGPoint
    }
    
    internal func createOpacityAnimation(forIcon icon: UIImageView) {
        let opacityDuration = CFTimeInterval(arc4random_uniform(10)) + 10
        let opacity = Float(Double((arc4random_uniform(100)))/100)
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = icon.layer.opacity
        opacityAnimation.toValue = opacity
        opacityAnimation.duration = opacityDuration
        opacityAnimation.setValue("opacity", forKey: "name")
        opacityAnimation.setValue(icon, forKey: "view")
        opacityAnimation.delegate = self
        
        
//        let opacityAnimation = createOpacityAnimation(forIcon: icon)
        icon.layer.add(opacityAnimation, forKey: nil)
        icon.layer.opacity = opacityAnimation.toValue as! Float
    }
    
    private func addIcon(image: UIImage) {
        let icon = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        
        let x = Int(arc4random_uniform(300))
        let y = Int(arc4random_uniform(300))
        
        let size = Int(arc4random_uniform(10)) + 20
        let opacity = Float( Double(arc4random_uniform(100))/100 )

        icon.frame = CGRect(x: x, y: y, width: size, height: size)
        icon.tintColor = ResourceManager.getColor(.secondaryColor)
        icon.layer.opacity = opacity
        
        addSubview(icon)
        sendSubview(toBack: icon)
        animatedIcons.append(icon)
//        animateIcon(icon: icon)
    }
}

extension PlugView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let animationName = anim.value(forKey: "name") as! String
        guard UIApplication.topViewController() == self.parentViewController else {
            self.animationStarted = false
            return
        }
        if animationName == "movement" {
            createMovementAnimation(forIcon: anim.value(forKey: "view") as! UIImageView)
        } else if animationName == "opacity" {
            createOpacityAnimation(forIcon: anim.value(forKey: "view") as! UIImageView)
        }
    }
    
    func startAnimation() {
        guard !animationStarted else {
            return
        }
        animationStarted = true
        animatedIcons.forEach {
            self.createOpacityAnimation(forIcon: $0)
            self.createMovementAnimation(forIcon: $0)
        }
    }
}

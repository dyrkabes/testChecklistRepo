//
//  CreativeHeaderView.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 23/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import UIKit
import SnapKit

/// TODO: Clean the mess
// Remove the last string with text
// make a proper expand animation

// TODO: Make phrases slower. An more at a time-


class CreativeHeaderView: UIView {
    let backgroundView = UIView()
    var animationStarted = false
    
    let trackHeight = 25
    let trackOffset = 2
    
    var gradientLayer: CAGradientLayer!
    
    var stringsOnTheScreen = 0
    let maxStringsOnTheScreen = 2
    let stringAppearenceDelay: Int = 12
    var previousTextLevel = -1
    
    var creativePhrases: CreativePhrasesProtocol! = nil
    
    
    // TODO: composite phrases
    // TODO: Separate fgile
    // TODO: load from server new ones
    

    
    weak var parentViewController: UIViewController?
    
    // layouts view for future animation
    func setup(withParentViewController parentViewController: UIViewController){
        self.parentViewController = parentViewController
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalToSuperview()
        }
        layoutIfNeeded()
        addBackgroundLayer()
        creativePhrases = CreativePhrases()
    }
    
    private func addBackgroundLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = backgroundView.bounds
        gradientLayer.colors = [ResourceManager.getColor(.secondaryColor).cgColor, UIColor(red: 0, green: 0.2, blue: 0.7, alpha: 0.8).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x:0.5, y: 0)
        
        gradientLayer.locations = [0.0, 1.0]
        backgroundView.layer.addSublayer(gradientLayer)
    }
    
    func addMaskLayer() {
        let helper = CreativeHeaderHelper(maxX: Int(self.frame.width), maxY: Int(frame.height))
        let paths = helper.generateCirclePattern()
        let maskLayer = CAShapeLayer()
        
        let path = CGMutablePath()
        paths.forEach( { path.addPath($0) })
        maskLayer.path = path
        maskLayer.fillColor = UIColor.black.cgColor

        animatePath(maskLayer: maskLayer, helper: helper)
        backgroundView.layer.mask = maskLayer
    }
    
    
    func animatePath(maskLayer: CAShapeLayer, helper: CreativeHeaderHelper) {
        helper.clear()
        let maskLayerPathAnimation = CABasicAnimation(keyPath: "path")
        maskLayerPathAnimation.fromValue = maskLayer.path
        
        let animationPath = CGMutablePath()
        let paths = helper.generateCirclePattern()
        paths.forEach
            { animationPath.addPath($0)}
        maskLayerPathAnimation.toValue = animationPath
        maskLayerPathAnimation.duration = 30
        maskLayerPathAnimation.repeatCount = Float.infinity
        maskLayerPathAnimation.autoreverses = true
        
        maskLayer.add(maskLayerPathAnimation, forKey: nil)
    }
    
    
    func startTextAnimation() {
        addAnimatedText()
        
        for i in 1..<maxStringsOnTheScreen {
            let delay = i * stringAppearenceDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                self.addAnimatedText()
            }
        }
    }
    
    internal func addAnimatedText() {
        if stringsOnTheScreen < maxStringsOnTheScreen {
            stringsOnTheScreen += 1
            backgroundView.layer.addSublayer(createTextLayer())
        }
    }
    
    private func createTextLayer() -> CALayer {
        let textLayer = CALayer()
        
        // TODO calc witdfht
        textLayer.bounds = CGRect(x: 0, y: 0, width: 360.0, height: CGFloat(trackHeight))
        textLayer.frame.origin = positionLayer()
        
        // To prevet overlapping there're just a few height states
        let text = creativePhrases.getRandomPhrase()

        textLayer.contents = drawText(text: text, withLayer: textLayer)
        addMovementAnimation(layer: textLayer)
        return textLayer
    }
    
    
    // converts text into image
    private func drawText(text: String, withLayer textLayer: CALayer) -> CGImage? {
        let textAttributes: [String: AnyObject] = {
            let style = NSMutableParagraphStyle()
            style.alignment = .center

            let color = ResourceManager.getColor(.warningTextColor)
            // UIFont(name: "HelveticaNeue-Bold", size: 14)!
            return [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: 300), NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: color]
        }()
        
        UIGraphicsBeginImageContextWithOptions(textLayer.frame.size, false, 0)
        
        text.draw(in: textLayer.bounds, withAttributes: textAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.cgImage
    }
    
    private func addMovementAnimation(layer: CALayer) {
        let duration = arc4random_uniform(UInt32(12)) + 16
        let movementAnimation = CABasicAnimation(keyPath: "position.x")
        movementAnimation.fromValue = self.frame.width + 180
        movementAnimation.toValue = -360
        movementAnimation.duration = CFTimeInterval(duration)
        
        movementAnimation.delegate = self
        movementAnimation.setValue(layer, forKey: "layer")
        layer.add(movementAnimation, forKey: nil)
        
        // not the best
        layer.frame.origin = CGPoint(x: -360, y: layer.frame.origin.y)
        
    }
    
    func positionLayer() -> CGPoint {
        let x = 0
        // remove magic niumber
        var isSameLavel = true
        var y = 0
        while isSameLavel {
            y = Int(arc4random_uniform(UInt32(7))) * (trackOffset + trackHeight) + trackHeight
            isSameLavel = y == previousTextLevel
        }
        previousTextLevel = y
        return CGPoint(x: x, y: y)
    }
    
    

    
//    func moveMaskUpwards() {
//        
//        
////        let mask = backgroundView.layer.mask as? CAShapeLayer
////        let moveUpAnimation = CABasicAnimation(keyPath: "position.y")
//////        moveUpAnimation.fromValue = mask?.position.y
//////        moveUpAnimation.toValue = -232
////        moveUpAnimation.byValue = -232
////        moveUpAnimation.duration = 1
////        moveUpAnimation.setValue("moveUpAnimation", forKey: "name")
////        moveUpAnimation.delegate = self
////        moveUpAnimation.setValue(mask, forKey: "layer")
////        mask?.add(moveUpAnimation, forKey: nil)
////        self.removeFromSuperview()
//        
//        // for some reason it doesnt work so i had to make it via delegate
////        mask?.position.y = -232
//    }

}


extension CreativeHeaderView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // stopAnimation when is not visible
        stringsOnTheScreen -= 1
        if parentViewController == UIApplication.topViewController() {
            
            addAnimatedText()
        } else {
            animationStarted = false
        }
        let finishedLayer = anim.value(forKey: "layer") as? CALayer
        finishedLayer?.removeFromSuperlayer()
        
        
    }
}

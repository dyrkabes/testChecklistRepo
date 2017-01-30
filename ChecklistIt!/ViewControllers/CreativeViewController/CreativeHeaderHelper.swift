//
//  CreativeHeaderHelper.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 24/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import UIKit

class Saturation {
    var saturation: Int = 0
    var indexOf: Int = 0
    
    init(saturation: Int, indexOf: Int) {
        self.saturation = saturation
        self.indexOf = indexOf
    }
    
}

enum CircleSize: Int{
    case Big = 50
    case Medium = 36
    case Small = 16
}


// TODO: Refactor
// TODO: Make bubble amount depend on the screen size
class CreativeHeaderHelper {
    let minX: Int
    // replace
    let maxX: Int

    let minY: Int
    let maxY: Int

//    let minRadius: Int

//    let maxYBorder: Int
    var xSaturation: [Saturation]
    var ySaturation: [Saturation]
    
    var circles: [CGPath]
    
    
    // test and probably break value
    var depth = 0
    
    init(maxX: Int, maxY: Int) {
        minX = -20
        // width of the view
        self.maxX = maxX
        
        minY = -20
        self.maxY = maxY
        
//        minRadius = CircleSize.Small.rawValue
        
//        maxYBorder = maxY + CircleSize.Small.rawValue/2
        circles = []
        xSaturation = []
        ySaturation = []
        
        
        for i in 0...20 {
            xSaturation.append(Saturation(saturation: 0, indexOf: i * maxX/20))
            ySaturation.append(Saturation(saturation: 0, indexOf: i * maxY/20))
        }

    }

    // reusing helper
    func clear() {
        xSaturation = []
        ySaturation = []
        circles = []
        depth = 0
    }
    
    func generateCircle(withSize size: CircleSize, andMaxSaturation maxSaturation: Int) -> UIBezierPath {
        depth += 1
        //something has gone wrong. It doesnt but just in case
        guard depth < 1000 else {
            depth -= 10
            return UIBezierPath(arcCenter:CGPoint(x: (maxX - minX)/2,
                                                  y: (maxY - minY)/2),
                                radius: 44, startAngle: 0, endAngle: 8, clockwise: true)
        }
        
        
        let x: Int = Int(arc4random_uniform(UInt32(maxX))) + minX
        let radius = Int(arc4random_uniform(UInt32(size.rawValue))) + size.rawValue/2
        let y = Int(arc4random_uniform(UInt32(maxY - minY))) + minY - radius
        
        // what pivots are affected
        let circleAffectXMin = x - radius
        let circleAffectXMax = x + radius
        let circleAffectYMin = y - radius
        let circleAffectYMax = y + radius
        
        var circle: UIBezierPath
        // below is a piece of code which needs some plastic surgery
        
        // Controlling overlapping rate
        let affectedXSaturationCount = xSaturation.filter {
            $0.indexOf > circleAffectXMin && $0.indexOf < circleAffectXMax && $0.saturation + 1 >= maxSaturation
            }.count
        let affectedYSaturationCount = ySaturation.filter {
            $0.indexOf > circleAffectYMin && $0.indexOf < circleAffectYMax && $0.saturation + 1 >= maxSaturation
            }.count
        
        
        if affectedXSaturationCount != 0 || affectedYSaturationCount != 0 {
            circle = generateCircle(withSize: size, andMaxSaturation: maxSaturation)
            return circle
        }
        
        
        for saturation in xSaturation {
            if saturation.indexOf > circleAffectXMin && saturation.indexOf < circleAffectXMax {
                saturation.saturation += 1
            }
        }
        
        for saturation in ySaturation {
            if saturation.indexOf > circleAffectYMin && saturation.indexOf < circleAffectYMax {
                saturation.saturation += 1
            }
        }
        
        return UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: CGFloat(radius), startAngle: 0, endAngle: 8, clockwise: true)
    }
    
    func generateCirclePattern() -> [CGPath]{
        for _ in 0...8 {
            circles.append(generateCircle(withSize: .Big, andMaxSaturation: 5).cgPath)
        }
        
        for _ in 0...8 {
            circles.append(generateCircle(withSize: .Medium, andMaxSaturation: 7).cgPath)
        }
        for _ in 0...12 {
            circles.append(generateCircle(withSize: .Small, andMaxSaturation: 12).cgPath)
        }
//        print(xSaturation.map({$0.saturation}))
//        print(ySaturation.map({$0.saturation}))
//        print(depth)
        return circles
    }
    


}





//print(xSaturation)





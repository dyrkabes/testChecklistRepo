//
//  ResourceManager.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 02.11.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import GoogleMaps

class ResourceManager {
	static let categories = [
		"No category",
		"Animal",
		"Documents",
		"House"
	]
	
	static let context = CIContext(options: nil)
	
	static var mapView = GMSMapView()
	
	static let images: [String: UIImage] = ["No category": UIImage(named: "No category")!,
	                                        "Animal": UIImage(named: "Animal")!,
	                                        "Documents": UIImage(named: "Documents")!,
	                                        "House": UIImage(named: "House")!,
	                                        "Checkmark": UIImage(named: "Checkmark")!,
	                                        "": UIImage(named: "No category")!
	]
	
	static let techColors: [ColorName: ColorTechRepresentation] = [
		ColorName.navBarColor: ColorTechRepresentation(red: 146, green: 189, blue: 163, alpha: 255),
		ColorName.textColor: ColorTechRepresentation(red: 0, green: 0, blue: 0, alpha: 255),
		ColorName.additionalTextColor: ColorTechRepresentation(red: 123, green: 75, blue: 148, alpha: 255),
		ColorName.barButtonColor: ColorTechRepresentation(red: 255, green: 255, blue: 255, alpha: 255),
		ColorName.sectionColor: ColorTechRepresentation(red: 244, green: 244, blue: 244, alpha: 255),
		ColorName.sectionTitleColor: ColorTechRepresentation(red: 122, green: 122, blue: 122, alpha: 255),
		ColorName.secondaryColor: ColorTechRepresentation(red: 123, green: 75, blue: 148, alpha: 255),
		ColorName.categoryPickerColor: ColorTechRepresentation(red: 123, green: 75, blue: 148, alpha: 255),
		ColorName.warningBGColor: ColorTechRepresentation(red: 200, green: 60, blue: 60, alpha: 255),
		ColorName.warningTextColor: ColorTechRepresentation(red: 255, green: 255, blue: 255, alpha: 255),
		ColorName.networkStatusIconInactive: ColorTechRepresentation(red: 123, green: 75, blue: 148, alpha: 180),
		ColorName.networkStatusIconNotLoggedIn: ColorTechRepresentation(red: 123, green: 75, blue: 148, alpha: 100),
		ColorName.networkStatusIconActive: ColorTechRepresentation(red: 123, green: 75, blue: 148, alpha: 255),
        ColorName.buttonPressedText: ColorTechRepresentation(red: 255, green: 255, blue: 255, alpha: 40)

	]
	

	
	static let fontSizes: [FontType: CGFloat] = [
		FontType.barButton: 20
	]
	
	static func getColor(_ colorName: ColorName) -> UIColor {
		return UIColor(red: techColors[colorName]!.red/255,
		               green: techColors[colorName]!.green/255,
		               blue: techColors[colorName]!.blue/255,
		               alpha: techColors[colorName]!.alpha/255)
	}
	
	static func getCGColor(_ colorName: ColorName) -> CGColor {
		return UIColor(red: techColors[colorName]!.red/255,
		               green: techColors[colorName]!.green/255,
		               blue: techColors[colorName]!.blue/255,
		               alpha: techColors[colorName]!.alpha/255).cgColor
	}
    
    // should divide image categories for this func\tion. Or add info to images array
    static func getImages(withoutEmpty: Bool = true) -> [UIImage] {
        return images.filter({ $0.key != "No category" && $0.key != "" && $0.key != "Checkmark" })
        .map( { $0.value } )
    }
	
	static func getFontSize(_ font: FontType) -> CGFloat {
		return fontSizes[font]!
	}
	
	
//	static let mainColor: [String: CGFloat] = ["red": 198, "green": 141, "blue": 55, "alpha": 255]
//	static let secondaryColor: [String: CGFloat] = ["red": 134, "green": 173, "blue": 71, "alpha": 255]
	
	static func getImageWithCategory(_ category: String) -> UIImage {
		return images[category]!
	}
	
	static func getImageForMapWithCategory(_ category: String) -> UIImage {
		return UIImage(named: category + "-pin")!
	}
	
	static func getFilteredImageForMapWithCategory(_ category: String, type: String) ->UIImage {
		let startImage = CIImage(image: UIImage(named: category + "-pin")!)
		
		let techColor: ColorTechRepresentation
		if type == "Checklist" {
			techColor = techColors[.navBarColor]!
		} else {
			techColor = techColors[.secondaryColor]!
		}
		
		let vectorRed = CIVector(x: techColor.red/255, y: 0, z: 0, w: 0)
		let vectorGreen = CIVector(x: 0, y: techColor.green/255, z: 0, w: 0)
		let vectorBlue = CIVector(x: 0, y: 0, z: techColor.blue/255, w: 0)
		
		
		let filter  = CIFilter(name: "CIColorMatrix")
		filter?.setValue(startImage, forKey: kCIInputImageKey)
		filter?.setValue(vectorRed, forKey: "inputRVector")
		filter?.setValue(vectorGreen, forKey: "inputGVector")
		filter?.setValue(vectorBlue, forKey: "inputBVector")
		
		let cgImage  = context.createCGImage((filter?.outputImage)!, from: (filter?.outputImage?.extent)!)
		
		let scale = (filter?.outputImage?.extent)!.width / 50
		
		
		let newImage = UIImage(cgImage: cgImage!, scale: scale, orientation: UIImageOrientation(rawValue: 0)!)

		return newImage
	}

}

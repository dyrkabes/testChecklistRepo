//
//  StatisticsViewController.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 14.11.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
import SnapKit
import RxGesture
import RxCocoa
import RxSwift


// In dev. Now just a plug
// animation is not WAU ofc :D

//TODO: Bug. Cloud is not avaiable sometimes
class StatisticsViewController: UIViewController {
	// rework in future
	
	let labelsCount = 8
	let labelTitles = [ "Checklists made: ",
	"Checklists archived: ",
	"Items made: ",
	"Items done: ",
	"Since"
	]
	
	let labelValues = [ DefaultsKey.ChecklistsAdded,
	                    DefaultsKey.ChecklistsArchived,
	                    DefaultsKey.ItemsAdded,
	                    DefaultsKey.ItemsDone,
	]
	
	var valueLabels: [UILabel] = []
	
    var inDevelopment: UIView!
    var inDevelopmetLabels: [UILabel] = []
    var speedArray: [Int] = []
    
//    var labelsProduced: Observable<Int>
//    var labelsProduced: Int = 0
    var labelsProduced = Variable<Int>(0)
    var scoreLabel = UILabel()
    var bufferdScore = 0
    
    let disposeBag = DisposeBag()

    // delete
    //    var inDevLabel: UILabel!
//    var auxLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Statistics"
		
		ColorConfigurator.configureViewController(self)
		placeTheLabels()
        
        var count = 0
        for label in valueLabels {
            configureValueLabel(label, withRow: count)
            count += 1
        }
        AppDelegate.networkStatusIcon.show(self)
        
        
        // IN dev
        // Very bad made but it is for removal
        inDevelopment = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        self.view.addSubview(inDevelopment)
        
        
        
        //		let blurView = UIVisualEffectView()
        let blurEff = UIBlurEffect(style: .dark)
        
        let blurView = UIVisualEffectView(effect: blurEff)
        self.view.addSubview(blurView)
        self.view.bringSubview(toFront: blurView)
        blurView.snp.makeConstraints {
            (make) -> Void in
            make.size.equalTo(self.view.snp.size)
        }
        
        blurView.rx
            .gesture(.tap).subscribe(onNext: {
                _ -> Void in
                self.addLabel()
            }).addDisposableTo(disposeBag)
        
        
        
        
        view.addSubview(scoreLabel)
        
        scoreLabel.frame = CGRect(x: 5, y: 0, width: 25, height: 25)
        scoreLabel.textColor = UIColor.white
        self.view.layoutIfNeeded()
        
        
        labelsProduced.asObservable().subscribe(onNext: {
            print($0)
            // filtr combineLast ?
            //            self.scoreLabel.text = String(describing: $0)
            self.bufferdScore = $0
            self.animateScore()
            
        }).addDisposableTo(disposeBag)
        
        
        
//        // just an animation test
//        let animatedView = UIView()
//        animatedView.bounds.size = CGSize(width: 20, height: 20)
////        animatedView.center.x = view.center.x
//        
////        animatedView.bounds.height = 20
//        self.view.addSubview(animatedView)
////        animatedView.backgroundColor = UIColor.red
//        
//        let animation = CABasicAnimation(keyPath: "position.x")
//        animation.fromValue = -view.bounds.size.width / 2
//        animation.toValue = view.bounds.size.width / 2
//        animation.duration = 1
//        
////        animation.fillMode = kCAFillModeBoth
////        animation.isRemovedOnCompletion = false
//        
//        animatedView.layer.add(animation, forKey: nil)
//        
//        animatedView.layer.backgroundColor = UIColor.green.cgColor
//        
//        let bgAnimation = CABasicAnimation(keyPath: "backgroundColor")
//        bgAnimation.fromValue = UIColor.clear.cgColor
//        bgAnimation.toValue = UIColor.green.cgColor
//        bgAnimation.duration = 4
////        bgAnimation.fillMode = kCAFillModeBackwards
//        animatedView.layer.add(bgAnimation, forKey: nil)
//        
//        
////        animatedView.layer.backgroundColor = UIColor.green.cgColor
//    
//        let cornerAnimation = CABasicAnimation(keyPath: "cornerRadius")
//        cornerAnimation.toValue = 20
//        cornerAnimation.duration = 5
//        
//        
//        animatedView.layer.add(cornerAnimation, forKey: nil)
        
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inDevelopmetLabels.forEach {
                animate(label: $0)
        }
        addLabel()
    }
    

    func addLabel() {
        let label = UILabel()
        randomizeLabelPosition(label: label)
        label.text = "In development"
        label.textColor = UIColor.white
        label.sizeToFit()

        self.view.addSubview(label)
        self.inDevelopmetLabels.append(label)
        
        animate(label: label)
        
        labelsProduced.value += 1
    }
    
    func randomizeLabelPosition(label: UILabel) {
        let x = Int(arc4random_uniform(300)) - 50
        let y = Int(arc4random_uniform(400)) + 30
        label.frame = CGRect(x: x, y: y, width: 0, height: 0)
    }
    
    func animate(label: UILabel, firstTime: Bool = true) {
        // CPU leak is produced here
        print("CONF animate")
        let x = label.frame.minX
        
        let distance = Int(self.view.frame.width - x)
        
        let speed: Int
        if firstTime {
            speed = Int(arc4random_uniform(20)) + 6
        } else {
            speed = speedArray[inDevelopmetLabels.index(of: label)!]
        }
        
        let time = distance / speed
        
        UIView.animate(withDuration: TimeInterval(time), delay: 0, options: [.curveLinear], animations: {
            label.frame = label.frame.offsetBy(dx: CGFloat(distance), dy: 0)
        }, completion: {
            _ in
            if UIApplication.topViewController() == self {
                label.frame = label.frame.offsetBy(dx: -UIScreen.main.bounds.width - label.frame.width - 10, dy: 0)
                self.animate(label: label)
            }
        })

    }
    
    func animateScore() {
        let auxLabel = UILabel()
        auxLabel.frame = self.scoreLabel.frame
        auxLabel.text = self.scoreLabel.text
        auxLabel.textColor = self.scoreLabel.textColor
        self.view.addSubview(auxLabel)
        self.scoreLabel.alpha = 0
        self.view.layoutIfNeeded()
        
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                auxLabel.alpha = 0
            }

            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.4) {
//                self.scoreLabel.alpha = 1
                self.scoreLabel.frame = self.scoreLabel.frame.offsetBy(dx: -50, dy: 0)
            }

            
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                self.scoreLabel.text = String(self.bufferdScore)
                self.scoreLabel.frame = self.scoreLabel.frame.offsetBy(dx: 50, dy: 0)
                self.scoreLabel.alpha = 1
            }
            self.view.layoutIfNeeded()

        }, completion: {
            _ in
            auxLabel.removeFromSuperview()
        })

//            self.scoreLabel.snp.remakeConstraints {
////                $0.bottom.equalTo(150)
//                $0.left.equalTo(0)
//            }
            
//            UIView.animate(withDuration: 1, delay: 1, options: [], animations: {
//                self.scoreLabel.snp.remakeConstraints {
////                    $0.bottom.equalTo(150)
//                    $0.left.equalTo(0)
//                }
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//        }
    }
    
//    func removeLabel(sender: UILabel) {
//        print("rmove")
////        let temp = sender as! UILabel
//        sender.removeFromSuperview()
//        inDevelopmetLabels.remove(at: inDevelopmetLabels.index(of: sender)!)
//    }
		
//// delete
//        inDevLabel = UILabel()
//		inDevLabel.text = "IN DEVELOPMENT"
//		inDevLabel.textColor = ResourceManager.getColor(.warningTextColor)
//		inDevelopment.addSubview(inDevLabel)
//		inDevLabel.font = UIFont(name: "System", size: 45)
//		inDevelopment.snp.makeConstraints {
//			(make) -> Void in
//			make.size.equalTo(self.view.snp.size)
//			make.center.equalTo(self.view.snp.center)
//		}
//		
//		inDevLabel.snp.makeConstraints {
//			(make) -> Void in
//			make.center.equalTo(self.view.snp.center)
//		}
//		self.view.bringSubview(toFront: inDevelopment)
//        
//        auxLabel = UILabel()
//        auxLabel.text = "IN DEVELOPMENT"
//        auxLabel.textColor = ResourceManager.getColor(.warningTextColor)
//        inDevelopment.addSubview(auxLabel)
//        auxLabel.font = UIFont(name: "System", size: 45)
//        
//        auxLabel.snp.makeConstraints {
//            (make) -> Void in
//            make.center.equalTo(self.view.snp.center)
//        }
//        self.view.bringSubview(toFront: inDevelopment)
//        
//        let gR = UITapGestureRecognizer(target: self, action: #selector(StatisticsViewController.animateInDevelopment))
//        self.inDevelopment.addGestureRecognizer(gR)
        
		
	
    // delete
//    func animateInDevelopment() {
//        // TODO: remake. Make om click different "In devs" floating.
//        // Click on inDev scales it down
//        // or sometimes makes two of them... dunno
//        print("inside")
//        auxLabel.transform = CGAffineTransform(scaleX: 1.0, y: 0.1)
//        auxLabel.snp.remakeConstraints {
//            (make) -> Void in
//            make.top.equalTo(inDevLabel.snp.top).offset(-15)
//            make.centerX.equalTo(inDevLabel.snp.centerX)
//        }
//        
//        UIView.animate(withDuration: 1) {
//            self.auxLabel.transform = CGAffineTransform()
//        }
//        
////        let auxView: UIView
////        inDevelopment.transform = CGAffineTransform(translationX: 70, y: 70)
//    }
	

	
	// pretty ununderstandable i guess
	func placeTheLabels() {
		for group in 0...1 {
			for labelNum in 0..<5 {
				let label = UILabel()
				label.font = UIFont.systemFont(ofSize: 13)
				view.addSubview(label)
				configureConstraintsForLabel(label, withColumn: group, andRow: labelNum)
				if group == 0 {
					label.text = labelTitles[labelNum]
					label.textColor = ResourceManager.getColor(ColorName.textColor)
				} else {
					configureValueLabel(label, withRow: labelNum)
					valueLabels.append(label)
					label.textColor = ResourceManager.getColor(ColorName.secondaryColor)
				}
			}
		}
	}
	
	func configureConstraintsForLabel(_ label: UILabel, withColumn column: Int, andRow row: Int) {
		label.snp.makeConstraints { (make) -> Void in
			if column == 0 {
				make.left.equalTo(view.snp.left).offset(10)
			} else {
				make.right.equalTo(view.snp.right).offset(-10)
			}
			make.top.equalTo(view.snp.top).offset(20 + 20 * row)
			
		}
    }
	
	func configureValueLabel(_ label: UILabel, withRow row: Int) {
		if row != 4 {
			label.text = String(describing: DefaultsHelper.getDefaultByKey(labelValues[row]))
		} else {
			label.text = String(DefaultsHelper.getStartingDate())
		}
	}
	
}

extension StatisticsViewController: ContentChangedDelegate {
    func contentChanged() {
        //
    }
    
    func addAnimation(category: String, itemID: String) {
        //
    }
}

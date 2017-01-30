//
//  SettingsViewController.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 13/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import UIKit
import SnapKit

import RxCocoa
import RxSwift

class SettingsViewController: UIViewController {

    let leaveAFeedBackButton = UIButton()
//    var anonimously = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorConfigurator.configureViewController(self)
        view.addSubview(leaveAFeedBackButton)
        leaveAFeedBackButton.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.width.equalTo(132)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(30)
        }
        
        leaveAFeedBackButton.backgroundColor = ResourceManager.getColor(.secondaryColor)
        leaveAFeedBackButton.setTitle("Leave feedback", for: .normal)
        DesignConfigurator.roundCorners(leaveAFeedBackButton, value: 8)
        DesignConfigurator.createShadow(leaveAFeedBackButton, withSize: .small)
        leaveAFeedBackButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .highlighted)
        leaveAFeedBackButton.addTarget(self, action: #selector(SettingsViewController.showFeedbackForm), for: .touchUpInside)

    }
    
    // TODO: reload on submit too
    // Do not reload all data, do not fetch everything on sumbit. Only one record
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.networkStatusIcon.show(self)
    }
    
    func showFeedbackForm() {

        let feedbackVC = FeedbackViewController(nibName: nil, bundle: nil)
//        feedbackVC.view = UIView()
        feedbackVC.view.backgroundColor = UIColor.white
//        feedbackVC.view.snp
        
        let navC = self.navigationController
//        let navCC = UINavigationController(rootViewController: feedbackVC)
        navC?.viewControllers = [self, feedbackVC]

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

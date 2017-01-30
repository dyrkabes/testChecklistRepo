//
//  CreativeViewController.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 23/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import UIKit
import SnapKit


// TODO: add next creative timer and button
// TODO: magic numbers

class CreativeViewController: UIViewController {

    var creativeTableView = ExpandableTableView()
    
    var headerView: CreativeHeaderView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorConfigurator.configureViewController(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addCreativeHeaderView()
        addTableView()
    }
    
    func addCreativeHeaderView() {
        if self.headerView == nil {
            headerView = CreativeHeaderView()
            self.view.addSubview(headerView!)
            
            layoutHeaderView()
            self.view.layoutIfNeeded()
            headerView?.setup(withParentViewController: self)
            
//            layoutHeaderView()
//            self.view.layoutIfNeeded()
//            headerView?.addMaskLayer()
//            headerView?.startTextAnimation()
//            headerView?.setup(withParentViewController: self)
            
        } else {
            layoutHeaderView()
            self.view.layoutIfNeeded()
//            layoutHeaderView()
//            self.view.layoutIfNeeded()
//            headerView?.addMaskLayer()
//            headerView?.startTextAnimation()
        }
        
        
        
        headerView?.addMaskLayer()
        headerView?.startTextAnimation()
       
        
        // Inache udalyaem staryi sloi, dobavlyaem novyi i animaciu
    }
    
    func layoutHeaderView() {
        headerView?.snp.remakeConstraints {
            $0.width.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(232)
            $0.left.equalToSuperview()
        }
    }
    
    func addTableView() {
        self.view.addSubview(creativeTableView)
        creativeTableView.setDelegate(parentViewController: self)
        creativeTableView.setUpTableView(parentViewController: self, cellType: CreativeCell.self)
        layoutTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func layoutTableView() {
        creativeTableView.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
//            $0.top.equalTo(feedbackForm.snp.bottom).offset(20)
            if let headerView = headerView {
                $0.top.equalTo(headerView.snp.bottom).offset(20)
            } else {
                // should never occur
                $0.top.equalToSuperview()
            }
            $0.bottom.equalToSuperview().offset(-55)
            $0.width.equalToSuperview().offset(-20)
        }
    }
    
}

extension CreativeViewController: ExpandableTableViewDelegate {
    func expand() {
        print("Expand")
//        headerView.moveMaskUpwards()
        // test
        UIView.animate(withDuration: 1) {
            self.creativeTableView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()


                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-40)
                $0.width.equalToSuperview()
            }
            // TODO: animate cornerr rad
            self.creativeTableView.layer.cornerRadius = 0
            
            self.headerView?.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalTo(self.view.snp.top)
                $0.height.equalTo(232)
                $0.width.equalToSuperview()
            }
            
            
            
            self.view.layoutIfNeeded()
        }
    }
    
    func collapse() {
        print("collapse")
        UIView.animate(withDuration: 1) {
            self.layoutHeaderView()
            // TODO: animate cornerr rad
            self.creativeTableView.layer.cornerRadius = 8
            
            self.layoutTableView()

            self.view.layoutIfNeeded()
        }
    }
    
    // TODO: TODO: !!!! when expandint it would be fun to move mask only!
}

extension CreativeHeaderHelper: ContentChangedDelegate {
    func contentChanged() {
        // Changes creatives, probably makes a new responce about new creative time
    }
    
    func addAnimation(category: String, itemID: String) {
        // 
    }
}

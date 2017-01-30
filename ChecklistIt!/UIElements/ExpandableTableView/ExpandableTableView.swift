//
//  ExpandableTableView.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 23/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import UIKit
import SnapKit
//import SwiftSVG

// TODO: feedback cell 
// title
// status in state of envelop. Transorming and colouring
// glasses for anonymous
// group all


class ExpandableTableView: UIView {
    let tableView = UITableView()
    let titleLabel = LabelWithInsets()
    let expandButton = UIButton()
    
    var expandDelegate: ExpandableTableViewDelegate?
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func setDelegate(parentViewController: ExpandableTableViewDelegate) {
        expandDelegate = parentViewController
    }
    
    func setUpTableView <T : UITableViewCell> (parentViewController: UIViewController, cellType: T.Type) {
        self.layer.borderColor = ResourceManager.getColor(.navBarColor).cgColor
        self.layer.borderWidth = 3
        
        let cellTypeString = String(describing: cellType)
        
        DesignConfigurator.roundCorners(self, value: 16)
        
        tableView.delegate = parentViewController as? UITableViewDelegate
        tableView.dataSource = parentViewController as? UITableViewDataSource
        
        tableView.register(cellType, forCellReuseIdentifier: cellTypeString)
        
        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.width.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(44)
            $0.height.equalToSuperview().offset(-44)
            $0.left.equalToSuperview().offset(10)
        }
        layer.masksToBounds = true
        
        let title = cellTypeString == String(describing: FeedbackCell.self) ? "Recent feedback" : "Recent creatives"

        setupTableViewWithTitle(title)
        setupExpandButton()
    }
    
    private func setupTableViewWithTitle(_ title: String) {
        titleLabel.text = title
        titleLabel.textColor = UIColor.white
        titleLabel.layer.backgroundColor = ResourceManager.getColor(.navBarColor).cgColor
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(44)
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
        }
    }
    
    private func setupExpandButton() {
        titleLabel.addSubview(expandButton)
        expandButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-10)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
            $0.top.equalToSuperview()
        }
        expandButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        expandButton.setImage(UIImage(named: "Add")!.withRenderingMode(.alwaysTemplate), for: .normal)
        expandButton.setImage(UIImage(named: "Add")!.withRenderingMode(.alwaysTemplate), for: .highlighted)
        expandButton.tintColor = UIColor.white
        
        
        titleLabel.isUserInteractionEnabled = true
        expandButton.addTarget(self, action: #selector(ExpandableTableView.expand), for: .touchDown)

        self.bringSubview(toFront: expandButton)
        
    }
    
    // unify?
    func expand() {
        expandDelegate?.expand()
        
        
        // switch action
        expandButton.removeTarget(self, action: #selector(ExpandableTableView.expand), for: .touchDown)
        expandButton.addTarget(self, action: #selector(ExpandableTableView.collapse), for: .touchDown)
        
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.duration = 1
        borderColorAnimation.fromValue =
//            ResourceManager.getColor(.navBarColor).cgColor
            self.layer.borderColor
        borderColorAnimation.toValue = ResourceManager.getColor(.secondaryColor).cgColor
        
        self.layer.add(borderColorAnimation, forKey: "borderColor")
        
        self.layer.borderColor = ResourceManager.getColor(.secondaryColor).cgColor
        
        UIView.transition(with: self.titleLabel, duration: 1, options: [], animations: {
            self.titleLabel.layer.backgroundColor = ResourceManager.getColor(.secondaryColor).cgColor
        }, completion: nil)
        
        
    }
    
    func collapse() {
        expandDelegate?.collapse()
        expandButton.removeTarget(self, action: #selector(ExpandableTableView.collapse), for: .touchDown)
        expandButton.addTarget(self, action: #selector(ExpandableTableView.expand), for: .touchDown)
        
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.duration = 1
        borderColorAnimation.fromValue = self.layer.borderColor
        borderColorAnimation.toValue = ResourceManager.getColor(.navBarColor).cgColor
        
        self.layer.add(borderColorAnimation, forKey: "borderColor")
        
        self.layer.borderColor = ResourceManager.getColor(.navBarColor).cgColor
        
        UIView.transition(with: self.titleLabel, duration: 1, options: [], animations: {
            self.titleLabel.layer.backgroundColor = ResourceManager.getColor(.navBarColor).cgColor
        }, completion: nil)
        
    }
    // TODO: expand animations
    
}

class LabelWithInsets: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 5)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}

//
//  FeedbackForm.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 13/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import SnapKit

import RxSwift
import RxCocoa

class FeedbackForm: UIView {
    let titleTextField = UITextField()
    let descriptionTextField = UITextField()
    let submitButton = UIButton()
    let anonButton = UIButton()
    let height = 260
    
    var delegate: ContentChangedDelegate?
    
    var anonButtonState = AnonButtonState.normal
    
    let disposeBag = DisposeBag()
    
    func layout(withParentViewController parentViewController: UIViewController) {
        
        delegate = parentViewController as? ContentChangedDelegate
        
//        let parentView = parentViewController.view!
        
        
        
        addSubview(titleTextField)
        addSubview(descriptionTextField)
        addSubview(submitButton)
        addSubview(anonButton)
        
        // annimate appearence... view Layers would be nice - starting pos is not needed
        
        titleTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(15)
            $0.width.equalToSuperview().dividedBy(1.2)
            $0.height.equalTo(44)
        }
        DesignConfigurator.roundCorners(titleTextField, value: 8)
        // TODO: designConf layer maker do :p what a beautiful exmple of english literature here D:D:D:D:
        titleTextField.layer.borderWidth = 2
        titleTextField.layer.borderColor = ResourceManager.getColor(.navBarColor).cgColor
        titleTextField.placeholder = "title"
        
        // add rx to watch for emptiness
        
        descriptionTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleTextField.snp.bottom).offset(15)
            $0.width.equalTo(titleTextField.snp.width)
            $0.height.equalTo(88)
        }
        DesignConfigurator.roundCorners(descriptionTextField, value: 16)
        descriptionTextField.layer.borderWidth = 2
        descriptionTextField.layer.borderColor = ResourceManager.getColor(.navBarColor).cgColor
        descriptionTextField.placeholder = "description"
        
        // add rx to watch for emptiness
        
        submitButton.snp.makeConstraints {
            $0.left.equalTo(titleTextField.snp.left).offset(10)
            $0.top.equalTo(descriptionTextField.snp.bottom).offset(15)
            $0.width.equalTo(120)
            $0.height.equalTo(44)
        }
        submitButton.backgroundColor = ResourceManager.getColor(.secondaryColor)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(ResourceManager.getColor(.buttonPressedText), for: .highlighted)
        DesignConfigurator.roundCorners(submitButton, value: 8)
        DesignConfigurator.createShadow(submitButton, withSize: .large)
        
        
        // ad rx for button press
        
        
        anonButton.snp.makeConstraints {
            $0.right.equalTo(titleTextField.snp.right).offset(-10)
            $0.top.equalTo(submitButton.snp.top)
            $0.width.equalTo(80)
            $0.height.equalTo(submitButton.snp.height)
        }

        // replace with a pic
        anonButton.setTitle("Anon", for: .normal)
        
        DesignConfigurator.roundCorners(anonButton, value: 8)

        
        configureAnonButton()
        
        
//         add rx to check the state
        anonButton.rx
        .tap.asObservable()
            .subscribe(onNext: {
                if self.anonButtonState == .normal {
                    self.anonButtonState = .pressed
                } else {
                    self.anonButtonState = .normal
                }
                self.configureAnonButton()
            }).addDisposableTo(disposeBag)
        
        submitButton.addTarget(self, action: #selector(FeedbackForm.submit), for: .touchDown)
        
    }
    
    func configureAnonButton() {
        if anonButtonState == .normal {
            DesignConfigurator.createShadow(anonButton, withSize: .large)
            anonButton.setTitleColor(ResourceManager.getColor(.buttonPressedText), for: .normal)
            
            anonButton.backgroundColor = ResourceManager.getColor(.warningBGColor)
            
        } else {
            // add shadw tilting
            DesignConfigurator.createShadow(anonButton, withSize: .small)
            anonButton.setTitleColor(ResourceManager.getColor(.warningTextColor), for: .normal)
            anonButton.backgroundColor = UIColor(red: 0.6, green: 0.2, blue: 0.2, alpha: 1)
        }
    }
    
    func submit() {
        guard Validator.notEmptyTextField(titleTextField) else {
            InfoMessageHelper.createInfoMessageWithText("Please fill the title", andStyle: .error)
            return
        }
        
        guard Validator.notEmptyTextField(descriptionTextField) else {
            InfoMessageHelper.createInfoMessageWithText("Please fill the description", andStyle: .error)
            return
        }
        let anonymously = anonButtonState == .pressed
        let feedbackDict: [String: Any] = ["title": titleTextField.text!,
                                       "text": descriptionTextField.text!,
                                       "anonimously": anonymously
                                       ]
        FeedbackHelper.sendNewFeedbackWithFeedbackDict(feedbackDict: feedbackDict) {
            self.delegate?.contentChanged()
        }

        clearForm()
        self.delegate?.contentChanged()
        

        
    }
    
    func clearForm() {
        titleTextField.text = ""
        descriptionTextField.text = ""
    }
    
}

enum AnonButtonState {
    case pressed
    case normal
}

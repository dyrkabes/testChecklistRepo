//
//  FeedbackViewController.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 20/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import UIKit
import RxSwift

// Issue: Anon button is only active on odd "willAppear"

class FeedbackViewController: UIViewController {
    let feedbackTableView = ExpandableTableView()
    var feedbacks: [Feedback] = []
    let feedbackForm = FeedbackForm()
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorConfigurator.configureViewController(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.networkStatusIcon.show(self)
        
        feedbacks = ManagedObjectContext.fetch(Feedback.self)
        
        FeedbackHelper.getAllFeedbacks(databseFeedbacks: feedbacks) {
            feedbacksFromServer in
            self.feedbacks = feedbacksFromServer
            DispatchQueue.main.async {
                self.feedbackTableView.reloadData()
            }
        }
        
        
        view.addSubview(feedbackForm)
        layoutFeedbackForm()
        
        feedbackForm.layout(withParentViewController: self)

        view.addSubview(feedbackTableView)
        layoutTableView()
        feedbackTableView.setDelegate(parentViewController: self)
        feedbackTableView.setUpTableView(parentViewController: self, cellType: FeedbackCell.self)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func back() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func layoutFeedbackForm() {
        feedbackForm.snp.remakeConstraints {
            $0.width.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(feedbackForm.height)
        }
    }
    
    func layoutTableView() {
        feedbackTableView.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(feedbackForm.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().offset(-55)
            $0.width.equalToSuperview().offset(-20)
        }
    }
}

extension FeedbackViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedbackCell.self), for: indexPath) as! FeedbackCell
        cell.titleLabel.text = feedbacks[indexPath.row].title
        cell.statusLabel.text = feedbacks[indexPath.row].status
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
}
    
extension FeedbackViewController: UITableViewDelegate {
        
}

extension FeedbackViewController: ContentChangedDelegate {
    func contentChanged() {
        feedbacks = ManagedObjectContext.fetch(Feedback.self)
        DispatchQueue.main.async {
            self.feedbackTableView.reloadData()
        }
    }
    
    func addAnimation(category: String, itemID: String) {
        // TODO: Add anim
    }
}

extension FeedbackViewController: ExpandableTableViewDelegate {
    func expand() {
        print("Expand")
        UIView.animate(withDuration: 1) {
            self.feedbackForm.snp.remakeConstraints {
                $0.bottom.equalTo(self.view.snp.top).offset(-10)
                $0.height.equalTo(self.feedbackForm.height)
                $0.width.equalToSuperview()
                
                // TODO: Recolor
                
            }
//            self.feedbackTableView.snp.updateConstraints {
//                $0.top.equalTo(self.feedbackForm.)
//            }
            self.view.layoutIfNeeded()
        }
    }
    
    func collapse() {
        print("collapse")
        UIView.animate(withDuration: 1) {
            self.layoutFeedbackForm()
            self.layoutTableView()
            self.view.layoutIfNeeded()
        }
        // make TW smalla again
    }
}

protocol ExpandableTableViewDelegate {
    func expand()
    func collapse()
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


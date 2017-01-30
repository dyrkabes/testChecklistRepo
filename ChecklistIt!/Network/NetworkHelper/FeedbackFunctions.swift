//
//  FeedbackFunctions.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 19/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift


extension NetworkHelper {
    static func sendFeedback(feedback: Feedback, completion: (() -> ())? ) {
        print(" **** sending feedback")
        let URL = NetworkHelper.getURL(.leaveFeedback)
        let (username, password) = DefaultsHelper.getUsernameAndPassword()
        let parameters: [String: Any] = ["username": username,
                                         "password": password,
                                         "feedback": feedback.mapTo()]
        AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.active)
        Alamofire.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: RequestConstants.headers
            )
            .responseJSON { serverResponce in
                let (responce, error) = ResponceValidator.validateJSONResponce(responce: serverResponce)
                guard error == nil else {
                    AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
                        .inactive)
                    return
                }
                
                if let result = responce?[ResponceKey.result] as? String {
                    if result == ResponceKey.success {
                        FeedbackHelper.changeFeedbackStatus(feedback: feedback, withNewStatus: "unread")
                        completion?()
                    }

                }
                AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
                    .inactive)
        }
    }
    

    static func getAllFeedback(withAnonymousIDs anonymousIDs: [String]) -> Observable<[[String: Any]]> {
        print(" **** getting all feedback")
        let URL = NetworkHelper.getURL(.getAllFeedback)
        let (username, password) = DefaultsHelper.getUsernameAndPassword()
        let parameters = ["username": username,
                          "password": password,
                          "anonymousIDs": anonymousIDs] as [String : Any]
        let request = NetworkHelper.createRequestWithURL(URL, andMethod: "POST", andParameters: parameters as [String : AnyObject])

        AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
            .active)
        return URLSession.shared
        .rx.json(request: request as URLRequest)
            .retry(3).map { serverResponce in
                if let responceJSON = (serverResponce as? [String: AnyObject])?["responce"] as? [String: AnyObject] {
                    if let feedbacks = responceJSON["feedbacks"] as? [[String:AnyObject]] {
                        AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
                            .inactive)
                        return feedbacks
                    }
                }
                AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
                    .inactive)
                return []
        }
    }
}

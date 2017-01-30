//
//  FeedbackHelper.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 19/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import RxSwift

class FeedbackHelper {
    let disposeBag = DisposeBag()
    // check all feedback on local device
    
    // write and send new feedback 
    static func sendNewFeedbackWithFeedbackDict(feedbackDict: [String: Any], completion: @escaping () -> ()) {
                // title text date local id anon
        // write to db
        
        let feedback = ManagedObjectContext.insertEntity(Feedback.self) as! Feedback
        feedback.id = UUID().uuidString
        feedback.title = feedbackDict["title"] as! String
        feedback.text = feedbackDict["text"] as! String
        feedback.date = Date().timeIntervalSince1970 as NSNumber
        feedback.status = "not sent"
        feedback.username = DefaultsHelper.getUsername()
        feedback.anonymously = feedbackDict["anonimously"] as! NSNumber
        feedback.responce = ""
        ManagedObjectContext.save()
        let functor = Functor(function: NetworkHelper.sendFeedback)
        functor.run((feedback: feedback, completion: completion))
    }
    
    static func changeFeedbackStatus(feedback: Feedback, withNewStatus status: String) {
        feedback.status = status
        ManagedObjectContext.save()
    }
    
    static func getAllFeedbacks(databseFeedbacks feedbacks: [Feedback], withCompletion completion: @escaping ([Feedback]) -> ()) {
        print(" ****Get all feedback")
        
        var anonymousIDs: [String] = []
        for feedback in feedbacks {
            if feedback.anonymously == 1 {
                anonymousIDs.append(feedback.id)
            }
        }
        
        NetworkHelper.getAllFeedback(withAnonymousIDs: anonymousIDs)
            .asObservable().subscribe(
                onNext: {
                    feedbacksFromServer in
                    var newFeedbacks: [Feedback] = feedbacks
                    
                    for feedback in feedbacksFromServer {
                        var foundInDatabase = false
                        for dbFeedback in feedbacks {
                            if feedback["local_id"] as! String == dbFeedback.id {
                                foundInDatabase = true
                                dbFeedback.status = feedback["status"] as! String
                                dbFeedback.responce = feedback["responce"] as! String
                                break
                            }
                        }
                        
                        if !foundInDatabase {
                            // feedback exists only on server
                            let dbFeedback = ManagedObjectContext.insertEntity(Feedback.self) as! Feedback
                            dbFeedback.mapOut(feedback)
                            newFeedbacks.append(dbFeedback)
                        }
                    }
                    ManagedObjectContext.save()
                    completion(newFeedbacks)
            },
                onDisposed: {
//                    print("Disposed")
                })
        
        
    }
    
    static func checkForNotSent() {
        let feedbacks = ManagedObjectContext.fetch(Feedback.self)
        let notSentFeedbacks = feedbacks.filter { $0.status == "not sent" }
        for feedback in notSentFeedbacks {
            NetworkHelper.sendFeedback(feedback: feedback, completion: nil)
        }
    }
    // probably it would be nice to have a big endpoint for that tho I will leave it for now
    
    
    // TODO: 
    // Feedback checks for oldies
    // nd deletes them
    static func checkForOldFeedback() {
//        let feedbacks = ManagedObjectContext.fetch(Feedback.self)
//        // older than a month
//        let now = Date().timeIntervalSince1970 as Double
//        let oldies = feedbacks.filter { $0.date as Double + 2592000.0 < now }
//        oldies.forEach { ManagedObjectContext.deleteEntity($0 as! BseItem) }
//        
    }
    
    
}

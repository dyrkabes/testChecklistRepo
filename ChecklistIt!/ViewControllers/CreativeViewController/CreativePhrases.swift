//
//  CreativePhrases.swift
//  ChecklistIt
//
//  Created by Pavel Stepanov on 30/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//
import Foundation

struct CreativePhrases: CreativePhrasesProtocol {
    // Think about: make groups in future
    
    // TODO: Length issue. is Cut at about end of birds phrase
    static var phrases: [String] = ["DO IT",
                            "WHAT ARE YOU WAITING FOR?",
                            "AWESOME POSSUM IS HERE FOR YOU!",
                            "What would happen if all the birds couldn't fly?",
                            "What do these bubbles look like?",
                            "What would dogs say if they could talk?",
                            "Why are the cats so cute?",
                            "What would it be if cats and dogs switched their bodies?",
                            "How do eyelashes know when to stop growing?",
                            "If you try to estinguish the sun with water, it'll be glad :)",
                            
                            
        
    ]
    
    func getRandomPhrase() -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(CreativePhrases.phrases.count)))
        let phrase = CreativePhrases.phrases[randomIndex]
        return phrase
    }
}

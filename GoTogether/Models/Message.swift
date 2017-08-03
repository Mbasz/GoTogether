//
//  Message.swift
//  GoTogether
//
//  Created by Marta on 03/08/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class Message {
    
    var key: String?
    let content: String
    let timestamp: Date
    let sender: Participant
    
    var dictValue: [String : Any] {
        let userDict = ["username" : sender.name,
                        "uid" : sender.uid]
        
        return ["sender" : userDict,
                "content" : content,
                "timestamp" : timestamp.timeIntervalSince1970]
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["timestamp"] as? TimeInterval,
            let userDict = dict["sender"] as? [String : Any],
            let uid = userDict["uid"] as? String,
            let name = userDict["name"] as? String,
            let imgURL = userDict["img_URL"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.content = content
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.sender = Participant(uid: uid, name: name, imgURL: imgURL)
    }
    
    init(content: String) {
        self.content = content
        self.timestamp = Date()
        let currentUser = User.current
        self.sender = Participant(uid: currentUser.uid, name: currentUser.name, imgURL: currentUser.imgURL)
    }
}

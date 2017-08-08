//
//  ParticipantService.swift
//  GoTogether
//
//  Created by Marta on 01/08/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ParticipantService {
    
    static func show(eventKey: String, completion: @escaping (Participant?) -> Void) {
        let ref = DatabaseReference.toLocation(.participant(eventKey: eventKey))
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let participant = Participant(snapshot: snapshot) else {
                return completion(nil)
            }
            completion(participant)
        })
    }
    
    static func create(user: User, eventKey: String) {
        let partAttrs = ["uid": user.uid, "name": user.name, "img_URL": user.imgURL]
        
        let ref = DatabaseReference.toLocation(.participant(eventKey: eventKey))
        
        ref.setValue(partAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
//                return completion(nil)
            }
        }
        
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            let participant = User (snapshot: snapshot)
//            completion(participant)
//        })
    }
    
    static func remove(eventKey: String) {
        let ref = DatabaseReference.toLocation(.participant(eventKey: eventKey))
        ref.removeValue()
    }
}

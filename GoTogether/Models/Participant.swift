//
//  Participant.swift
//  GoTogether
//
//  Created by Marta on 02/08/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class Participant {
    let uid: String
    let name: String
    var imgURL: String
    
    init(uid: String, name: String, imgURL: String) {
        self.uid = uid
        self.name = name
        self.imgURL = imgURL
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any], let uid = dict["uid"] as? String, let name = dict["name"] as? String, let imgURL = dict["img_URL"] as? String
            else { return nil }
        
        self.uid = uid
        self.name = name
        self.imgURL = imgURL
    }
    
}

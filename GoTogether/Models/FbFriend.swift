//
//  FbFriend.swift
//  GoTogether
//
//  Created by Marta on 25/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase.FIRDataSnapshot

struct FbFriend {
    var uid: String
    var name: String
    var imgURL: String
    
    init(uid: String, name: String, imgURL: String) {
        self.uid = uid
        self.name = name
        self.imgURL = imgURL
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any], let name = dict["name"] as? String, let imgURL = dict["img_URL"] as? String
            else { return nil }
        
        self.uid = snapshot.key
        self.name = name
        self.imgURL = imgURL
    }
}

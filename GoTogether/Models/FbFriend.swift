//
//  FbFriend.swift
//  GoTogether
//
//  Created by Marta on 25/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit

struct FbFriend {
    var uid: String
    var name: String
    var imgURL: String
    
    init(uid: String, name: String, imgURL: String) {
        self.uid = uid
        self.name = name
        self.imgURL = imgURL
    }
    
}

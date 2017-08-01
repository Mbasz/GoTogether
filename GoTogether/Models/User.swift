//
//  User.swift
//  GoTogether
//
//  Created by Marta on 10/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth.FIRUser
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    let uid: String
    let name: String
    var location: String
    var imgURL: String
    
    var dictValue: [String: Any] {
        let userDict = ["uid": uid, "name": name, "location": location, "img_URL": imgURL]
        return userDict
    }
    
    private static var _current: User?
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        return currentUser
    }
    
    init(uid: String, name: String, location: String, imgURL: String) {
        self.uid = uid
        self.name = name
        self.location = location
        self.imgURL = imgURL
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any], let name = dict["name"] as? String, let location = dict["location"] as? String, let imgURL = dict["imgURL"] as? String
            else { return nil }
        
        self.uid = snapshot.key
        self.name = name
        self.location = location
        self.imgURL = imgURL
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let name = aDecoder.decodeObject(forKey: Constants.UserDefaults.name) as? String,
            let location = aDecoder.decodeObject(forKey: Constants.UserDefaults.location) as? String,
            let imgURL = aDecoder.decodeObject(forKey: Constants.UserDefaults.imgURL) as? String
            else { return nil }
        
        self.uid = uid
        self.name = name
        self.location = location
        self.imgURL = imgURL
        
        super.init()

    }
    
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        
        if writeToUserDefaults {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }
        _current = user
    }
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
        aCoder.encode(name, forKey: Constants.UserDefaults.name)
        aCoder.encode(location, forKey: Constants.UserDefaults.location)
        aCoder.encode(imgURL, forKey: Constants.UserDefaults.imgURL)
        
    }
}


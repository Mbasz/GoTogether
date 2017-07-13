//
//  Event.swift
//  GoTogether
//
//  Created by Marta on 10/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase.FIRDataSnapshot

enum Category {
    case sport, culture, workshop
}

class Event {
    var key: String?
    let creator: User
    var title: String
    var date: Date
    var location: String
    let imgURL: String
    let imgHeight: CGFloat
    var description: String
    //var going: User? = nil
    //var category: Category
    
    var dictValue: [String: Any] {
        let userDict = ["uid": creator.uid, "name": creator.name]
        
        return ["title": title, "date": date, "location": location, "img_URL": imgURL, "img_height": imgHeight, "description": description, "creator": userDict]
    }
    
    init(title: String, location: String, imgURL: String, imgHeight: CGFloat, description: String) {
        self.title = title
        self.date = Date()
        self.location = location
        self.imgURL = imgURL
        self.imgHeight = imgHeight
        self.description = description
        self.creator = User.current
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any],
            let userDict = dict["creator"] as? [String: Any],
            let uid = userDict["uid"] as? String,
            let name = userDict["name"] as? String,
            let title = dict["title"] as? String,
            let date = dict["date"] as? Date,
            let location = dict["location"] as? String,
            let imgURL = dict["img_url"] as? String,
            let imgHeight = dict["img_height"] as? CGFloat,
            let description = dict["description"] as? String
        else { return nil }
        
        self.key = snapshot.key
        self.creator = User(uid: uid, name: name)
        self.title = title
        self.date = date
        self.location = location
        self.imgURL = imgURL
        self.imgHeight = imgHeight
        self.description = description
    }
}

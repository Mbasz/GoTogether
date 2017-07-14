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
    var link: String
    var description: String
    //var category: Category
    
    var dictValue: [String: Any] {
        let userDict = ["uid": creator.uid, "name": creator.name]
        
        return ["title": title, "date": date, "location": location, "img_URL": imgURL, "img_height": imgHeight, "link": link, "description": description, "creator": userDict]
    }
    
    init(title: String, location: String, imgHeight: CGFloat, imgURL: String, link: String, description: String) {
        self.title = title
        self.date = Date()
        self.location = location
        self.imgURL = imgURL
        self.imgHeight = imgHeight
        self.link = link
        self.description = description
        self.creator = User.current
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any],
            let userDict = dict["creator"] as? [String: Any],
            let uid = userDict["uid"] as? String,
            let name = userDict["name"] as? String,
            let title = dict["title"] as? String,
            let location = dict["location"] as? String,
            let imgURL = dict["img_URL"] as? String,
            let imgHeight = dict["img_height"] as? CGFloat,
            let link = dict["link"] as? String,
            let description = dict["description"] as? String
        else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        self.key = snapshot.key
        self.creator = User(uid: uid, name: name)
        self.title = title
        self.date = dateFormatter.date(from: dict["date"] as! String)!
        self.location = location
        self.imgURL = imgURL
        self.imgHeight = imgHeight
        self.link = link
        self.description = description
    }
}

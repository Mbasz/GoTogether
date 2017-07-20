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

class Event {
    var key: String?
    let creator: User
    var title: String
    var date: Date
    var time: String
    var location: String
    let imgURL: String
    let imgHeight: CGFloat
    var link: String
    var description: String
    var category: Int
    
    var dictValue: [String: Any] {
        let userDict = ["uid": creator.uid, "name": creator.name, "location": creator.location, "img_URL": creator.imgURL]
        
        return ["title": title, "date": date, "time": time, "location": location, "img_URL": imgURL, "img_height": imgHeight, "link": link, "description": description, "category": category, "creator": userDict]
    }
    
    init(title: String, date: Date, time: String, location: String, imgHeight: CGFloat, imgURL: String, link: String, description: String, category: Int) {
        self.title = title
        self.date = date
        self.time = time
        self.location = location
        self.imgURL = imgURL
        self.imgHeight = imgHeight
        self.link = link
        self.description = description
        self.creator = User.current
        self.category = category
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any],
            let userDict = dict["creator"] as? [String: Any],
            let uid = userDict["uid"] as? String,
            let name = userDict["name"] as? String,
            let profileImgURL = userDict["img_URL"] as? String,
            let title = dict["title"] as? String,
            let time = dict["time"] as? String,
            let location = dict["location"] as? String,
            let eventImgURL = dict["img_URL"] as? String,
            let imgHeight = dict["img_height"] as? CGFloat,
            let link = dict["link"] as? String,
            let description = dict["description"] as? String,
            let category = dict["category"] as? Int
        else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        self.key = snapshot.key
        self.creator = User(uid: uid, name: name, location: location, imgURL: profileImgURL)
        self.title = title
        self.date = dateFormatter.date(from: dict["date"] as! String)!
        self.time = time
        self.location = location
        self.imgURL = eventImgURL
        self.imgHeight = imgHeight
        self.link = link
        self.description = description
        self.category = category
    }
}

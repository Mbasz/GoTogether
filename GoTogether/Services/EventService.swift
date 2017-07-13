//
//  EventService.swift
//  GoTogether
//
//  Created by Marta on 11/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase

struct EventService {
    static func create(title: String, location: String, image: UIImage, description: String) {
        let imageRef = StorageReference.newEventImageReference()
        StorageService.upload(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            let aspectHeight = image.aspectHeight
            create(title: title, location: location, forURLString: urlString, aspectHeight: aspectHeight, description: description)
        }
        
    }
    
    private static func create(title: String, location: String, forURLString urlString: String, aspectHeight: CGFloat, description: String) {
        let currentUser = User.current
        let event = Event(title: title, location: location, imgURL: urlString, imgHeight: aspectHeight, description: description)
        
        let dict = event.dictValue
        
        let eventRef = DatabaseReference.toLocation(.newEvent(currentUID: currentUser.uid))
        

        eventRef.updateChildValues(dict)
    }
    
    static func show(forKey eventKey: String, creatorUID: String, completion: @escaping (Event?) -> Void) {
        let ref = DatabaseReference.toLocation(.showEvent(uid: creatorUID, eventKey: eventKey))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let event = Event(snapshot: snapshot) else {
                return completion(nil)
            }
            completion(event)
        })
    }
}

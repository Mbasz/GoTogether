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
    static func create(title: String, date: Date, time: String, location: String, image: UIImage, link: String, description: String, category: Int, isPublic: Bool) {
        let imageRef = StorageReference.newEventImageReference()
        StorageService.upload(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            let aspectHeight = image.aspectHeight
            create(title: title, date: date, time: time, location: location, forURLString: urlString, aspectHeight: aspectHeight, link: link, description: description, category: category, isPublic: isPublic) { (event) in
                    guard event != nil else { return }
                }
        }
        
    }
    
    private static func create(title: String, date: Date, time: String, location: String, forURLString urlString: String, aspectHeight: CGFloat, link: String, description: String, category: Int, isPublic: Bool, completion: @escaping (Event?) -> Void) {
        let currentUser = User.current
        let event = Event(title: title, date: date, time: time, location: location, imgHeight: aspectHeight, imgURL: urlString, link: link, description: description, category: category, isPublic: isPublic)
        
        var dict = event.dictValue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        dict["date"] = dateFormatter.string(from: dict["date"] as! Date)
        
        let eventRef = DatabaseReference.toLocation(.newEvent(currentUID: currentUser.uid))
        eventRef.updateChildValues(dict)
        
        if isPublic {
            let publicRef = DatabaseReference.toLocation(.newPublicEvent)
            publicRef.updateChildValues(dict)
        }
                
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
    
    static func showPublic(filter: Filter?, completion: @escaping ([Event]) -> Void) {
        let publicRef = DatabaseReference.toLocation(.showPublic)
        publicRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            var events: [Event] = snapshot
                .reversed()
                .flatMap {
                    guard let event = Event(snapshot: $0)
                        else { return nil }
                    
                    return event
            }
            if let filter = filter {
                print(filter.location)
                switch filter.category {
                case 0:
                    events = events.filter {$0.category == 0}
                case 1:
                    events = events.filter {$0.category == 1}
                case 2:
                    events = events.filter {$0.category == 2}
                case 3:
                    events = events.filter {$0.category == 3}
                default:
                    break
                }
                
//                switch filter.date {
//                case 0:
//                    events = events.filter {$0.date == Date()}
//                case 1:
//                    events = events.filter {$0.date == 1}
//                case 2:
//                    events = events.filter {$0.date == 2}
//                case 3:
//                    events = events.filter {$0.date == 3}
//                case 4:
//                    events = events.filter {$0.date == 3}
//                default:
//                    break
//                }
                
            }
            completion(events)
        })

        
    }
    
    
}



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
    static func create(title: String, date: Date, time: String, location: String, image: UIImage, link: String, description: String, category: Int, isPublic: Bool, id: String) {
        let imageRef = StorageReference.newEventImageReference()
        StorageService.upload(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            let aspectHeight = image.aspectHeight
            create(title: title, date: date, time: time, location: location, forURLString: urlString, aspectHeight: aspectHeight, link: link, description: description, category: category, isPublic: isPublic, id: id) { (event) in
                    guard event != nil else { return }
                }
        }
        
    }
    
    private static func create(title: String, date: Date, time: String, location: String, forURLString urlString: String, aspectHeight: CGFloat, link: String, description: String, category: Int, isPublic: Bool, id: String, completion: @escaping (Event?) -> Void) {
        let currentUser = User.current
        let event = Event(title: title, date: date, time: time, location: location, imgHeight: aspectHeight, imgURL: urlString, link: link, description: description, category: category, isPublic: isPublic, id: id, hasParticipant: false)
        
        var dict = event.dictValue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        dict["date"] = dateFormatter.string(from: dict["date"] as! Date)
        
        let eventRef = DatabaseReference.toLocation(.newEvent(currentUID: currentUser.uid))
        eventRef.updateChildValues(dict)
        
        if isPublic {
            let publicRef = DatabaseReference.toLocation(.newPublicEvent(eventKey: eventRef.key))
            publicRef.updateChildValues(dict)
        }
                
    }
    
//    static func show(forKey eventKey: String, creatorUID: String, completion: @escaping (Event?) -> Void) {
//        let ref = DatabaseReference.toLocation(.showEvent(uid: creatorUID, eventKey: eventKey))
//        
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let event = Event(snapshot: snapshot) else {
//                return completion(nil)
//            }
//            completion(event)
//        })
//    }
    
    static func remove(currentUID: String, eventKey: String) {
        let publicRef = DatabaseReference.toLocation(.showPublicEvent(eventKey: eventKey))
        publicRef.removeValue()
        let ref = DatabaseReference.toLocation(.showEvent(uid: currentUID, eventKey: eventKey))
        ref.removeValue()
    }
    
    static func showPublic(ids: [String], filter: Filter?, completion: @escaping ([Event]) -> Void) {
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
            let calendar = Calendar.current
            let date = Date()
            if let filter = filter {
                if !filter.isPublic {
                    events = events.filter { ids.contains($0.id) }
                }
                switch filter.category {
                case 0:
                    events = events.filter {$0.category == 0}
                case 1:
                    events = events.filter {$0.category == 1}
                case 2:
                    events = events.filter {$0.category == 2}
                case 3:
                    events = events.filter {$0.category == 3}
                case 4:
                    events = events.filter {$0.category == 4}
                default:
                    break
                }
                switch filter.date {
                case 0:
                    events = events.filter {calendar.isDate($0.date, equalTo: date, toGranularity: .day)}
                case 1:
                    events = events.filter {calendar.isDate($0.date, equalTo: date, toGranularity: .weekOfYear)}
                case 2:
                    events = events.filter {calendar.component(.weekOfYear, from: $0.date) == calendar.component(.weekOfYear, from: calendar.date(byAdding: .weekOfYear, value: 1, to: date)!)}
                case 3:
                    events = events.filter {calendar.isDate($0.date, equalTo: date, toGranularity: .month)}                case 4:
                    events = events.filter {calendar.component(.month, from: $0.date) == calendar.component(.month, from: calendar.date(byAdding: .month, value: 1, to: date)!) }
                default:
                    break
                }
                if !filter.location.isEmpty {
                    events = events.filter {$0.location.lowercased().contains(filter.location.lowercased())}
                }
            }
            //events = events.filter {$0.date >= date}
            events = events.filter {$0.creator.uid != User.current.uid}
            completion(events)
        })

        
    }
    
    
}



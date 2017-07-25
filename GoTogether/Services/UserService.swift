//
//  UserService.swift
//  GoTogether
//
//  Created by Marta on 11/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FacebookCore

struct UserService {
    
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = DatabaseReference.toLocation(.showUser(uid: uid))
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            completion(user)
        })
    }
    
    static func create(_ firUser: FIRUser, name: String, location: String, imgURL: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["name": name, "location": location, "imgURL": imgURL]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let user = User (snapshot: snapshot)
            completion(user)
        })
    }

    
    static func events(for user: User, completion: @escaping ([Event]) -> Void) {
        let ref = DatabaseReference.toLocation(.events(uid: user.uid))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            let events: [Event] = snapshot
                .reversed()
                .flatMap {
                    guard let event = Event(snapshot: $0)
                        else { return nil }
                    
                    return event
            }
            completion(events)
        })
    }
    
    static func friends(completion: @escaping ([FbFriend]) -> Void) {
        let connection = GraphRequestConnection()
        let params = ["fields": "name, picture"]
        connection.add(GraphRequest(graphPath: "/me/friends", parameters: params)) { response, result in
        switch result {
        case .success(let response):
            var friends = [FbFriend]()
            if let responseDict = response.dictionaryValue {
                for friendDict in responseDict["data"] {
                    let name = friendDict["name"] as String
                    let imgURL = friendDict["picture"]["data"]["url"]
                    let friend = FbFriend(name: name, imgURL: imgURL)
                    friends.append(friend)
                }
            }
        case .failed:
            completion([])
        }
        }
        connection.start()
        completion(friends)
    }
    
}

//
//  DatabaseReference+Location.swift
//  GoTogether
//
//  Created by Marta on 11/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation

import FirebaseDatabase

extension DatabaseReference {
    enum GTLocation {
        case root
        case events(uid: String)
        case showEvent(uid: String, eventKey: String)
        case newEvent(currentUID: String)
        case newPublicEvent
        case showPublic
        case users
        case showUser(uid: String)
        
        func asDatabaseReference() -> DatabaseReference {
            let root = Database.database().reference()
            
            switch self {
            case .root:
                return root
            case .events(let uid):
                return root.child("events").child(uid)
            case let .showEvent(uid, eventKey):
                return root.child("events").child(uid).child(eventKey)
            case .newEvent(let currentUID):
                return root.child("events").child(currentUID).childByAutoId()
            case .newPublicEvent:
                return root.child("public_events").childByAutoId()
            case .showPublic:
                return root.child("public_events")
            case .users:
                return root.child("users")
            case .showUser(let uid):
                return root.child("users").child(uid)
            }
        }
    }
    static func toLocation(_ location: GTLocation) -> DatabaseReference {
        return location.asDatabaseReference()
    }
}

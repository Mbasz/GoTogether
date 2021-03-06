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
        case showPublicEvent(eventKey: String)
        case newEvent(currentUID: String)
        case newPublicEvent(eventKey: String)
        case participant(eventKey: String)
        case showPublic
        case users
        case showUser(uid: String)
        case newChat(currentUID: String, eventKey: String)
        case showChats(currentUID: String, eventKey: String)
        case newMessage(chatKey: String)
        case showMessages(chatKey: String)
        case fbID(id: String)
        
        func asDatabaseReference() -> DatabaseReference {
            let root = Database.database().reference()
            
            switch self {
            case .root:
                return root
            case .events(let uid):
                return root.child("events").child(uid)
            case let .showEvent(uid, eventKey):
                return root.child("events").child(uid).child(eventKey)
            case let .showPublicEvent(eventKey):
                return root.child("public_events").child(eventKey)
            case .newEvent(let currentUID):
                return root.child("events").child(currentUID).childByAutoId()
            case .newPublicEvent(let eventKey):
                return root.child("public_events").child(eventKey)
            case .showPublic:
                return root.child("public_events")
            case .participant(let eventKey):
                return root.child("participants").child(eventKey)
            case .users:
                return root.child("users")
            case .showUser(let uid):
                return root.child("users").child(uid)
            case let .newChat(currentUID, eventKey):
                return root.child("chats").child(currentUID).child(eventKey).childByAutoId()
            case let .showChats(currentUID, eventKey):
                return root.child("chats").child(currentUID).child(eventKey)
            case .newMessage(let chatKey):
                return root.child("messages").child(chatKey).childByAutoId()
            case .showMessages(let chatKey):
                return root.child("messages").child(chatKey)
            case .fbID(let id):
                return root.child("fb_IDs").child(id)
            }
        }
    }
    static func toLocation(_ location: GTLocation) -> DatabaseReference {
        return location.asDatabaseReference()
    }
}

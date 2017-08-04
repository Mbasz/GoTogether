//
//  ChatService.swift
//  GoTogether
//
//  Created by Marta on 03/08/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ChatService {
    static func create(from message: Message, with chat: Chat, eventKey: String, completion: @escaping (Chat?) -> Void) {
        
        var membersDict = [String : Bool]()
        for uid in chat.memberUIDs {
            membersDict[uid] = true
        }
        
        let lastMessage = "\(message.sender.name): \(message.content)"
        chat.lastMessage = lastMessage
        let lastMessageSent = message.timestamp.timeIntervalSince1970
        chat.lastMessageSent = message.timestamp
        
        let chatDict: [String : Any] = ["title" : chat.title, "memberHash" : chat.memberHash, "members" : membersDict, "lastMessage" : lastMessage, "lastMessageSent" : lastMessageSent]
        
        let chatRef = DatabaseReference.toLocation(.newChat(currentUID: User.current.uid, eventKey: eventKey))
        chat.key = chatRef.key
        
        var multiUpdateValue = [String : Any]()
        
        for uid in chat.memberUIDs {
            multiUpdateValue["chats/\(uid)/\(eventKey)/\(chatRef.key)"] = chatDict
        }
        
        let messagesRef = DatabaseReference.toLocation(.newMessage(chatKey: chatRef.key))
        let messageKey = messagesRef.key
        
        multiUpdateValue["messages/\(chatRef.key)/\(messageKey)"] = message.dictValue
        
        let rootRef = DatabaseReference.toLocation(.root)
        rootRef.updateChildValues(multiUpdateValue) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            completion(chat)
        }
    }
    
    static func checkForExistingChat(with participant: Participant, eventKey: String, completion: @escaping (Chat?) -> Void) {
        let currentUser = User.current
        let user = Participant(uid: currentUser.uid, name: currentUser.name, imgURL: currentUser.imgURL)
        let members = [participant, user]
        let hashValue = Chat.hash(forMembers: members)
        
        let chatRef = DatabaseReference.toLocation(.showChats(currentUID: currentUser.uid, eventKey: eventKey))
        
        let query = chatRef.queryOrdered(byChild: "memberHash").queryEqual(toValue: hashValue)
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let chatSnap = snapshot.children.allObjects.first as? DataSnapshot,
                let chat = Chat(snapshot: chatSnap)
                else { return completion(nil) }
            
            completion(chat)
        })
    }
    
    static func sendMessage(_ message: Message, for chat: Chat, eventKey: String, success: ((Bool) -> Void)? = nil) {
        guard let chatKey = chat.key else {
            success?(false)
            return
        }
        
        var multiUpdateValue = [String : Any]()
        
        for uid in chat.memberUIDs {
            let lastMessage = "\(message.sender.name): \(message.content)"
            multiUpdateValue["chats/\(uid)/\(eventKey)/\(chatKey)/lastMessage"] = lastMessage
            multiUpdateValue["chats/\(uid)/\(eventKey)/\(chatKey)/lastMessageSent"] = message.timestamp.timeIntervalSince1970
        }
        
        let messagesRef = DatabaseReference.toLocation(.newMessage(chatKey: chatKey))
        let messageKey = messagesRef.key
        multiUpdateValue["messages/\(chatKey)/\(messageKey)"] = message.dictValue
        
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            
            success?(true)
        })
    }
    
    static func observeMessages(forChatKey chatKey: String, completion: @escaping (DatabaseReference, Message?) -> Void) -> DatabaseHandle {
        let messagesRef = DatabaseReference.toLocation(.showMessages(chatKey: chatKey))
        
        return messagesRef.observe(.childAdded, with: { snapshot in
            guard let message = Message(snapshot: snapshot) else {
                return completion(messagesRef, nil)
            }
            completion(messagesRef, message)
        })
    }
    
}

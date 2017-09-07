//
//  ChatViewController.swift
//  GoTogether
//
//  Created by Marta on 04/08/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController {
    var chat: Chat!
    var eventKey: String!
    var messages = [Message]()
    var messagesHandle: DatabaseHandle = 0
    var messagesRef: DatabaseReference?
    var existingChat: Chat?
    var incomingAvatarURL: URL?
    var outgoingAvatarURL: URL?
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }
        
        let color = UIColor.gtPurple
        return bubbleImageFactory.outgoingMessagesBubbleImage(with: color)
    }()
    
    var incomingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }
        
        let color = UIColor.jsq_messageBubbleLightGray()
        return bubbleImageFactory.incomingMessagesBubbleImage(with: color)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupJSQMessagesViewController()
        tryObservingMessages()
        navigationController?.navigationBar.titleTextAttributes?[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: 16)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        messagesRef?.removeObserver(withHandle: messagesHandle)
    }
    
    func setupJSQMessagesViewController() {
        senderId = User.current.uid
        senderDisplayName = User.current.name
        title = chat.title
        
        // remove attachment button
        inputToolbar.contentView.leftBarButtonItem = nil
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height: kJSQMessagesCollectionViewAvatarSizeDefault)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height: kJSQMessagesCollectionViewAvatarSizeDefault)
    }
    
    func tryObservingMessages() {
        guard let chatKey = chat?.key else { return }
        
        messagesHandle = ChatService.observeMessages(forChatKey: chatKey, completion: { [weak self] (ref, message) in
            self?.messagesRef = ref
            
            if let message = message {
                self?.messages.append(message)
                self?.finishReceivingMessage()
            }
        })
    }
    
}

extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].jsqMessageValue
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let sender = message.sender
        
        if sender.uid == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        var message = messages[indexPath.item]
        
        if message.jsqMessageValue.senderId == self.senderId {
            let data = try? Data(contentsOf: outgoingAvatarURL!)
            return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: data!), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
        else {
            let data = try? Data(contentsOf: incomingAvatarURL!)
            return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: data!), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = (message.sender.uid == senderId) ? .white : .black
        return cell
    }
    func sendMessage(_ message: Message) {
        if chat?.key == nil {
            ChatService.create(from: message, with: chat, eventKey: eventKey, completion: { [weak self] chat in
                guard let chat = chat else { return }
                
                self?.chat = chat
                
                self?.tryObservingMessages()
            })
        } else {
            ChatService.sendMessage(message, for: chat, eventKey: eventKey)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = Message(content: text)
        sendMessage(message)
        finishSendingMessage()
        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
    }
}



//
//  ChatTableViewController.swift
//  GoTogether
//
//  Created by Marta on 03/08/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class ProfileChatListTableViewController: UITableViewController {
    var chats = [Chat]()
    var userChatsHandle: DatabaseHandle = 0
    var userChatsRef: DatabaseReference?
    var eventKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        userChatsHandle = UserService.observeChats(for: User.current, eventKey: eventKey) { [weak self] (ref, chats) in
            self?.userChatsRef = ref
            self?.chats = chats
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    deinit {
        userChatsRef?.removeObserver(withHandle: userChatsHandle)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toCreatorChat",
            let destination = segue.destination as? ProfileChatViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            destination.chat = chats[indexPath.row]
            destination.eventKey = eventKey
            destination.outgoingAvatarURL = URL(string: User.current.imgURL)
            UserService.show(forUID: chats[indexPath.row].memberUIDs[1]) { user in
                destination.incomingAvatarURL = URL(string: user!.imgURL)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        
        let chat = chats[indexPath.row]
        cell.titleLabel.text = chat.title
        cell.lastMessageLabel.text = chat.lastMessage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toCreatorChat", sender: self)
    }
}



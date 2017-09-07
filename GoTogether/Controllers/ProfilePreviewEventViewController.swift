//
//  ProfilePreviewEventViewController.swift
//  GoTogether
//
//  Created by Marta on 01/08/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import BEMCheckBox
import UIKit
import FacebookCore
import FacebookShare

class ProfilePreviewEventViewController: UIViewController, BEMCheckBoxDelegate {
    
    var event: Event!
    var participant: Participant?
    var urlLink: URL!
    var existingChat: Chat?
    var creator, user: Participant?
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkbox.delegate = self
        checkbox.onAnimationType = .bounce
        checkbox.offAnimationType = .bounce
        navigationController?.isNavigationBarHidden = false
        deleteButton.layer.cornerRadius = 5
        
        let currentUser = User.current
        creator = Participant(uid: event.creator.uid, name: event.creator.name, imgURL: event.creator.imgURL)
        user = Participant(uid: currentUser.uid, name: currentUser.name, imgURL: currentUser.imgURL)
        
        titleLabel.text = event.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateLabel.text = dateFormatter.string(from: event.date)
        dateFormatter.timeStyle = .medium
        dateFormatter.dateFormat = "hh:mm a"
        timeLabel.text = event.time
        locationLabel.text = event.location
        descriptionLabel.text = event.description
        let eventImgURL = URL(string: event.imgURL)
        eventImageView.kf.setImage(with: eventImgURL)
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 20
        
        if currentUser.uid == event.creator.uid {
            checkbox.isHidden = true
            checkboxLabel.isHidden = true
            
            
            if event.hasParticipant {
                ParticipantService.show(eventKey: event.key!) { participant in
                    self.participant = participant
                    if participant!.imgURL.isEmpty {
                        self.profileImageView.image = UIImage(named: "profilePicture")
                    } else {
                        let imgURL = URL(string: participant!.imgURL)
                        self.profileImageView.kf.setImage(with: imgURL)
                    }
                    self.profileImageView.layer.borderWidth = 1
                    self.profileImageView.layer.borderColor = UIColor.white.cgColor
                    self.nameLabel.text = "\(participant!.name) is going with you!"
                }
            } else {
                nameLabel.isHidden = true
                profileImageView.isHidden = true
            }
        } else {
            deleteButton.isHidden = true
            nameLabel.text = "You're going with \(event.creator.name)!"
            checkboxLabel.text = ""
            profileImageView.layer.borderWidth = 1
            profileImageView.layer.borderColor = UIColor.white.cgColor
            if event.creator.imgURL.isEmpty {
                self.profileImageView.image = UIImage(named: "profilePicture")
            } else {
                let profileImgURL = URL(string: event.creator.imgURL)
                self.profileImageView.kf.setImage(with: profileImgURL)
            }
        }
        
        if URL(string: event.link) != nil {
            urlLink = URL(string: event.link)
            if UIApplication.shared.canOpenURL(urlLink) {
                linkButton.isEnabled = true
            }
            else {
                linkButton.isEnabled = false
            }
        } else {
            linkButton.isEnabled = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        if let url = URL(string: event.link) {
            let content = LinkShareContent(url: url)
            let frame = CGRect(x: self.view.subviews[0].frame.origin.x, y: deleteButton.frame.origin.y, width: deleteButton.frame.width, height: deleteButton.frame.height)
            let shareButton = ShareButton<LinkShareContent>()
            shareButton.content = content
            shareButton.frame = frame
            let shareDialog = ShareDialog(content: content)
            shareDialog.mode = .automatic
            shareDialog.failsOnInvalidData = true
            self.view.addSubview(shareButton)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if event.hasParticipant {
            checkbox.on = true
            checkboxLabel.text = ""
        }
    }
    
    func animationDidStop(for checkBox: BEMCheckBox) {
        if checkbox.on {
            nameLabel.text = "You're going with \(event!.creator.name)!"
            checkboxLabel.text = ""
            UserService.tag(event: event!)
        } else {
            nameLabel.text = "\(event!.creator.name) is going!"
            checkboxLabel.text = "Go Togethr"
            UserService.untag(event: event!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toChats", let destination = segue.destination as? ProfileChatListTableViewController
        {
            destination.eventKey = event?.key!
        } else if segue.identifier == "toParticipantChat", let destination = segue.destination as? ProfileChatViewController {
            let members = [creator!, user!]
            destination.chat = existingChat ?? Chat(members: members)
            destination.eventKey = event.key!
        }
    }

    @IBAction func linkButtonTapped(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(urlLink, options: [:], completionHandler:  { success in
                if !success {
                    let alertController = UIAlertController(title: "Invalid URL", message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        } else {
            UIApplication.shared.openURL(urlLink)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Do you want to delete this event?", message: nil, preferredStyle: .alert)
        
        let addButton = UIAlertAction(title: "Yes", style: .default) { (_) in
            EventService.remove(currentUID: User.current.uid, eventKey: self.event!.key!)
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func chatButtonTapped(_ sender: UIButton) {
        if User.current.uid == event?.creator.uid {
            performSegue(withIdentifier: "toChats", sender: self)
        } else {
            sender.isEnabled = false
            ChatService.checkForExistingChat(with: creator!, eventKey: event.key!) { (chat) in
                sender.isEnabled = true
                self.existingChat = chat
                
                self.performSegue(withIdentifier: "toParticipantChat", sender: self)
            }
        }
    }
    
}






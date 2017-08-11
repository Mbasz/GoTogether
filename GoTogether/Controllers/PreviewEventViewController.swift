//
//  PreviewEventViewController.swift
//  GoTogether
//
//  Created by Marta on 10/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import FacebookShare
import FacebookCore
import BEMCheckBox

class PreviewEventViewController: UIViewController, BEMCheckBoxDelegate {
    
    var event: Event!
    var urlLink: URL!
    var existingChat: Chat?
    var creator, user: Participant?
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkbox.delegate = self
        checkbox.onAnimationType = .bounce
        checkbox.offAnimationType = .bounce
        
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
        
        nameLabel.text = "\(event.creator.name) is going!"
        if event.creator.imgURL.isEmpty {
            profileImageView.image = UIImage(named: "profilePicture")
        } else {
            let profileImgURL = URL(string: event.creator.imgURL)
            profileImageView.kf.setImage(with: profileImgURL)
        }
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        
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
        
//        let shareButton = ShareButton<LinkShareContent>()
//        if let url = URL(string: event.link) {
//            let content = LinkShareContent(url: url)
//            shareButton.content = content
//        }
//        shareButton.frame.origin.y = 570
//        shareButton.frame.origin.x = 27
//        shareButton.frame.size = CGSize(width: 75, height: 30)
//        let shareDialog = ShareDialog(content: content)
//        shareDialog.mode = .native
//        self.view.addSubview(shareButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if event!.hasParticipant {
            checkbox.on = true
            checkboxLabel.text = ""
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animationDidStop(for checkBox: BEMCheckBox) {
        if checkbox.on {
            nameLabel.text = "You're going with \(event!.creator.name)!"
            checkboxLabel.text = ""
            UserService.tag(event: event!)
            performSegue(withIdentifier: "toChat", sender: self)
        } else {
            nameLabel.text = "\(event!.creator.name) is going!"
            checkboxLabel.text = "Go Togethr"
            UserService.untag(event: event!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toChat", let destination = segue.destination as? ChatViewController {
            let currentUser = User.current
            let creator = Participant(uid: event!.creator.uid, name: event!.creator.name, imgURL: event!.creator.imgURL)
            let user = Participant(uid: currentUser.uid, name: currentUser.name, imgURL: currentUser.imgURL)
            let members = [creator, user]
            destination.chat = existingChat ?? Chat(members: members)
            destination.eventKey = event.key!
        }
    }

    
    @IBAction func linkButtonTapped(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(urlLink, options: [:], completionHandler:  { success in
                if !success {
                    let alertController = UIAlertController(title: "Problem with internet connection", message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        } else {
            UIApplication.shared.openURL(urlLink)
        }
    }
    
    @IBAction func chatButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        ChatService.checkForExistingChat(with: creator!, eventKey: event.key!) { (chat) in
            sender.isEnabled = true
            self.existingChat = chat
            
            self.performSegue(withIdentifier: "toChat", sender: self)
        }
    }
    
    
}




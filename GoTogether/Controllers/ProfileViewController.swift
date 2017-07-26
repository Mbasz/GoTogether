//
//  ProfileViewController.swift
//  GoTogether
//
//  Created by Marta on 10/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet

class ProfileViewController: UIViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var myEvents = [Event]()
    var friends = [FbFriend]()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var myEventsButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let user = User.current
        nameLabel.text = user.name
        locationLabel.text = user.location
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        let imgURL = URL(string: user.imgURL)
        profileImageView.kf.setImage(with: imgURL)
        myEventsButton.isUserInteractionEnabled = false
        myEventsButton.layer.opacity = 0.5
        
        self.eventsTableView.reloadData()
        self.eventsTableView.emptyDataSetSource = self
        self.eventsTableView.emptyDataSetDelegate = self
        eventsTableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserService.events(for: User.current) { (events) in
            self.myEvents = events
            self.eventsTableView.reloadData()
        }
        
        UserService.friends { (friends) in
            self.friends = friends
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func title(forEmptyDataSet scrollview: UIScrollView) -> NSAttributedString? {
        if !myEventsButton.isUserInteractionEnabled {
            let str = "You don't have any saved events yet :("
            let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
            return NSAttributedString(string: str, attributes: attrs)
        } else {
            let str = "None of your friends use GoTogether yet. Connect with Facebook and invite them! :)"
            let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
            return NSAttributedString(string: str, attributes: attrs)
        }
    }
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        let color = UIColor.gtPink
        return color
    }
    
    @IBAction func friendsTapped(_ sender: Any) {
        myEventsButton.layer.opacity = 1
        friendsButton.layer.opacity = 0.5
        friendsButton.isUserInteractionEnabled = false
        myEventsButton.isUserInteractionEnabled = true
        eventsTableView.reloadData()
    }
    
    @IBAction func myEventsTapped(_ sender: Any) {
        myEventsButton.layer.opacity = 0.5
        friendsButton.layer.opacity = 1
        friendsButton.isUserInteractionEnabled = true
        myEventsButton.isUserInteractionEnabled = false
        eventsTableView.reloadData()
    }
}

extension ProfileViewController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myEventsButton.isUserInteractionEnabled {
            return friends.count
        } else {
            return myEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if myEventsButton.isUserInteractionEnabled {
            let friend = friends[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "FbFriendCell", for: indexPath) as! FbFriendCell
            
            cell.friendNameLabel.text = friend.name
            let friendImgURL = URL(string: friend.imgURL)
            cell.friendImageView.layer.masksToBounds = true
            cell.friendImageView.layer.cornerRadius = cell.friendImageView.frame.height/2
            cell.friendImageView.kf.setImage(with: friendImgURL)
            
            return cell
        } else {
            let event = myEvents[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            
            switch (event.category) {
            case 0:
                cell.backgroundColor = UIColor.gtBlue
            case 1:
                cell.backgroundColor = UIColor.gtRed
            case 2:
                cell.backgroundColor = UIColor.gtGreen
            case 3:
                cell.backgroundColor = UIColor.gtOrange
            default:
                cell.backgroundColor = UIColor.gtBackground
            }
            
            let eventImgURL = URL(string: event.imgURL)
            let profileImgURL = URL(string: event.creator.imgURL)
            cell.profileImageView.layer.masksToBounds = true
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.height/2
            cell.eventImageView.kf.setImage(with: eventImgURL)
            cell.profileImageView.kf.setImage(with: profileImgURL)
            cell.titleLabel.text = event.title
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            cell.dateLabel.text = dateFormatter.string(from: event.date)
            cell.nameLabel.text = "\(event.creator.name) is going!"
            
            return cell
        }
    }
}

extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if myEventsButton.isUserInteractionEnabled {
            return 70
        } else {
            return 140
        }
    }
}


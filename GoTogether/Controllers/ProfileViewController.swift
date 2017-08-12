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
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var myEvents = [Event]()
    var friends = [FbFriend]()
    var refreshControl: UIRefreshControl?
    
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
        profileImageView.clipsToBounds = true
        if user.imgURL.isEmpty {
            profileImageView.image = UIImage(named: "profilePicture")
        } else {
            let imgURL = URL(string: user.imgURL)
            profileImageView.kf.setImage(with: imgURL)
        }
        myEventsButton.isUserInteractionEnabled = false
        myEventsButton.layer.opacity = 0.5
        myEventsButton.layer.borderColor = UIColor.white.cgColor
        myEventsButton.layer.borderWidth = 1
        friendsButton.layer.borderColor = UIColor.white.cgColor
        friendsButton.layer.borderWidth = 1
        
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.gtPink
        refreshControl!.addTarget(self, action: #selector(reloadMyEvents), for: .valueChanged)
        eventsTableView.addSubview(refreshControl!)
        
        self.eventsTableView.reloadData()
        self.eventsTableView.emptyDataSetSource = self
        self.eventsTableView.emptyDataSetDelegate = self
        eventsTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        reloadMyEvents()
        
        UserService.friends { (friends) in
            self.friends = friends
        }
        
        navigationController?.isNavigationBarHidden = true
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
        let color = UIColor.gtBackground
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
            if friend.imgURL.isEmpty {
                cell.friendImageView.image = UIImage(named: "profilePicture")
            } else {
                let friendImgURL = URL(string: friend.imgURL)
                cell.friendImageView.kf.setImage(with: friendImgURL)
            }
            cell.friendImageView.layer.masksToBounds = true
            cell.friendImageView.layer.borderWidth = 1
            cell.friendImageView.layer.borderColor = UIColor.white.cgColor
            cell.friendImageView.layer.cornerRadius = cell.friendImageView.frame.height/2
            
            return cell
        } else {
            let event = myEvents[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEventCell", for: indexPath) as! ProfileEventCell
            
            switch (event.category) {
//            case 0:
//                cell.backgroundColor = UIColor.gtBlue
//            case 1:
//                cell.backgroundColor = UIColor.gtRed
//            case 2:
//                cell.backgroundColor = UIColor.gtGreen
//            case 3:
//                cell.backgroundColor = UIColor.gtOrange
            default:
                cell.backgroundColor = UIColor.gtPink
            }
            
            let imgURL = URL(string: event.imgURL)
            cell.profileImageView.kf.setImage(with: imgURL)
            cell.profileTitleLabel.text = event.title
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            cell.profileDateLabel.text = dateFormatter.string(from: event.date)
                if event.date < Date() {
                    cell.alpha = 0.1
                }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if myEventsButton.isUserInteractionEnabled {
            return 60
        } else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !myEventsButton.isUserInteractionEnabled {
            let event = myEvents[indexPath.row]
            performSegue(withIdentifier: "toProfilePreview", sender: event)
        }
    }
    
    func reloadMyEvents() {
        UserService.myEvents(for: User.current) { (events) in
            self.myEvents = events
            if self.refreshControl!.isRefreshing {
                self.refreshControl!.endRefreshing()
            }
            self.eventsTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfilePreview" {
            if let vc = segue.destination as? ProfilePreviewEventViewController {
                if let sender = sender as? Event {
                    vc.event = sender
                }
            }
        }
    }
}



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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var eventsTableView: UITableView!
    
    
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
        
        self.eventsTableView.emptyDataSetSource = self
        self.eventsTableView.emptyDataSetDelegate = self
        
        eventsTableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func title(forEmptyDataSet scrollview: UIScrollView) -> NSAttributedString? {
        let str = "You don't have any saved events yet :("
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        let color = UIColor(red: 230/255, green: 210/255, blue: 245/255, alpha: 1)
        return color
    }
}

extension ProfileViewController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventsCell") as! EventCell
        return cell
    }
}



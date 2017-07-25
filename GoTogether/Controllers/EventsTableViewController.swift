//
//  ViewController.swift
//  GoTogether
//
//  Created by Marta on 10/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class EventsTableViewController: UITableViewController, UITabBarControllerDelegate {

    var events = [Event]()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        EventService.showPublic() { (events) in
            self.events = events
            self.tableView.reloadData()
        }
        
        let numberOfItems = CGFloat((tabBarController?.tabBar.items!.count)!)
        let tabBarItemSize = CGSize(width: (tabBarController?.tabBar.frame.width)! / numberOfItems, height: (tabBarController?.tabBar.frame.height)!)
        tabBarController?.tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: UIColor.gtSelected, size: tabBarItemSize).resizableImage(withCapInsets: .zero)
        
        tabBarController?.tabBar.frame.size.width = self.view.frame.width + 4
        tabBarController?.tabBar.frame.origin.x = -2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let event = events[indexPath.row]
        
        return 140
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toPreview", sender: events[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPreview" {
            if let vc = segue.destination as? PreviewEventViewController {
                if let sender = sender as? Event {
                    vc.event = sender
                }
            }
        }
    }
}



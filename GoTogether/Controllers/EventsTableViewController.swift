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

protocol EventsTableViewControllerDelegate {
    func updateFilter(filter: Filter?)
}

class EventsTableViewController: UITableViewController, UITabBarControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UISearchResultsUpdating, EventsTableViewControllerDelegate {

    var events = [Event]()
    var eventsSearched: Array<Event>?
    var filter: Filter?
    var delegate: EventsTableViewControllerDelegate?
    let searchController = UISearchController(searchResultsController: nil)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        EventService.showPublic(filter: filter) { (events) in
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
        searchController.searchResultsUpdater = self
        //searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismiss(animated: true, completion: nil)
        searchController.dismiss(animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let events = eventsSearched else {
            return 0
        }
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
        if let events = eventsSearched {
            let event = events[indexPath.row]
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
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    @IBAction func searchTapped(_ sender: Any) {
//        let alertController = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
//        alertController.addTextField { textField in
//            textField.placeholder = ""
//        }
//        let search = UIAlertAction(title: "GO", style: .default) { (_) in
//            let textField = alertController.textFields![0]
//            self.events = self.events.filter {$0.title.contains(textField.text!)}
//            self.tableView.reloadData()
//        }
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alertController.addAction(search)
//        alertController.addAction(cancel)
//        
//        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            eventsSearched = events.filter { event in
                return event.title.lowercased().contains(searchText.lowercased())
            }
            
        } else {
            eventsSearched = events
        }
        tableView.reloadData()
    }
    
    func updateFilter(filter: Filter?) {
        if let filter = filter {
            self.filter = filter
        }
    }
}



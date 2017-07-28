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

class EventsTableViewController: UITableViewController, UITabBarControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {

    var events = [Event]()
    var eventsSearched: Array<Event>?
    var filter: Filter?
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
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        searchController.searchBar.barTintColor = UIColor.gtBackground
        searchController.delegate = self
        searchController.searchBar.enablesReturnKeyAutomatically = false
        tableView.tableHeaderView = nil
        tableView.tableFooterView = UIView()
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
        if searchController.isActive {
            return eventsSearched?.count ?? 0
        }
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
        let event: Event
        if !searchController.isActive {
            event = events[indexPath.row]
        } else {
            event = (eventsSearched?[indexPath.row])!
        }
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
            cell.backgroundColor = UIColor.gtPink
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
        } else if segue.identifier == "toFilter" {
            if let filterVC = segue.destination as? FilterViewController {
                filterVC.eventsVC = self
            }
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
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
    
    @IBAction func searchTapped(_ sender: Any) {
        if tableView.tableHeaderView != nil {
            tableView.tableHeaderView = nil
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    
    @IBAction func filterTapped(_ sender: Any) {
        performSegue(withIdentifier: "toFilter", sender: self)
    }
    
    
}



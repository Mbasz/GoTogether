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
import DZNEmptyDataSet

class EventsTableViewController: UITableViewController, UITabBarControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var ids = [String]()
    var events = [Event]()
    var friendsEvents: [Event]?
    var eventsSearched: Array<Event>? = nil
    var filter: Filter?
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchController.searchBar.resignFirstResponder()
        
        UserService.friends { friends in
            let friends = friends
            self.ids = friends.map { $0.uid }
        }
        
        reloadEvents()
        
        let numberOfItems = CGFloat((tabBarController?.tabBar.items!.count)!)
        let tabBarItemSize = CGSize(width: (tabBarController?.tabBar.frame.width)! / numberOfItems, height: (tabBarController?.tabBar.frame.height)!)
        tabBarController?.tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: UIColor.gtSelected, size: tabBarItemSize).resizableImage(withCapInsets: .zero)
        
        tabBarController?.tabBar.frame.size.width = self.view.frame.width + 4
        tabBarController?.tabBar.frame.origin.x = -2
        
        if filter != nil {
            filterButton.image = UIImage(named: "clearFilter")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        searchController.searchBar.barTintColor = UIColor.gtBackground
        self.tableView.tableHeaderView = searchController.searchBar
        self.tableView.tableFooterView = UIView()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        filter = nil
        
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.gtBackground
        refreshControl!.addTarget(self, action: #selector(reloadEvents), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func title(forEmptyDataSet scrollview: UIScrollView) -> NSAttributedString? {
        let str = "No events found."
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        let color = UIColor.gtBackground
        return color
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return eventsSearched?.count ?? 0
        }
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        
        let event: Event
        if searchController.isActive && searchController.searchBar.text != "" {
            event = (eventsSearched?[indexPath.row])!
        } else {
            event = events[indexPath.row]
        }
        switch (event.category) {
//        case 0:
//            cell.backgroundColor = UIColor.gtBlue
//        case 1:
//            cell.backgroundColor = UIColor.gtRed
//        case 2:
//            cell.backgroundColor = UIColor.gtGreen
//        case 3:
//            cell.backgroundColor = UIColor.gtOrange
        default:
            cell.backgroundColor = UIColor.gtPink
        }
        
        let eventImgURL = URL(string: event.imgURL)
        if event.creator.imgURL.isEmpty {
            cell.profileImageView.image = UIImage(named: "profilePicture")
        } else {
            let profileImgURL = URL(string: event.creator.imgURL)
            cell.profileImageView.kf.setImage(with: profileImgURL)
        }
        cell.profileImageView.layer.masksToBounds = true
        cell.profileImageView.layer.borderWidth = 1
        cell.profileImageView.layer.borderColor = UIColor.white.cgColor
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.height/2
        cell.eventImageView.kf.setImage(with: eventImgURL)
        cell.titleLabel.text = event.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        cell.dateLabel.text = dateFormatter.string(from: event.date)
        cell.nameLabel.text = "\(event.creator.name) is going!"
        
        cell.alpha = 0.5
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event: Event?
        if searchController.isActive && searchController.searchBar.text != "" {
            event = eventsSearched?[indexPath.row]
        } else {
            event = events[indexPath.row]
        }
        performSegue(withIdentifier: "toPreview", sender: event)
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
    
    func reloadEvents() {
        EventService.showPublic(ids: ids, filter: filter) { (events) in
            self.events = events
            if self.refreshControl!.isRefreshing {
                self.refreshControl!.endRefreshing()
            }
            self.tableView.reloadData()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        eventsSearched = events.filter { event in
            return event.title.lowercased().contains(searchController.searchBar.text!.lowercased())
        }

        self.tableView.reloadData()
    }
    
    @IBAction func filterTapped(_ sender: Any) {
        if filter != nil {
            filter = nil
            friendsEvents = nil
            filterButton.image = UIImage(named: "filter")
            reloadEvents()
        } else {
            performSegue(withIdentifier: "toFilter", sender: self)
        }
    }
    
    
}



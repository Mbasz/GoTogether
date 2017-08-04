//
//  NewEventViewController.swift
//  GoTogether
//
//  Created by Marta on 10/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import SwiftLinkPreview
import GooglePlaces

class NewEventViewController: UIViewController, MFMessageComposeViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UISearchControllerDelegate, UISearchBarDelegate {
    
    weak var categoriesVC: CategoriesViewController?
    let slp = SwiftLinkPreview()
    var image = UIImage(named: "uploadImage")
    var friends = [PhoneFriend]()
    let imageHelper = GTImageHelper()
    var searchController: UISearchController?
    var results = [String]()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        activityIndicator.backgroundColor = UIColor.gtPurple
        activityIndicator.startAnimating()
        
        slp.preview(categoriesVC!.link, onSuccess: { result in
            if let title: String = result[.title] as? String {
                self.titleTextField.text = title
            }
            if let description = result[.description] as? String, description.characters.count < 100 {
                self.descriptionTextView.text = description
            }
            if let imageURL = result[.image] as? String {
                self.uploadImageView.kf.setImage(with: URL(string: imageURL))
            }
            
        }, onError: { error in
            print("\(error.localizedDescription)")
        })
        
        activityIndicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        eventDatePicker.minimumDate = Date()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(tapGestureRecognizer)
        
        imageHelper.completionHandler = { image in
            self.uploadImageView.image = image
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        tapGesture.cancelsTouchesInView = true
//        self.view.addGestureRecognizer(tapGesture)
        
        addFriendButton.layer.cornerRadius = 5
        createButton.layer.cornerRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //if searchBar.text != "" {
            view.viewWithTag(100)?.frame.origin = CGPoint(x: 27, y: 65)
        //}
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //if searchBar.text == "" {
            view.viewWithTag(100)?.frame.origin = CGPoint(x: 27, y: 225)
        //}
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" && text.characters.count == 1 {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        categoriesVC!.reload = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: eventDatePicker.date), title = self.titleTextField.text!, location = locationTextField.text!, link = categoriesVC!.link
        let date = eventDatePicker.date
        dateFormatter.timeStyle = .medium
        dateFormatter.dateFormat = "hh:mm a"
        let time = dateFormatter.string(from: eventDatePicker.date)
        if self.uploadImageView.image! == image {
            switch (categoriesVC!.category) {
            case 0:
                image = UIImage(named: "Workshop-1")
            case 1:
                image = UIImage(named: "Culture-1")
            case 2:
                image = UIImage(named: "Sport-1")
            case 3:
                image = UIImage(named: "Social-1")
            default:
                image = UIImage(named: "Other-1")
            }
        } else {
            image = self.uploadImageView.image!
        }
        
        EventService.create(title: title, date: date, time: time, location: location, image: self.image!, link: link, description: self.descriptionTextView.text!, category: categoriesVC!.category, isPublic: categoriesVC!.isPublic)
        
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
        } else {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            composeVC.recipients = friends.map({$0.number})
            composeVC.body = "Hi, I want to invite you to this event: \(title) which takes place on \(dateString). Place: \(location). And here's the link: \(link). See you there!"
            
            self.present(composeVC, animated: true, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
        tabBarController?.selectedIndex = 0
        navigationController?.popToRootViewController(animated: true)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imageHelper.presentImagePickerController(with: .photoLibrary, from: self)
        }
    }
    
    @IBAction func addLocationTapped(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        autocompleteController.tableCellBackgroundColor = UIColor.gtBackground
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func addFriendTapped(_ sender: Any) {
        
        //show alert controller
        let alertController = UIAlertController(title: "Add New Friend", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Type name"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Type phone number"
        }
        
        let addButton = UIAlertAction(title: "Add", style: .default) { (_) in
            //append this friend to array
            guard let nameField = alertController.textFields?[0], let numberField = alertController.textFields?[1] else {
                return
            }
            let name = nameField.text!
            let number = numberField.text!
            
            let friend = PhoneFriend(name: name, number: number)

            self.friends.append(friend)
            self.friendsTableView.isHidden = false
            self.friendsTableView.reloadData()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension NewEventViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.locationTextField.text = place.formattedAddress
        self.locationTextField.backgroundColor = UIColor.white
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


extension NewEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhoneFriendCell") as! PhoneFriendCell
        let friend = friends[indexPath.row]
        cell.nameLabel.text = friend.name
        cell.numberLabel.text = friend.number
        return cell
    }
    
}




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

class NewEventViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    var friends = [Friend]()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var friendsTableView: UITableView!
    
    
    let imageHelper = GTImageHelper()
    
//    override func viewWillAppear(_ animated: Bool) {
//        titleTextField.text = ""
//        eventDatePicker.date = Date()
//        locationTextField.text = ""
//        linkTextField.text = ""
//        uploadImageView.image = UIImage(contentsOfFile: "uploadImage")
//        
//        friendsTableView.isHidden = true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.eventDatePicker.minimumDate = Date()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(tapGestureRecognizer)
        
        imageHelper.completionHandler = { image in
            self.uploadImageView.image = image
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        let calendar = Calendar.current
        let date = dateFormatter.string(from: eventDatePicker.date), title = self.titleTextField.text!, location = self.locationTextField.text!, link = self.linkTextField.text!
        EventService.create(title: title, date: eventDatePicker.date, location: location, image: self.uploadImageView.image!, link: self.linkTextField.text!, description: self.descriptionTextField.text!)
        
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
            print("Hi, I want to invite you to this event: \(title) which takes place on \(date). Place: \(location). And here's the link: \(link). See you there!")
        } else {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            composeVC.recipients = friends.map({$0.phone})
            composeVC.body = "Hi, I want to invite you to this event: \(title) which takes place on \(date). Place: \(location). And here's the link: \(link). See you there!"
            
            self.present(composeVC, animated: true, completion: nil)
        }

        tabBarController?.selectedIndex = 0
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
    
    @IBAction func addFriendTapped(_ sender: Any) {
        
        //show alert controller
        let alertController = UIAlertController(title: "Add New Friend", message: nil, preferredStyle: .alert)
        let addButton = UIAlertAction(title: "Add", style: .default) { (_) in
            //append this friend to array
            guard let nameField = alertController.textFields?[0], let phoneField = alertController.textFields?[1] else {
                return
            }
            let name = nameField.text!
            let phone = phoneField.text!
            
            let friend = Friend(name: name, phone: phone)

            self.friends.append(friend)
            self.friendsTableView.isHidden = false
            self.friendsTableView.reloadData()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addButton)
        alertController.addAction(cancelButton)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Type name"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Type phone number"
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension NewEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
        let friend = friends[indexPath.row]
        cell.nameLabel.text = friend.name
        cell.phoneLabel.text = friend.phone
        return cell
    }
    
}


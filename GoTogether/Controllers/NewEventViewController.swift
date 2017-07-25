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

class NewEventViewController: UIViewController, MFMessageComposeViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    let slp = SwiftLinkPreview()
    var category = -1
    var isPublic = true
    var link = ""
    var image = UIImage(named: "uploadImage")
    var friends = [PhoneFriend]()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var friendsTableView: UITableView!
    
    
    let imageHelper = GTImageHelper()
    
    override func viewWillAppear(_ animated: Bool) {
//        titleTextField.text = ""
//        eventDatePicker.date = Date()
//        locationTextField.text = ""
//        uploadImageView.image = UIImage(contentsOfFile: "uploadImage")
//        descriptionTextView.text = ""
//        friendsTableView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.eventDatePicker.minimumDate
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(tapGestureRecognizer)
        
        imageHelper.completionHandler = { image in
            self.uploadImageView.image = image
        }
        self.titleTextField.delegate = self
        self.locationTextField.delegate = self
        self.descriptionTextView.delegate = self
        
        slp.preview(link, onSuccess: { result in
            if let title: String = result[.title] as? String {
                self.titleTextField.text = title
            }
            if let description = result[.description] as? String {
                self.descriptionTextView.text = description
            }
            if let imageURL = result[.image] as? String {
                self.uploadImageView.kf.setImage(with: URL(string: imageURL))
            }
            
        }, onError: { error in
            print("\(error.localizedDescription)")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: eventDatePicker.date), title = self.titleTextField.text!, location = self.locationTextField.text!, link = self.link
        let date = eventDatePicker.date
        dateFormatter.timeStyle = .medium
        dateFormatter.dateFormat = "hh:mm a"
        let time = dateFormatter.string(from: eventDatePicker.date)
        if self.uploadImageView.image! == image {
            switch (category) {
            case 0:
                image = UIImage(named: "Workshop-1")
            case 1:
                image = UIImage(named: "Culture-1")
            case 2:
                image = UIImage(named: "Sport-1")
            case 3:
                image = UIImage(named: "Social-1")
            default:
                image = UIImage(named: "uploadImage")
            }
        } else {
            image = self.uploadImageView.image!
        }
        
        EventService.create(title: title, date: date, time: time, location: location, image: self.image!, link: self.link, description: self.descriptionTextView.text!, category: category, isPublic: isPublic)
        
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
            print("Hi, I want to invite you to this event: \(title) which takes place on \(dateString). Place: \(location). And here's the link: \(link). See you there!")
        } else {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            composeVC.recipients = friends.map({$0.phone})
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
            
            let friend = PhoneFriend(name: name, phone: phone)

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhoneFriendCell") as! PhoneFriendCell
        let friend = friends[indexPath.row]
        cell.nameLabel.text = friend.name
        cell.phoneLabel.text = friend.phone
        return cell
    }
    
}


//
//  CategoriesViewController.swift
//  GoTogether
//
//  Created by Marta on 19/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit

class  CategoriesViewController: UIViewController, UITextFieldDelegate {
    
    var selected = false
    var category = -1
    var isPublic = true
    var link = ""
    var reload = false
    
    @IBOutlet weak var workshopButton: UIButton!
    @IBOutlet weak var cultureButton: UIButton!
    @IBOutlet weak var sportButton: UIButton!
    @IBOutlet weak var socialButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var publicSegmentedControl: UISegmentedControl!
    @IBOutlet weak var linkTextfield: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        publicSegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 16)], for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(CategoriesViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CategoriesViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.linkTextfield.delegate = self
        nextButton.layer.cornerRadius = 5
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if reload {
            workshopButton.layer.opacity = 1
            workshopButton.isUserInteractionEnabled = true
            cultureButton.layer.opacity = 1
            cultureButton.isUserInteractionEnabled = true
            sportButton.layer.opacity = 1
            sportButton.isUserInteractionEnabled = true
            socialButton.layer.opacity = 1
            socialButton.isUserInteractionEnabled = true
            otherButton.layer.opacity = 1
            otherButton.isUserInteractionEnabled = true
            publicSegmentedControl.selectedSegmentIndex = 0
            linkTextfield.text = ""
            selected = false
        }
        
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - (tabBarController?.tabBar.frame.height)!)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += (keyboardSize.height - (tabBarController?.tabBar.frame.height)!)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewEvent" {
            if let vc = segue.destination as? NewEventViewController {
                link = linkTextfield.text!
                if publicSegmentedControl.selectedSegmentIndex == 0 {
                    isPublic = true
                }
                else {
                    isPublic = false
                }
                vc.categoriesVC = self
            }
        }
    }
    
    @IBAction func workshopTapped(_ sender: Any) {
        workshopButton.layer.opacity = 0.5
        workshopButton.isUserInteractionEnabled = false
        cultureButton.layer.opacity = 1
        cultureButton.isUserInteractionEnabled = true
        sportButton.layer.opacity = 1
        sportButton.isUserInteractionEnabled = true
        socialButton.layer.opacity = 1
        socialButton.isUserInteractionEnabled = true
        otherButton.layer.opacity = 1
        otherButton.isUserInteractionEnabled = true
        category = 0
        selected = true
    }
    
    @IBAction func cultureTapped(_ sender: Any) {
        workshopButton.layer.opacity = 1
        workshopButton.isUserInteractionEnabled = true
        cultureButton.layer.opacity = 0.5
        cultureButton.isUserInteractionEnabled = false
        sportButton.layer.opacity = 1
        sportButton.isUserInteractionEnabled = true
        socialButton.layer.opacity = 1
        socialButton.isUserInteractionEnabled = true
        otherButton.layer.opacity = 1
        otherButton.isUserInteractionEnabled = true
        category = 1
        selected = true
    }
    
    @IBAction func sportTapped(_ sender: Any) {
        workshopButton.layer.opacity = 1
        workshopButton.isUserInteractionEnabled = true
        cultureButton.layer.opacity = 1
        cultureButton.isUserInteractionEnabled = true
        sportButton.layer.opacity = 0.5
        sportButton.isUserInteractionEnabled = false
        socialButton.layer.opacity = 1
        socialButton.isUserInteractionEnabled = true
        otherButton.layer.opacity = 1
        otherButton.isUserInteractionEnabled = true
        category = 2
        selected = true
    }
    
    @IBAction func socialTapped(_ sender: Any) {
        workshopButton.layer.opacity = 1
        workshopButton.isUserInteractionEnabled = true
        cultureButton.layer.opacity = 1
        cultureButton.isUserInteractionEnabled = true
        sportButton.layer.opacity = 1
        sportButton.isUserInteractionEnabled = true
        socialButton.layer.opacity = 0.5
        socialButton.isUserInteractionEnabled = false
        otherButton.layer.opacity = 1
        otherButton.isUserInteractionEnabled = true
        category = 3
        selected = true
    }
    
    @IBAction func otherTapped(_ sender: Any) {
        workshopButton.layer.opacity = 1
        workshopButton.isUserInteractionEnabled = true
        cultureButton.layer.opacity = 1
        cultureButton.isUserInteractionEnabled = true
        sportButton.layer.opacity = 1
        sportButton.isUserInteractionEnabled = true
        socialButton.layer.opacity = 1
        socialButton.isUserInteractionEnabled = true
        otherButton.layer.opacity = 0.5
        otherButton.isUserInteractionEnabled = false
        category = 4
        selected = true
    }
    
    
    @IBAction func nextTapped(_ sender: Any) {
        if selected {
            self.view.endEditing(true)
            reload = false
            performSegue(withIdentifier: "toNewEvent", sender: self)
        } else {
            let alertController = UIAlertController(title: "Please select a category", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}


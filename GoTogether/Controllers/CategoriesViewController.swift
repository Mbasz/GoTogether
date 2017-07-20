//
//  CategoriesViewController.swift
//  GoTogether
//
//  Created by Marta on 19/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit

class  CategoriesViewController: UIViewController {
    
    var category = -1
    var isPublic = true
    
    @IBOutlet weak var workshopButton: UIButton!
    @IBOutlet weak var cultureButton: UIButton!
    @IBOutlet weak var sportButton: UIButton!
    @IBOutlet weak var socialButton: UIButton!
    @IBOutlet weak var publicSegmentedControl: UISegmentedControl!
    @IBOutlet weak var linkTextfield: UITextField!
    
    override func viewDidLoad() {
        publicSegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 16)], for: .normal)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewEvent" {
            if let vc = segue.destination as? NewEventViewController {
                vc.category = category
                vc.isPublic = isPublic
                vc.link = linkTextfield.text!
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
        category = 0
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
        category = 1
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
        category = 2
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
        category = 3
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        performSegue(withIdentifier: "toNewEvent", sender: self)
    }
    
    @IBAction func isPublicTapped(_ sender: Any) {
        if publicSegmentedControl.isEnabledForSegment(at: 0) {
            isPublic = true
        }
        else {
            isPublic = false
        }
    }
    
    
}


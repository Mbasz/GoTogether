//
//  FilterViewController.swift
//  GoTogether
//
//  Created by Marta on 26/07/2017.
//  Copyright © 2017 Marta. All rights reserved.
//

import Foundation
import UIKit

class FilterViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    var isPublic = true
    var location = ""
    var category = -1
    var date = -1
    
    @IBOutlet weak var publicSegmentedControl: UISegmentedControl!
    @IBOutlet weak var locationTextField: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextField.delegate = self
    }
    
    
}

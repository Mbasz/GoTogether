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
    var category = -1
    var date = -1
    var categoryContainerVC: FilterCategoryTableViewController!
    var dateContainerVC: FilterDateTableViewController!
    var filter: Filter? = nil
    weak var eventsVC: EventsTableViewController?
    
    @IBOutlet weak var publicSegmentedControl: UISegmentedControl!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var timeContainer: UIView!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextField.delegate = self
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        tapGesture.cancelsTouchesInView = true
//        self.view.addGestureRecognizer(tapGesture)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            categoryContainerVC = childViewControllers[0] as! FilterCategoryTableViewController
            if publicSegmentedControl.selectedSegmentIndex == 0 {
                isPublic = true
            } else {
                isPublic = false
            }
            category = categoryContainerVC.selected
            dateContainerVC = childViewControllers[1] as! FilterDateTableViewController
            date = dateContainerVC.selected
            if !isPublic || locationTextField.text != "" || category != -1 || date != -1 {
                filter = Filter(isPublic: isPublic, location: locationTextField.text!, category: category, date: date)
            }
            eventsVC?.filter = filter
        }
    }
}
